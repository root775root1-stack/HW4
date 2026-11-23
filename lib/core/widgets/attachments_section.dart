import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/documents/data/attachment_repository.dart';
import '../crud/generic_repository.dart';
import '../services/file_service.dart';
import '../utils/formatters.dart';
import 'common_widgets.dart';

String fileSizeText(Object? bytes) {
  final b = toD(bytes);
  if (b < 1024) return '${b.toInt()} B';
  if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
  return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
}

IconData fileIcon(String? kind) {
  switch ((kind ?? '').toLowerCase()) {
    case 'pdf':
      return Icons.picture_as_pdf_outlined;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'webp':
    case 'heic':
      return Icons.image_outlined;
    default:
      return Icons.insert_drive_file_outlined;
  }
}

/// One attachment row: open / share / delete with graceful missing-file handling.
class AttachmentTile extends StatelessWidget {
  const AttachmentTile({
    super.key,
    required this.row,
    required this.onChanged,
    this.showOwner = false,
  });
  final DbRow row;
  final VoidCallback onChanged;
  final bool showOwner;

  @override
  Widget build(BuildContext context) {
    final files = Get.find<FileService>();
    final created = txt(row['created_at']);
    final date = created.length >= 10 ? created.substring(0, 10) : created;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(fileIcon(txt(row['kind']))),
      title: Text(txt(row['name']).isEmpty ? 'unnamed'.tr : txt(row['name']),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text([
        if (showOwner) 'o_${txt(row['owner_type'])}'.tr,
        if (showOwner && txt(row['owner_name']).isNotEmpty)
          txt(row['owner_name']),
        txt(row['kind']).toUpperCase(),
        date,
        fileSizeText(row['size_bytes']),
      ].where((e) => e.isNotEmpty).join('  •  ')),
      onTap: () async {
        final err = await files.open(txt(row['file_path']));
        if (err != null) showErr(err);
      },
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          final path = txt(row['file_path']);
          if (v == 'open') {
            final err = await files.open(path);
            if (err != null) showErr(err);
          } else if (v == 'share') {
            final err = await files.share(path);
            if (err != null) showErr(err);
          } else if (v == 'delete') {
            if (await confirmDialog()) {
              await AttachmentRepository()
                  .delete(txt(row['owner_type']), row['id'] as int, path);
              showOk('deleted_ok');
              onChanged();
            }
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'open', child: Text('open'.tr)),
          PopupMenuItem(value: 'share', child: Text('share'.tr)),
          PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
        ],
      ),
    );
  }
}

/// Reusable attachments card for details screens.
class AttachmentsSection extends StatefulWidget {
  const AttachmentsSection(
      {super.key, required this.ownerType, required this.ownerId});
  final String ownerType;
  final int ownerId;

  @override
  State<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends State<AttachmentsSection> {
  final _repo = AttachmentRepository();
  late Future<List<DbRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.list(widget.ownerType, widget.ownerId);
  }

  void _reload() =>
      setState(() => _future = _repo.list(widget.ownerType, widget.ownerId));

  Future<void> _add(String source) async {
    final files = Get.find<FileService>();
    final List<StoredFile> picked;
    if (source == 'file') {
      picked = await files.pickFiles();
    } else {
      final f = await files.pickImage(camera: source == 'camera');
      picked = f == null ? [] : [f];
    }
    if (picked.isEmpty) return;
    for (final f in picked) {
      await _repo.add(widget.ownerType, widget.ownerId, f);
    }
    showOk('attachment_added');
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      titleKey: 'attachments',
      icon: Icons.attach_file,
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.add_circle_outline),
        tooltip: 'add_attachment'.tr,
        onSelected: _add,
        itemBuilder: (_) => [
          PopupMenuItem(value: 'file', child: Text('pick_file'.tr)),
          PopupMenuItem(value: 'gallery', child: Text('pick_image'.tr)),
          PopupMenuItem(value: 'camera', child: Text('take_photo'.tr)),
        ],
      ),
      child: FutureBuilder<List<DbRow>>(
        future: _future,
        builder: (c, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
                padding: EdgeInsets.all(8), child: LinearProgressIndicator());
          }
          final rows = snap.data ?? [];
          if (rows.isEmpty) return Text('no_attachments'.tr);
          return Column(children: [
            for (final r in rows) AttachmentTile(row: r, onChanged: _reload),
          ]);
        },
      ),
    );
  }
}
