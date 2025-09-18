// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'ខេអេច ភאָס លាយទ៍';

  @override
  String get tabItems => 'ទំនិញ';

  @override
  String get tabCustomers => 'អតិថិជន';

  @override
  String get tabInvoices => 'វិក្កយបត្រ';

  @override
  String get tabSettings => 'ការកំណត់';

  @override
  String get itemsSearchHint => 'ឈ្មោះទំនិញ';

  @override
  String get itemsEmptyTitle => 'រកមិនឃើញទំនិញ';

  @override
  String get itemsEmptySubtitle => 'ទំនិញអាចមិនមានក្នុងបញ្ជីរបស់អ្នក';

  @override
  String get itemsCreateButton => 'បង្កើតទំនិញថ្មី';

  @override
  String get itemsSkuOnlyFilter => 'ស្វែងរកតាម SKU ប៉ុណ្ណោះ';

  @override
  String get itemsAdjustStockTooltip => 'កែតម្រូវស្តុក';

  @override
  String get itemsCreateTooltip => 'បង្កើតទំនិញ';

  @override
  String itemsStockChip(Object count) {
    return 'ស្តុក: $count';
  }

  @override
  String get itemsFormTitleCreate => 'បង្កើតទំនិញ';

  @override
  String get itemsFormTitleEdit => 'កែប្រែទំនិញ';

  @override
  String get itemsFormSectionBasicInfo => 'ព័ត៍មានមូលដ្ឋាន';

  @override
  String get itemsFormSectionNote => 'កំណត់ចំណាំ';

  @override
  String get itemsFormSectionImage => 'រូបភាព';

  @override
  String get itemsFieldName => 'ឈ្មោះទំនិញ';

  @override
  String get itemsFieldCode => 'កូដទំនិញ';

  @override
  String get itemsFieldUnitCost => 'តម្លៃដើម (៛)';

  @override
  String get itemsFieldPrice => 'តម្លៃលក់ (៛)';

  @override
  String get itemsFieldStock => 'ស្តុក';

  @override
  String get itemsFieldNoteHint => 'សរសេរកំណត់ចំណាំរបស់អ្នក';

  @override
  String get itemsAddImage => 'បន្ថែមរូបភាព';

  @override
  String get itemsPriceValidation => 'តម្លៃលក់ត្រូវតែធំជាងឬស្មើតម្លៃដើម';

  @override
  String get itemsSkuExists => 'SKU នេះមានរួចហើយ';

  @override
  String get itemsSkuFormat => 'ប្រើតួអក្សរ 3-32: អក្សរ លេខ _ ឬ -';

  @override
  String get customersSearchHint => 'ឈ្មោះ, ទូរស័ព្ទ';

  @override
  String get customersEmptyTitle => 'រកមិនឃើញអតិថិជន';

  @override
  String get customersEmptySubtitle => 'អតិថិជនអាចមិនមានក្នុងបញ្ជីរបស់អ្នក';

  @override
  String get customersCreateButton => 'បង្កើតអតិថិជនថ្មី';

  @override
  String get customersCreateTooltip => 'បង្កើតអតិថិជន';

  @override
  String get customersFormTitleCreate => 'បង្កើតអតិថិជន';

  @override
  String get customersFormTitleEdit => 'កែប្រែអតិថិជន';

  @override
  String get customersSectionBasicInfo => 'ព័ត៍មានមូលដ្ឋាន';

  @override
  String get customersSectionAddress => 'អាសយដ្ឋាន';

  @override
  String get customersSectionNote => 'កំណត់ចំណាំ';

  @override
  String get customersFieldFullName => 'ឈ្មោះពេញ';

  @override
  String get customersFieldPhone => 'ទូរស័ព្ទ';

  @override
  String get customersFieldAltPhone => 'ទូរស័ព្ទបន្ថែម';

  @override
  String get customersFieldVatTin => 'លេខ VAT';

  @override
  String get customersFieldAddressHint => 'អាសយដ្ឋាន';

  @override
  String get customersFieldNoteHint => 'សរសេរកំណត់ចំណាំរបស់អ្នក';

  @override
  String get customersVatLabel => 'VAT';

  @override
  String get customersPrivacyHint => 'យើងគោរពភាពឯកជនរបស់អតិថិជន ហើយមិនចែករំលែកទិន្នន័យរបស់ពួកគេទេ។';

  @override
  String get customersDeleted => 'បានលុបអតិថិជន';

  @override
  String get commonDone => 'រួចរាល់';

  @override
  String get formRequired => 'ត្រូវការ';

  @override
  String get formNonNegative => 'ត្រូវតែធំជាងឬស្មើសូន្យ';

  @override
  String get loginTitle => 'ចូលប្រើ';

  @override
  String get loginSignIn => 'ចូលប្រើ';

  @override
  String get settingsLanguage => 'ភាសា';

  @override
  String get settingsLanguageKm => 'ខ្មែរ';

  @override
  String get settingsLanguageEn => 'អង់គ្លេស';

  @override
  String get settingsDarkMode => 'របៀបងងឹត';

  @override
  String get settingsGeneralSection => 'កន្លែងធ្វើការ';

  @override
  String get settingsGeneralSectionSubtitle => 'គ្រប់គ្រងព័ត៌មានសម្គាល់ និងស្ថានភាពសមកាលកម្ម។';

  @override
  String get settingsSyncNow => 'សមកាលកម្មឥឡូវនេះ';

  @override
  String get settingsSyncIdle => 'កំពុងសម្រាកសមកាលកម្ម';

  @override
  String get settingsSyncing => 'កំពុងសមកាលកម្ម...';

  @override
  String settingsSyncError(Object message) {
    return 'កំហុសសមកាលកម្ម: $message';
  }

  @override
  String get settingsSyncDeleted => 'បានលុប';

  @override
  String get undo => 'មិនធ្វើវិញ';

  @override
  String get noProducts => 'គ្មានផលិតផល';

  @override
  String get noSales => 'គ្មានការលក់';

  @override
  String get salesEmptyDescription => 'បង្កើតការលក់ដើម្បីចាប់ផ្តើមតាមដានការទូទាត់។';

  @override
  String get noPayments => 'គ្មានការទូទាត់';

  @override
  String lastSyncAt(Object time) {
    return 'សមកាលកម្មចុងក្រោយ: $time';
  }

  @override
  String get settingsShowSyncBanner => 'បង្ហាញបន្ទះសមកាលកម្ម';

  @override
  String get settingsEnableBatchSync => 'អនុញ្ញាតសមកាលកម្មជាក្បាល';

  @override
  String get settingsBatchSize => 'ទំហំក្បាល';

  @override
  String settingsBatchSizeHint(Object size) {
    return 'ដំណើរការ $size វិក័យប័ត្រក្នុងមួយក្បាល';
  }

  @override
  String get settingsPreferencesSection => 'ចំណូលចិត្ត';

  @override
  String get settingsPreferencesSectionSubtitle => 'ប្ដូររបៀបដែលកម្មវិធីមើលទៅ និងមានអារម្មណ៍។';

  @override
  String get settingsSyncSection => 'សមកាលកម្មស្វ័យប្រវត្តិ';

  @override
  String get settingsSyncSectionSubtitle => 'លៃតម្រូវសមកាលកម្មជាក្បាល និងការពារស្តុក។';

  @override
  String get aboutTitle => 'អំពីកម្មវិធី';

  @override
  String get aboutDbVersion => 'កំណែនៃមូលដ្ឋានទិន្នន័យ';

  @override
  String get aboutAppVersion => 'កំណែនៃកម្មវិធី';

  @override
  String get aboutLastSync => 'សមកាលកម្មចុងក្រោយ';

  @override
  String get aboutQaParams => 'ប៉ារ៉ាម៉ែត្រ QA';

  @override
  String get aboutCopied => 'បានចម្លង';

  @override
  String get aboutResetLocalDb => 'សម្អាតទិន្នន័យមូលដ្ឋាន';

  @override
  String get aboutResetLocalDbHint => 'ចុចសង្កត់ដើម្បីសម្អាត';

  @override
  String get aboutConfirmTitle => 'បញ្ជាក់ទៅកាន់ការសម្អាត';

  @override
  String get aboutConfirmMessage => 'នេះនឹងលុបទិន្នន័យក្នុងឧបករណ៍។ បន្តឬ?';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get ok => 'យល់ព្រម';

  @override
  String get error => 'កំហុស';

  @override
  String get aboutResetDone => 'Local data cleared';

  @override
  String get checkoutTitle => 'គិតលុយ';

  @override
  String get checkoutTotal => 'សរុប';

  @override
  String get checkoutCash => 'សាច់ប្រាក់';

  @override
  String get checkoutTransfer => 'ផ្ទេរលុយ';

  @override
  String get checkoutAmountReceived => 'ប្រាក់បានទទួល (៛)';

  @override
  String get checkoutChangeDue => 'ប្រាក់អាប់';

  @override
  String get checkoutRemaining => 'ប្រាក់នៅខ្វះ';

  @override
  String get checkoutCompleteSale => 'បញ្ចប់ការលក់';

  @override
  String saleCompletedChange(Object amount) {
    return 'បានបញ្ចប់ការលក់។ ប្រាក់អាប់: $amount';
  }

  @override
  String saleCompletedRemaining(Object amount) {
    return 'បានកត់ត្រាការលក់។ ប្រាក់នៅខ្វះ: $amount';
  }

  @override
  String get salesAppBarSubtitle => 'តាមដានការទូទាត់ និងសមតុល្យអតិថិជន';

  @override
  String get receivePayment => 'ទទួលការទូទាត់';

  @override
  String get salesSummaryTotal => 'ទឹកប្រាក់លក់សរុប';

  @override
  String get salesSummaryOutstanding => 'ទឹកប្រាក់នៅសល់';

  @override
  String get salesSummaryCompleted => 'បានទូទាត់ពេញលេញ';

  @override
  String get salesCardTotal => 'តម្លៃការលក់';

  @override
  String get salesStatusOutstanding => 'នៅខ្វះ';

  @override
  String get salesViewDetails => 'មើលលម្អិត';

  @override
  String get salesDeleteTooltip => 'លុបការលក់';

  @override
  String get salesNewSale => 'ការលក់ថ្មី';

  @override
  String get balance => 'សមតុល្យ';

  @override
  String get saleDetailsTitle => 'ព័ត៌មានលម្អិតអំពីការលក់';

  @override
  String get saleNotFound => 'រកមិនឃើញការលក់';

  @override
  String get paid => 'បានទូទាត់';

  @override
  String get settingsKhqrTitle => 'KHQR ថេរ';

  @override
  String get settingsUploadKhqr => 'ផ្ទុកឡើងរូបភាព KHQR';

  @override
  String get settingsRemoveKhqr => 'លុប KHQR';

  @override
  String get settingsKhqrNotSet => 'មិនទាន់មាន KHQR';

  @override
  String get checkoutTxReference => 'លេខយោងផ្ទេរ (ស្រេចចិត្ត)';

  @override
  String get checkoutScanKhqr => 'អញ្ជើញអតិថិជនស្កេន KHQR នេះ';

  @override
  String txRefLabel(Object ref) {
    return 'លេខយោង: $ref';
  }

  @override
  String get settingsLowStockThreshold => 'កម្រិតស្តុកទាប';

  @override
  String settingsLowStockThresholdDescription(Object threshold) {
    return 'ជូនដំណឹងនៅពេលស្តុកទាបជាង $threshold';
  }

  @override
  String get adjustStockTitle => 'កែតម្រូវស្តុក';

  @override
  String get stockLabel => 'ស្តុក';

  @override
  String get decrease => 'បន្ថយ';

  @override
  String get increase => 'បន្ថែម';

  @override
  String get setStock => 'កំណត់ស្តុក';

  @override
  String get lowStock => 'ស្តុកតិច';

  @override
  String get insufficientStock => 'ស្តុកមិនគ្រប់គ្រាន់';

  @override
  String get outOfStock => 'អស់ស្តុក';

  @override
  String notEnoughStockFor(Object name, Object qty) {
    return 'ស្តុកមិនគ្រប់សម្រាប់ $name។ នៅសល់: $qty';
  }

  @override
  String get settingsAllowOversell => 'អនុញ្ញាតលក់លើស (ព្រមានតែប៉ុណ្ណោះ)';

  @override
  String get settingsReceiptSection => 'ម៉ាកវិក្កយបត្រ';

  @override
  String get settingsReceiptSectionSubtitle => 'ប្ដូររូបរាងហាងលើវិក្កយបត្រ។';

  @override
  String get settingsPaymentSection => 'ការរួមបញ្ចូលការទូទាត់';

  @override
  String get settingsPaymentSectionSubtitle => 'ចែករំលែក KHQR និងភ្ជាប់បុត Telegram។';

  @override
  String get settingsDangerZone => 'តំបន់គ្រោះថ្នាក់';

  @override
  String get settingsDangerZoneSubtitle => 'ចាកចេញពីឧបករណ៍នេះ។';

  @override
  String get exceedsStock => 'លើសស្តុក';

  @override
  String get receipt => 'វិក្កយបត្រ';

  @override
  String get print => 'បោះពុម្ព';

  @override
  String get share => 'ចែករំលែក';

  @override
  String get pairPrinter => 'ភ្ជាប់ម៉ាស៊ីនបោះពុម្ព';

  @override
  String get printingStarted => 'កំពុងបោះពុម្ព...';

  @override
  String get printingDone => 'បានបោះពុម្ព';

  @override
  String get printingFailed => 'បោះពុម្ពបរាជ័យ';

  @override
  String get sharePdf => 'ចែករំលែក PDF';

  @override
  String get printBluetooth => 'បោះពុម្ព (ម៉ាស៊ីន 58mm)';

  @override
  String get sendTelegram => 'ផ្ញើទៅ Telegram';

  @override
  String get telegramNotConfigured => 'មិនទាន់កំណត់ Telegram';

  @override
  String get discount => 'បញ្ចុះតម្លៃ';

  @override
  String get voidSale => 'លុបបោះបង់';

  @override
  String get offline => 'ក្រៅបណ្តាញ';

  @override
  String get allSynced => 'បានសមកាលកម្ម';

  @override
  String get errorGeneric => 'មានបញ្ហា សូមព្យាយាមម្ដងទៀត';

  @override
  String get khqr => 'KHQR';

  @override
  String get scanDevices => 'ស្កេនឧបករណ៍';

  @override
  String get scanning => 'កំពុងស្កេន...';

  @override
  String get noDevicesFound => 'រកមិនឃើញឧបករណ៍';

  @override
  String get tapToSelect => 'ចុចដើម្បីជ្រើសរើស';

  @override
  String get testPrint => 'បោះពុម្ពសាកល្បង';

  @override
  String get unpair => 'ផ្ដាច់ការភ្ជាប់';
}
