import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../../../core/services/file_service.dart';
import '../../../core/services/pdf_support.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/contract_pdf_service.dart';
import '../data/contract_repository.dart';

/// Contract preview: print / share (built into PdfPreview) plus save & open.
class ContractPdfView extends StatefulWidget {
  const ContractPdfView({super.key});

  @override
  State<ContractPdfView> createState() => _ContractPdfViewState();
}

class _ContractPdfViewState extends State<ContractPdfView> {
  final _repo = ContractRepository();
  final _service = ContractPdfService();
  late final int _id = (Get.arguments as Map)['id'] as int;
  ContractBundle? _bundle;
  String _lang = 'ar';
  bool _fontOk = true;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final b = await _repo.loadBundle(_id);
      if (b == null) {
        setState(() {
          _error = 'not_found'.tr;
          _loading = false;
        });
        return;
      }
      final stored = '${b.contract['language'] ?? ''}';
      _lang = (stored == 'ar' || stored == 'en')
          ? stored
          : Get.find<StorageService>().langCode;
      _fontOk = await PdfSupport.hasArabicFont();
      setState(() {
        _bundle = b;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String get _fileName =>
      '${_bundle?.contract['contract_no'] ?? 'contract'}.pdf';

  Future<String?> _save() async {
    final bytes = await _service.build(_bundle!, lang: _lang);
    final file =
        await Get.find<FileService>().saveBytes('contracts', _fileName, bytes);
    await _repo.update(_id, {'pdf_path': file.path});
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('contract_preview'.tr),
        actions: [
          if (_bundle != null) ...[
            PopupMenuButton<String>(
              tooltip: 'f_language'.tr,
              icon: const Icon(Icons.translate),
              initialValue: _lang,
              onSelected: (v) => setState(() => _lang = v),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'ar', child: Text('العربية')),
                const PopupMenuItem(value: 'en', child: Text('English')),
              ],
            ),
            IconButton(
              tooltip: 'save_pdf'.tr,
              icon: const Icon(Icons.save_alt),
              onPressed: () async {
                final p = await _save();
                if (p != null) showOk('pdf_saved');
              },
            ),
            IconButton(
              tooltip: 'open_pdf'.tr,
              icon: const Icon(Icons.open_in_new),
              onPressed: () async {
                final p = await _save();
                final err = await Get.find<FileService>().open(p);
                if (err != null) showErr(err);
              },
            ),
          ],
        ],
      ),
      body: _loading
          ? const LoadingState()
          : _error != null
              ? ErrorState(message: _error, onRetry: _init)
              : Column(children: [
                  if (!_fontOk && _lang == 'ar')
                    MaterialBanner(
                      content: Text('arabic_font_missing'.tr),
                      leading: const Icon(Icons.warning_amber_rounded),
                      actions: const [SizedBox.shrink()],
                    ),
                  Expanded(
                    child: PdfPreview(
                      key: ValueKey(_lang),
                      build: (format) => _service.build(_bundle!, lang: _lang),
                      pdfFileName: _fileName,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      canDebug: false,
                      allowPrinting: true,
                      allowSharing: true,
                    ),
                  ),
                ]),
    );
  }
}
