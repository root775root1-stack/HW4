/// Single source of truth for every translated string in the app.
/// Used both by GetX (`.tr`, via [AppTranslations]) and by the contract PDF
/// generator (via `labelFor`), which runs outside the widget tree and must
/// pick a language explicitly.
const Map<String, Map<String, String>> kTranslations = {
  // ---------------------------------------------------------------- generic
  'app_name': {'en': 'Property Manager', 'ar': 'مدير العقارات'},
  'dashboard': {'en': 'Dashboard', 'ar': 'لوحة التحكم'},
  'properties': {'en': 'Properties', 'ar': 'العقارات'},
  'units': {'en': 'Units', 'ar': 'الوحدات'},
  'tenants': {'en': 'Tenants', 'ar': 'المستأجرون'},
  'tenant': {'en': 'Tenant', 'ar': 'المستأجر'},
  'contracts': {'en': 'Contracts', 'ar': 'العقود'},
  'obligations': {'en': 'Financial Obligations', 'ar': 'الالتزامات المالية'},
  'payments': {'en': 'Payments', 'ar': 'المدفوعات'},
  'services': {'en': 'Services', 'ar': 'الخدمات'},
  'documents': {'en': 'Documents', 'ar': 'المستندات'},
  'reports': {'en': 'Reports', 'ar': 'التقارير'},
  'settings': {'en': 'Settings', 'ar': 'الإعدادات'},
  'about': {'en': 'About', 'ar': 'حول التطبيق'},
  'more': {'en': 'More', 'ar': 'المزيد'},
  'unit': {'en': 'Unit', 'ar': 'الوحدة'},
  'property': {'en': 'Property', 'ar': 'العقار'},
  'not_found': {'en': 'Page not found', 'ar': 'الصفحة غير موجودة'},
  'add': {'en': 'Add', 'ar': 'إضافة'},
  'edit': {'en': 'Edit', 'ar': 'تعديل'},
  'delete': {'en': 'Delete', 'ar': 'حذف'},
  'save': {'en': 'Save', 'ar': 'حفظ'},
  'cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
  'confirm': {'en': 'Confirm', 'ar': 'تأكيد'},
  'search': {'en': 'Search', 'ar': 'بحث'},
  'retry': {'en': 'Retry', 'ar': 'إعادة المحاولة'},
  'required': {'en': 'Required', 'ar': 'حقل مطلوب'},
  'invalid_number': {'en': 'Invalid number', 'ar': 'رقم غير صحيح'},
  'invalid_email': {'en': 'Invalid email', 'ar': 'بريد إلكتروني غير صحيح'},
  'no_data': {'en': 'No records yet', 'ar': 'لا توجد سجلات بعد'},
  'no_results': {'en': 'No matching results', 'ar': 'لا توجد نتائج مطابقة'},
  'empty_hint': {
    'en': 'Start by adding your first record',
    'ar': 'ابدأ بإضافة أول سجل'
  },
  'saved_ok': {'en': 'Saved successfully', 'ar': 'تم الحفظ بنجاح'},
  'deleted_ok': {'en': 'Deleted successfully', 'ar': 'تم الحذف بنجاح'},
  'save_failed': {'en': 'Save failed', 'ar': 'فشل الحفظ'},
  'error_generic': {'en': 'Something went wrong', 'ar': 'حدث خطأ ما'},
  'all': {'en': 'All', 'ar': 'الكل'},
  'view_all': {'en': 'View all', 'ar': 'عرض الكل'},
  'yes': {'en': 'Yes', 'ar': 'نعم'},
  'no': {'en': 'No', 'ar': 'لا'},
  'unnamed': {'en': 'Unnamed', 'ar': 'بدون اسم'},
  'attachments': {'en': 'Attachments', 'ar': 'المرفقات'},
  'no_attachments': {'en': 'No attachments yet', 'ar': 'لا توجد مرفقات بعد'},
  'attachment_added': {'en': 'Attachment added', 'ar': 'تمت إضافة المرفق'},
  'add_attachment': {'en': 'Add attachment', 'ar': 'إضافة مرفق'},
  'pick_file': {'en': 'Choose file', 'ar': 'اختيار ملف'},
  'pick_image': {'en': 'Choose photo', 'ar': 'اختيار صورة'},
  'take_photo': {'en': 'Take photo', 'ar': 'التقاط صورة'},
  'open': {'en': 'Open', 'ar': 'فتح'},
  'share': {'en': 'Share', 'ar': 'مشاركة'},
  'file_missing': {'en': 'File not found', 'ar': 'الملف غير موجود'},
  'file_open_failed': {'en': 'Could not open the file', 'ar': 'تعذر فتح الملف'},
  'due': {'en': 'Due', 'ar': 'الاستحقاق'},
  'status': {'en': 'Status', 'ar': 'الحالة'},
  'outstanding': {'en': 'Outstanding', 'ar': 'المتبقي'},
  'remaining': {'en': 'Remaining', 'ar': 'المتبقي'},
  'overdue': {'en': 'Overdue', 'ar': 'المتأخرات'},
  'rented_units': {'en': 'Rented units', 'ar': 'الوحدات المؤجرة'},
  'rented_short': {'en': 'rented', 'ar': 'مؤجرة'},
  'occupied_units': {'en': 'Occupied units', 'ar': 'الوحدات المؤجرة'},
  'available_units': {'en': 'Available units', 'ar': 'الوحدات المتاحة'},
  'active_contracts': {'en': 'Active contracts', 'ar': 'العقود النشطة'},
  'due_this_month': {'en': 'Due this month', 'ar': 'المستحق هذا الشهر'},
  'paid_this_month': {'en': 'Paid this month', 'ar': 'المدفوع هذا الشهر'},
  'overdue_warning': {
    'en': '{n} overdue obligations',
    'ar': 'يوجد {n} التزامات متأخرة'
  },
  'upcoming_dues': {'en': 'Upcoming dues', 'ar': 'المستحقات القادمة'},
  'recent_contracts': {'en': 'Recent contracts', 'ar': 'أحدث العقود'},
  'recent_payments': {'en': 'Recent payments', 'ar': 'أحدث المدفوعات'},
  'no_upcoming': {'en': 'No upcoming dues', 'ar': 'لا توجد مستحقات قادمة'},
  'add_property': {'en': 'Add Property', 'ar': 'إضافة عقار'},
  'edit_property': {'en': 'Edit Property', 'ar': 'تعديل العقار'},
  'add_tenant': {'en': 'Add Tenant', 'ar': 'إضافة مستأجر'},
  'edit_tenant': {'en': 'Edit Tenant', 'ar': 'تعديل المستأجر'},
  'create_contract': {'en': 'Create Lease Contract', 'ar': 'إنشاء عقد إيجار'},
  'edit_contract': {'en': 'Edit Contract', 'ar': 'تعديل العقد'},
  'record_payment': {'en': 'Record Payment', 'ar': 'تسجيل دفعة'},
  'edit_payment': {'en': 'Edit Payment', 'ar': 'تعديل الدفعة'},
  'property_info': {'en': 'Property information', 'ar': 'بيانات العقار'},
  'occupancy': {'en': 'Occupancy', 'ar': 'نسبة الإشغال'},
  'unit_info': {'en': 'Unit information', 'ar': 'بيانات الوحدة'},
  'no_units': {'en': 'No units yet', 'ar': 'لا توجد وحدات بعد'},
  'no_contracts': {'en': 'No contracts yet', 'ar': 'لا توجد عقود بعد'},
  'no_active_contracts': {
    'en': 'No active contracts',
    'ar': 'لا توجد عقود نشطة'
  },
  'no_services': {'en': 'No services yet', 'ar': 'لا توجد خدمات بعد'},
  'personal_info': {'en': 'Personal information', 'ar': 'البيانات الشخصية'},
  'payment_history': {'en': 'Payment history', 'ar': 'سجل المدفوعات'},
  'no_payments': {'en': 'No payments yet', 'ar': 'لا توجد مدفوعات بعد'},
  'outstanding_obligations': {
    'en': 'Outstanding obligations',
    'ar': 'الالتزامات المستحقة'
  },
  'no_outstanding': {
    'en': 'No outstanding obligations',
    'ar': 'لا توجد التزامات مستحقة'
  },
  'financial_record': {'en': 'Financial record', 'ar': 'السجل المالي'},
  'add_unit': {'en': 'Add Unit', 'ar': 'إضافة وحدة'},
  'edit_unit': {'en': 'Edit Unit', 'ar': 'تعديل الوحدة'},
  'cannot_delete_has_units': {
    'en': 'Cannot delete: property has units',
    'ar': 'لا يمكن الحذف: العقار يحتوي على وحدات'
  },
  'cannot_delete_has_contracts': {
    'en': 'Cannot delete: linked to contracts',
    'ar': 'لا يمكن الحذف: مرتبط بعقود'
  },
  'add_property_first': {
    'en': 'Add a property first',
    'ar': 'أضف عقاراً أولاً'
  },
  'unit_duplicate': {
    'en': 'This unit number already exists',
    'ar': 'رقم الوحدة موجود مسبقاً'
  },
  'no_properties': {'en': 'No properties yet', 'ar': 'لا توجد عقارات بعد'},
  'no_tenants': {'en': 'No tenants yet', 'ar': 'لا يوجد مستأجرون بعد'},
  'add_service': {'en': 'Add Service', 'ar': 'إضافة خدمة'},
  'edit_service': {'en': 'Edit Service', 'ar': 'تعديل الخدمة'},
  'service_target_required': {
    'en': 'Choose a property or a unit',
    'ar': 'اختر عقاراً أو وحدة'
  },
  'service_has_history': {
    'en': 'Has financial history; deactivate instead',
    'ar': 'له سجل مالي؛ يمكن إيقافه بدلاً من الحذف'
  },
  'record_reading': {'en': 'Record reading', 'ar': 'تسجيل قراءة'},
  'period_format': {
    'en': 'Use the format YYYY-MM',
    'ar': 'استخدم الصيغة YYYY-MM'
  },
  'no_units_available': {
    'en': 'No units available',
    'ar': 'لا توجد وحدات متاحة'
  },
  'activate': {'en': 'Activate', 'ar': 'تفعيل'},
  'deactivate': {'en': 'Deactivate', 'ar': 'إيقاف'},
  'change_photo': {'en': 'Change photo', 'ar': 'تغيير الصورة'},
  'obligations_after_activation': {
    'en': 'Obligations are created once the contract is activated',
    'ar': 'تُنشأ الالتزامات بعد تفعيل العقد',
  },
  'rent': {'en': 'Rent', 'ar': 'إيجار'},
  'service_charge': {'en': 'Service charge', 'ar': 'رسوم خدمة'},
  'duplicate': {'en': 'Duplicate', 'ar': 'نسخ'},

  // ---------------------------------------------------------------- contract form
  'discard_title': {'en': 'Discard changes?', 'ar': 'تجاهل التغييرات؟'},
  'discard_message': {
    'en': 'Unsaved changes will be lost.',
    'ar': 'ستفقد التغييرات غير المحفوظة.'
  },
  'discard': {'en': 'Discard', 'ar': 'تجاهل'},
  'only_draft_editable': {
    'en': 'Only draft contracts can be edited',
    'ar': 'يمكن تعديل العقود في حالة المسودة فقط'
  },
  'fix_errors': {
    'en': 'Please fix the highlighted fields',
    'ar': 'يرجى تصحيح الحقول المظللة'
  },
  'end_before_start': {
    'en': 'End date must be after start date',
    'ar': 'يجب أن يكون تاريخ النهاية بعد تاريخ البداية'
  },
  'rent_positive': {
    'en': 'Rent must be greater than zero',
    'ar': 'يجب أن يكون الإيجار أكبر من صفر'
  },
  'contract_activated': {'en': 'Contract activated', 'ar': 'تم تفعيل العقد'},
  'duplicate_contract_no': {
    'en': 'This contract number already exists',
    'ar': 'رقم العقد موجود مسبقاً'
  },
  'save_draft': {'en': 'Save draft', 'ar': 'حفظ كمسودة'},
  'previous': {'en': 'Previous', 'ar': 'السابق'},
  'next': {'en': 'Next', 'ar': 'التالي'},
  'save_contract': {'en': 'Save contract', 'ar': 'حفظ العقد'},
  'suggest_words': {'en': 'Suggest in words', 'ar': 'اقتراح بالحروف'},
  'note_tenant_select': {
    'en':
        'Pick an existing tenant to autofill their data, or type a new tenant directly.',
    'ar':
        'اختر مستأجراً موجوداً لتعبئة بياناته تلقائياً، أو أدخل بيانات مستأجر جديد مباشرة.',
  },
  'note_handover': {
    'en':
        'Photos of the unit at handover can be attached from the contract details screen.',
    'ar': 'يمكن إرفاق صور الوحدة عند التسليم من شاشة تفاصيل العقد.',
  },
  'note_signatures': {
    'en':
        'Signature and fingerprint areas are left blank in the PDF for manual completion after printing.',
    'ar':
        'تبقى مساحات التوقيع والبصمة فارغة في ملف PDF لاستكمالها يدوياً بعد الطباعة.',
  },
  'legal_note': {
    'en':
        'This contract is a customizable template, not legal advice. Have it reviewed by a qualified lawyer under your local law.',
    'ar':
        'هذا العقد نموذج قابل للتخصيص وليس استشارة قانونية. يُنصح بمراجعته من محامٍ مختص وفق القانون المحلي المعمول به.',
  },
  'confirm_terminate': {
    'en': 'Terminate this contract?',
    'ar': 'هل تريد إنهاء هذا العقد؟'
  },
  'confirm_cancel': {
    'en': 'Cancel this contract?',
    'ar': 'هل تريد إلغاء هذا العقد؟'
  },
  'confirm_suspend': {
    'en': 'Suspend this contract?',
    'ar': 'هل تريد إيقاف هذا العقد مؤقتاً؟'
  },
  'activate_contract': {'en': 'Activate', 'ar': 'تفعيل العقد'},
  'suspend_contract': {'en': 'Suspend', 'ar': 'إيقاف مؤقت'},
  'terminate_contract': {'en': 'Terminate', 'ar': 'إنهاء العقد'},
  'cancel_contract': {'en': 'Cancel contract', 'ar': 'إلغاء العقد'},
  'status_changed': {'en': 'Status updated', 'ar': 'تم تحديث الحالة'},
  'contract_duplicated': {
    'en': 'Contract duplicated as a new draft',
    'ar': 'تم نسخ العقد كمسودة جديدة'
  },
  'cannot_delete_has_obligations': {
    'en': 'Cannot delete: has financial history',
    'ar': 'لا يمكن الحذف: له سجل مالي'
  },
  'cannot_delete_active': {
    'en': 'Cannot delete an active contract',
    'ar': 'لا يمكن حذف عقد نشط'
  },
  'unit_inactive': {'en': 'The unit is inactive', 'ar': 'الوحدة غير نشطة'},
  'unit_has_active_contract': {
    'en': 'The unit already has an active contract',
    'ar': 'يوجد للوحدة عقد نشط بالفعل'
  },
  'contract_already_ended': {
    'en': 'The contract end date has already passed',
    'ar': 'تاريخ نهاية العقد قد مضى بالفعل'
  },

  // ---------------------------------------------------------------- PDF
  'contract_preview': {'en': 'Contract Preview', 'ar': 'معاينة العقد'},
  'save_pdf': {'en': 'Save PDF', 'ar': 'حفظ PDF'},
  'open_pdf': {'en': 'Open PDF', 'ar': 'فتح PDF'},
  'pdf_saved': {'en': 'PDF saved', 'ar': 'تم حفظ الملف'},
  'arabic_font_missing': {
    'en':
        'Arabic font not found in assets/fonts — Arabic text may not render correctly.',
    'ar':
        'لم يتم العثور على خط عربي في assets/fonts — قد لا يظهر النص العربي بشكل صحيح.',
  },
  'lease_agreement': {'en': 'Lease Agreement', 'ar': 'عقد إيجار'},
  'signature': {'en': 'Signature', 'ar': 'التوقيع'},
  'fingerprint': {'en': 'Fingerprint', 'ar': 'البصمة'},
  'witness': {'en': 'Witness', 'ar': 'الشاهد'},
  'landlord': {'en': 'Landlord', 'ar': 'المالك'},
  'print_contract': {'en': 'Print Contract', 'ar': 'طباعة العقد'},

  // ---------------------------------------------------------------- payments
  'overpay_title': {
    'en': 'Amount exceeds balance',
    'ar': 'المبلغ يتجاوز المستحق'
  },
  'overpay_confirm': {
    'en': 'The paid amount is larger than what is owed. Continue anyway?',
    'ar': 'المبلغ المدفوع أكبر من المستحق. هل تريد المتابعة؟',
  },
  'amount_positive': {
    'en': 'Amount must be greater than zero',
    'ar': 'يجب أن يكون المبلغ أكبر من صفر'
  },
  'no_documents': {'en': 'No documents yet', 'ar': 'لا توجد مستندات بعد'},
  'no_documents_hint': {
    'en':
        'Attachments added to properties, units, tenants and contracts appear here',
    'ar': 'تظهر هنا المرفقات المضافة للعقارات والوحدات والمستأجرين والعقود',
  },

  // ---------------------------------------------------------------- reports
  'report_properties': {
    'en': 'Properties & Units',
    'ar': 'تقرير العقارات والوحدات'
  },
  'report_tenants': {'en': 'Tenants', 'ar': 'تقرير المستأجرين'},
  'report_contracts': {'en': 'Contracts', 'ar': 'تقرير العقود'},
  'report_obligations': {
    'en': 'Monthly Obligations',
    'ar': 'تقرير الالتزامات الشهرية'
  },
  'report_payments': {'en': 'Payments', 'ar': 'تقرير المدفوعات'},
  'report_overdue': {'en': 'Overdue', 'ar': 'تقرير المتأخرات'},
  'report_services': {'en': 'Service Costs', 'ar': 'تقرير تكاليف الخدمات'},

  // ---------------------------------------------------------------- settings
  'appearance': {'en': 'Appearance', 'ar': 'المظهر'},
  'language': {'en': 'Language', 'ar': 'اللغة'},
  'theme_dark': {'en': 'Dark mode', 'ar': 'الوضع الداكن'},
  'financial_settings': {'en': 'Financial', 'ar': 'الإعدادات المالية'},
  'currency': {'en': 'Currency', 'ar': 'العملة'},
  'owner_profile': {'en': 'Owner profile', 'ar': 'بيانات المالك'},
  'owner_profile_hint': {
    'en': 'Pre-fills the landlord section of new contracts',
    'ar': 'تُستخدم لتعبئة بيانات المالك تلقائياً في العقود الجديدة',
  },
  'default_contract_settings': {
    'en': 'Default contract settings',
    'ar': 'إعدادات العقد الافتراضية'
  },
  'security': {'en': 'Security', 'ar': 'الأمان'},
  'set_pin': {'en': 'Set / change PIN', 'ar': 'تعيين / تغيير رمز PIN'},
  'remove_pin': {'en': 'Remove PIN', 'ar': 'إزالة رمز PIN'},
  'remove_pin_confirm': {
    'en': 'Remove the PIN lock?',
    'ar': 'هل تريد إزالة قفل PIN؟'
  },
  'enter_pin': {'en': 'Enter PIN', 'ar': 'أدخل رمز PIN'},
  'new_pin': {'en': 'New PIN (4-6 digits)', 'ar': 'رمز PIN جديد (4-6 أرقام)'},
  'wrong_pin': {'en': 'Wrong PIN', 'ar': 'رمز PIN غير صحيح'},
  'unlock': {'en': 'Unlock', 'ar': 'فتح'},
  'pin_length': {
    'en': 'PIN must be 4 to 6 digits',
    'ar': 'يجب أن يتكون رمز PIN من 4 إلى 6 أرقام'
  },
  'pin_set': {'en': 'PIN set', 'ar': 'تم تعيين رمز PIN'},
  'pin_removed': {'en': 'PIN removed', 'ar': 'تمت إزالة رمز PIN'},
  'data': {'en': 'Data', 'ar': 'البيانات'},
  'backup': {'en': 'Backup database', 'ar': 'نسخة احتياطية من قاعدة البيانات'},
  'backup_hint': {
    'en': 'Save a copy outside the app',
    'ar': 'حفظ نسخة خارج التطبيق'
  },
  'backup_saved': {'en': 'Backup saved', 'ar': 'تم حفظ النسخة الاحتياطية'},
  'backup_failed': {'en': 'Backup failed', 'ar': 'فشل إنشاء النسخة الاحتياطية'},
  'restore_database': {
    'en': 'Restore database',
    'ar': 'استعادة قاعدة البيانات'
  },
  'restore_hint': {
    'en': 'Replace current data from a backup file',
    'ar': 'استبدال البيانات الحالية من ملف نسخة احتياطية'
  },
  'restore_confirm': {
    'en':
        'This replaces all current data with the backup file. A safety copy of the current data is kept. Continue?',
    'ar':
        'سيؤدي هذا إلى استبدال جميع البيانات الحالية بملف النسخة الاحتياطية، مع الاحتفاظ بنسخة أمان من البيانات الحالية. هل تريد المتابعة؟',
  },
  'restore_ok': {'en': 'Database restored', 'ar': 'تمت استعادة قاعدة البيانات'},
  'restore_invalid': {
    'en': 'This is not a valid PTMS backup file',
    'ar': 'هذا الملف ليس نسخة احتياطية صالحة'
  },
  'restore_failed': {'en': 'Restore failed', 'ar': 'فشلت عملية الاستعادة'},
  'app_version': {'en': 'Version', 'ar': 'الإصدار'},
  'legal_note_title': {'en': 'Legal note', 'ar': 'ملاحظة قانونية'},
  'legal_note_body': {
    'en':
        'Lease contracts generated by this app are a customizable template. They are not legal advice and are not guaranteed to be valid in every jurisdiction. Have the final wording reviewed by a qualified lawyer under your applicable local law.',
    'ar':
        'عقود الإيجار التي ينشئها هذا التطبيق هي نموذج قابل للتخصيص، وليست استشارة قانونية، ولا تضمن صحتها القانونية في كل البلدان. يُنصح بمراجعة الصياغة النهائية من قبل محامٍ مختص وفق القانون المحلي المعمول به.',
  },

  // ---------------------------------------------------------------- field labels
  'f_name': {'en': 'Name', 'ar': 'الاسم'},
  'f_full_name': {'en': 'Full legal name', 'ar': 'الاسم الكامل'},
  'f_address': {'en': 'Address', 'ar': 'العنوان'},
  'f_city': {'en': 'City', 'ar': 'المدينة'},
  'f_country': {'en': 'Country', 'ar': 'الدولة'},
  'f_postal_code': {'en': 'Postal code', 'ar': 'الرمز البريدي'},
  'f_floors': {'en': 'Number of floors', 'ar': 'عدد الطوابق'},
  'f_units_count': {'en': 'Number of units', 'ar': 'عدد الوحدات'},
  'f_owner_name': {'en': 'Owner name', 'ar': 'اسم المالك'},
  'f_owner_phone': {'en': 'Owner phone', 'ar': 'هاتف المالك'},
  'f_description': {'en': 'Description', 'ar': 'الوصف'},
  'f_notes': {'en': 'Notes', 'ar': 'ملاحظات'},
  'f_property_type': {'en': 'Property type', 'ar': 'نوع العقار'},
  'f_floor': {'en': 'Floor', 'ar': 'الطابق'},
  'f_type': {'en': 'Type', 'ar': 'النوع'},
  'f_area': {'en': 'Area (m²)', 'ar': 'المساحة (م²)'},
  'f_bedrooms': {'en': 'Bedrooms', 'ar': 'عدد الغرف'},
  'f_bathrooms': {'en': 'Bathrooms', 'ar': 'عدد دورات المياه'},
  'f_furnishing': {'en': 'Furnishing', 'ar': 'حالة الفرش'},
  'f_base_rent': {'en': 'Base rent', 'ar': 'الإيجار الأساسي'},
  'f_deposit_amount': {'en': 'Deposit amount', 'ar': 'مبلغ التأمين'},
  'f_meter_electric': {
    'en': 'Electricity meter no.',
    'ar': 'رقم عداد الكهرباء'
  },
  'f_meter_water': {'en': 'Water meter no.', 'ar': 'رقم عداد المياه'},
  'f_name_ar': {'en': 'Arabic name', 'ar': 'الاسم بالعربية'},
  'f_name_en': {'en': 'English name', 'ar': 'الاسم بالإنجليزية'},
  'f_id_type': {'en': 'ID type', 'ar': 'نوع الهوية'},
  'f_id_number': {'en': 'ID / passport number', 'ar': 'رقم الهوية / الجواز'},
  'f_id_issue_date': {'en': 'ID issue date', 'ar': 'تاريخ إصدار الهوية'},
  'f_id_expiry_date': {'en': 'ID expiry date', 'ar': 'تاريخ انتهاء الهوية'},
  'f_nationality': {'en': 'Nationality', 'ar': 'الجنسية'},
  'f_birth_date': {'en': 'Date of birth', 'ar': 'تاريخ الميلاد'},
  'f_gender': {'en': 'Gender', 'ar': 'الجنس'},
  'f_phone': {'en': 'Phone', 'ar': 'رقم الهاتف'},
  'f_phone2': {'en': 'Alternative phone', 'ar': 'هاتف بديل'},
  'f_email': {'en': 'Email', 'ar': 'البريد الإلكتروني'},
  'f_employer': {'en': 'Employer / company', 'ar': 'جهة العمل'},
  'f_job_title': {'en': 'Job title', 'ar': 'المسمى الوظيفي'},
  'f_emergency_name': {
    'en': 'Emergency contact name',
    'ar': 'اسم جهة الاتصال في الطوارئ'
  },
  'f_emergency_phone': {
    'en': 'Emergency contact phone',
    'ar': 'هاتف جهة الاتصال في الطوارئ'
  },
  'f_emergency_relation': {'en': 'Relationship', 'ar': 'صلة القرابة'},
  'f_contract_no': {'en': 'Contract number', 'ar': 'رقم العقد'},
  'f_title': {'en': 'Contract title', 'ar': 'عنوان العقد'},
  'f_contract_type': {'en': 'Contract type', 'ar': 'نوع العقد'},
  'f_created_date': {'en': 'Creation date', 'ar': 'تاريخ الإنشاء'},
  'f_start_date': {'en': 'Start date', 'ar': 'تاريخ البداية'},
  'f_end_date': {'en': 'End date', 'ar': 'تاريخ النهاية'},
  'f_renewal_option': {'en': 'Renewal option', 'ar': 'خيار التجديد'},
  'f_renewal_period': {'en': 'Renewal period', 'ar': 'مدة التجديد'},
  'f_notice_period': {'en': 'Notice period (days)', 'ar': 'مدة الإشعار (أيام)'},
  'f_language': {'en': 'Contract language', 'ar': 'لغة العقد'},
  'f_currency': {'en': 'Currency', 'ar': 'العملة'},
  'f_allow_overlap': {
    'en': 'Allow overlap with another contract',
    'ar': 'السماح بالتداخل مع عقد آخر'
  },
  'f_status': {'en': 'Status', 'ar': 'الحالة'},
  'f_id_number_landlord': {
    'en': 'National ID / commercial registration',
    'ar': 'رقم الهوية / السجل التجاري'
  },
  'f_bank_name': {'en': 'Bank name', 'ar': 'اسم البنك'},
  'f_iban': {'en': 'Bank account / IBAN', 'ar': 'رقم الحساب / الآيبان'},
  'f_rep_name': {
    'en': 'Authorized representative name',
    'ar': 'اسم الممثل المفوض'
  },
  'f_rep_id': {'en': 'Representative ID', 'ar': 'هوية الممثل المفوض'},
  'f_tenant_id': {'en': 'Existing tenant', 'ar': 'مستأجر موجود'},
  'f_property_id': {'en': 'Property', 'ar': 'العقار'},
  'f_unit_id': {'en': 'Unit', 'ar': 'الوحدة'},
  'f_property_name': {'en': 'Property name', 'ar': 'اسم العقار'},
  'f_property_address': {'en': 'Property address', 'ar': 'عنوان العقار'},
  'f_unit_number': {'en': 'Unit number', 'ar': 'رقم الوحدة'},
  'f_unit_type': {'en': 'Unit type', 'ar': 'نوع الوحدة'},
  'f_parking_space': {'en': 'Parking space', 'ar': 'موقف السيارة'},
  'f_storage_room': {'en': 'Storage room', 'ar': 'غرفة التخزين'},
  'f_facilities': {'en': 'Included facilities', 'ar': 'المرافق المشمولة'},
  'f_condition_at_handover': {
    'en': 'Condition at handover',
    'ar': 'حالة الوحدة عند التسليم'
  },
  'f_rent_amount': {'en': 'Monthly rent', 'ar': 'الإيجار الشهري'},
  'f_rent_words': {'en': 'Rent amount in words', 'ar': 'قيمة الإيجار كتابة'},
  'f_advance_payment': {'en': 'Advance payment', 'ar': 'الدفعة المقدمة'},
  'f_payment_cycle': {'en': 'Payment frequency', 'ar': 'دورية السداد'},
  'f_due_day': {'en': 'Due day of month', 'ar': 'يوم الاستحقاق من الشهر'},
  'f_grace_period': {'en': 'Grace period (days)', 'ar': 'مهلة السماح (أيام)'},
  'f_late_fee': {'en': 'Late payment fee', 'ar': 'غرامة التأخير'},
  'f_late_fee_type': {'en': 'Late fee type', 'ar': 'نوع غرامة التأخير'},
  'f_utilities_included': {
    'en': 'Utilities included',
    'ar': 'الخدمات المشمولة'
  },
  'f_electricity_resp': {
    'en': 'Electricity responsibility',
    'ar': 'مسؤولية الكهرباء'
  },
  'f_water_resp': {'en': 'Water responsibility', 'ar': 'مسؤولية المياه'},
  'f_internet_resp': {
    'en': 'Internet responsibility',
    'ar': 'مسؤولية الإنترنت'
  },
  'f_maintenance_resp': {
    'en': 'Maintenance responsibility',
    'ar': 'مسؤولية الصيانة'
  },
  'f_service_charges': {'en': 'Service charges', 'ar': 'رسوم الخدمات'},
  'f_commission': {'en': 'Commission', 'ar': 'العمولة'},
  'f_other_charges': {
    'en': 'Other recurring charges',
    'ar': 'رسوم إضافية أخرى'
  },
  'f_payment_method': {'en': 'Payment method', 'ar': 'طريقة السداد'},
  'f_bank_details': {'en': 'Bank details', 'ar': 'بيانات البنك'},
  'f_payment_notes': {'en': 'Payment notes', 'ar': 'ملاحظات حول السداد'},
  'f_permitted_use': {
    'en': 'Permitted use',
    'ar': 'الغرض المسموح من الاستخدام'
  },
  'f_occupants_count': {'en': 'Number of occupants', 'ar': 'عدد الساكنين'},
  'f_sublet_allowed': {
    'en': 'Subletting permitted',
    'ar': 'السماح بالتأجير من الباطن'
  },
  'f_pets_allowed': {'en': 'Pets permitted', 'ar': 'السماح بالحيوانات الأليفة'},
  'f_smoking_allowed': {'en': 'Smoking permitted', 'ar': 'السماح بالتدخين'},
  'f_alterations_allowed': {
    'en': 'Alterations permitted',
    'ar': 'السماح بالتعديلات'
  },
  'f_maintenance_terms': {'en': 'Maintenance terms', 'ar': 'شروط الصيانة'},
  'f_repairs_resp': {'en': 'Repairs responsibility', 'ar': 'مسؤولية الإصلاحات'},
  'f_inspection_rights': {'en': 'Inspection rights', 'ar': 'حقوق المعاينة'},
  'f_access_notice': {
    'en': 'Access notice period (hours)',
    'ar': 'مدة إشعار الدخول (ساعات)'
  },
  'f_noise_rules': {'en': 'Noise restrictions', 'ar': 'قيود الضوضاء'},
  'f_parking_rules': {'en': 'Parking rules', 'ar': 'قواعد مواقف السيارات'},
  'f_common_area_rules': {
    'en': 'Common area rules',
    'ar': 'قواعد المناطق المشتركة'
  },
  'f_insurance_req': {'en': 'Insurance requirements', 'ar': 'متطلبات التأمين'},
  'f_early_termination': {
    'en': 'Early termination terms',
    'ar': 'شروط الإنهاء المبكر'
  },
  'f_breach_terms': {
    'en': 'Breach & default terms',
    'ar': 'شروط الإخلال بالعقد'
  },
  'f_dispute_resolution': {
    'en': 'Dispute resolution',
    'ar': 'آلية فض النزاعات'
  },
  'f_governing_law': {'en': 'Governing law', 'ar': 'القانون الحاكم'},
  'f_jurisdiction': {'en': 'Jurisdiction', 'ar': 'الاختصاص القضائي'},
  'f_special_conditions': {'en': 'Special conditions', 'ar': 'شروط خاصة'},
  'f_additional_clauses': {'en': 'Additional clauses', 'ar': 'بنود إضافية'},
  'f_handover_date': {'en': 'Handover date', 'ar': 'تاريخ التسليم'},
  'f_keys_count': {'en': 'Number of keys', 'ar': 'عدد المفاتيح'},
  'f_cards_count': {'en': 'Number of access cards', 'ar': 'عدد بطاقات الدخول'},
  'f_furniture_list': {'en': 'Furniture inventory', 'ar': 'جرد الأثاث'},
  'f_appliances_list': {'en': 'Appliances inventory', 'ar': 'جرد الأجهزة'},
  'f_damage_notes': {
    'en': 'Existing damage notes',
    'ar': 'ملاحظات الأضرار الموجودة'
  },
  'f_reading_electric': {
    'en': 'Electricity meter reading',
    'ar': 'قراءة عداد الكهرباء'
  },
  'f_reading_water': {'en': 'Water meter reading', 'ar': 'قراءة عداد المياه'},
  'f_handover_notes': {'en': 'Handover notes', 'ar': 'ملاحظات التسليم'},
  'f_w1_name': {'en': 'Witness 1 name', 'ar': 'اسم الشاهد الأول'},
  'f_w1_id': {'en': 'Witness 1 ID', 'ar': 'هوية الشاهد الأول'},
  'f_w2_name': {'en': 'Witness 2 name', 'ar': 'اسم الشاهد الثاني'},
  'f_w2_id': {'en': 'Witness 2 ID', 'ar': 'هوية الشاهد الثاني'},
  'f_signed_date': {'en': 'Date of signature', 'ar': 'تاريخ التوقيع'},
  'f_is_active': {'en': 'Active', 'ar': 'نشط'},
  'f_amount': {'en': 'Amount', 'ar': 'المبلغ'},
  'f_billing_type': {'en': 'Billing type', 'ar': 'طريقة الاحتساب'},
  'f_split_method': {'en': 'Split method', 'ar': 'طريقة التوزيع'},
  'f_paid_on': {'en': 'Payment date', 'ar': 'تاريخ الدفع'},
  'f_method': {'en': 'Payment method', 'ar': 'طريقة الدفع'},
  'f_reference': {'en': 'Reference number', 'ar': 'الرقم المرجعي'},
  'f_bank_txn_no': {
    'en': 'Bank transaction number',
    'ar': 'رقم العملية البنكية'
  },
  'f_quantity': {'en': 'Quantity', 'ar': 'الكمية'},
  'f_period': {'en': 'Period (YYYY-MM)', 'ar': 'الفترة (سنة-شهر)'},

  // report table headers (reuse / extra)
  'f_city_r': {'en': 'City', 'ar': 'المدينة'},
  'f_tenant': {'en': 'Tenant', 'ar': 'المستأجر'},
  'f_target': {'en': 'Applies to', 'ar': 'مطبّقة على'},
  'f_balance': {'en': 'Balance', 'ar': 'الرصيد'},
  'f_due_date': {'en': 'Due date', 'ar': 'تاريخ الاستحقاق'},
  'f_paid_amount': {'en': 'Paid amount', 'ar': 'المبلغ المدفوع'},
  'f_active_contracts': {'en': 'Active contracts', 'ar': 'العقود النشطة'},
  'f_start_date_r': {'en': 'Start', 'ar': 'البداية'},
  'f_end_date_r': {'en': 'End', 'ar': 'النهاية'},

  // ---------------------------------------------------------------- contract form steps
  'step_info': {'en': 'Contract Info', 'ar': 'بيانات العقد'},
  'step_landlord': {'en': 'Landlord', 'ar': 'المالك'},
  'step_tenant': {'en': 'Tenant', 'ar': 'المستأجر'},
  'step_unit': {'en': 'Property & Unit', 'ar': 'العقار والوحدة'},
  'step_financial': {'en': 'Financial Terms', 'ar': 'الشروط المالية'},
  'step_conditions': {'en': 'Lease Conditions', 'ar': 'شروط الإيجار'},
  'step_handover': {'en': 'Handover & Inventory', 'ar': 'التسليم والجرد'},
  'step_witnesses': {'en': 'Witnesses & Signatures', 'ar': 'الشهود والتوقيعات'},

  // ---------------------------------------------------------------- options (o_*)
  'o_apartment_building': {'en': 'Apartment building', 'ar': 'عمارة سكنية'},
  'o_villa': {'en': 'Villa', 'ar': 'فيلا'},
  'o_commercial_building': {'en': 'Commercial building', 'ar': 'مبنى تجاري'},
  'o_mall': {'en': 'Mall', 'ar': 'مجمع تجاري'},
  'o_compound': {'en': 'Compound', 'ar': 'مجمع سكني'},
  'o_land': {'en': 'Land', 'ar': 'أرض'},
  'o_other': {'en': 'Other', 'ar': 'أخرى'},
  'o_available': {'en': 'Available', 'ar': 'متاحة'},
  'o_rented': {'en': 'Rented', 'ar': 'مؤجرة'},
  'o_maintenance': {'en': 'Maintenance', 'ar': 'صيانة'},
  'o_inactive': {'en': 'Inactive', 'ar': 'غير نشطة'},
  'o_active': {'en': 'Active', 'ar': 'نشط'},
  'o_apartment': {'en': 'Apartment', 'ar': 'شقة'},
  'o_studio': {'en': 'Studio', 'ar': 'استوديو'},
  'o_shop': {'en': 'Shop', 'ar': 'محل'},
  'o_office': {'en': 'Office', 'ar': 'مكتب'},
  'o_warehouse': {'en': 'Warehouse', 'ar': 'مستودع'},
  'o_parking': {'en': 'Parking', 'ar': 'موقف سيارات'},
  'o_furnished': {'en': 'Furnished', 'ar': 'مفروشة'},
  'o_semi_furnished': {'en': 'Semi-furnished', 'ar': 'نصف مفروشة'},
  'o_unfurnished': {'en': 'Unfurnished', 'ar': 'غير مفروشة'},
  'o_residential': {'en': 'Residential', 'ar': 'سكني'},
  'o_commercial': {'en': 'Commercial', 'ar': 'تجاري'},
  'o_draft': {'en': 'Draft', 'ar': 'مسودة'},
  'o_expired': {'en': 'Expired', 'ar': 'منتهي'},
  'o_terminated': {'en': 'Terminated', 'ar': 'مُنهى'},
  'o_cancelled': {'en': 'Cancelled', 'ar': 'ملغى'},
  'o_suspended': {'en': 'Suspended', 'ar': 'موقوف'},
  'o_unpaid': {'en': 'Unpaid', 'ar': 'غير مدفوع'},
  'o_partial': {'en': 'Partially paid', 'ar': 'مدفوع جزئياً'},
  'o_paid': {'en': 'Paid', 'ar': 'مدفوع بالكامل'},
  'o_overdue': {'en': 'Overdue', 'ar': 'متأخر'},
  'o_monthly': {'en': 'Monthly', 'ar': 'شهري'},
  'o_quarterly': {'en': 'Quarterly', 'ar': 'ربع سنوي'},
  'o_semi_annual': {'en': 'Semi-annually', 'ar': 'نصف سنوي'},
  'o_annual': {'en': 'Annually', 'ar': 'سنوي'},
  'o_custom': {'en': 'Custom', 'ar': 'مخصص'},
  'o_fixed': {'en': 'Fixed amount', 'ar': 'مبلغ ثابت'},
  'o_percentage': {'en': 'Percentage', 'ar': 'نسبة مئوية'},
  'o_daily': {'en': 'Daily amount', 'ar': 'مبلغ يومي'},
  'o_landlord': {'en': 'Landlord', 'ar': 'المالك'},
  'o_tenant': {'en': 'Tenant', 'ar': 'المستأجر'},
  'o_shared': {'en': 'Shared', 'ar': 'مشتركة'},
  'o_national_id': {'en': 'National ID', 'ar': 'الهوية الوطنية'},
  'o_passport': {'en': 'Passport', 'ar': 'جواز سفر'},
  'o_residence_permit': {'en': 'Residence permit', 'ar': 'رخصة إقامة'},
  'o_commercial_reg': {'en': 'Commercial registration', 'ar': 'سجل تجاري'},
  'o_cash': {'en': 'Cash', 'ar': 'نقداً'},
  'o_bank_transfer': {'en': 'Bank transfer', 'ar': 'تحويل بنكي'},
  'o_e_wallet': {'en': 'E-wallet', 'ar': 'محفظة إلكترونية'},
  'o_fixed_monthly': {'en': 'Fixed monthly', 'ar': 'تكلفة ثابتة شهرية'},
  'o_consumption': {'en': 'Based on consumption', 'ar': 'حسب الاستهلاك'},
  'o_one_time': {'en': 'One-time', 'ar': 'لمرة واحدة'},
  'o_direct': {'en': 'Direct to unit', 'ar': 'مباشر على الوحدة'},
  'o_equal': {'en': 'Split equally', 'ar': 'بالتساوي'},
  'o_male': {'en': 'Male', 'ar': 'ذكر'},
  'o_female': {'en': 'Female', 'ar': 'أنثى'},
  'o_property': {'en': 'Property', 'ar': 'عقار'},
  'o_unit': {'en': 'Unit', 'ar': 'وحدة'},
  'o_with_balance': {'en': 'Has balance', 'ar': 'لديه رصيد مستحق'},
};
