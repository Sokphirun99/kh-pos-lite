// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KH POS Lite';

  @override
  String get tabItems => 'Items';

  @override
  String get tabCustomers => 'Customers';

  @override
  String get tabInvoices => 'Invoices';

  @override
  String get tabSettings => 'Settings';

  @override
  String get itemsSearchHint => 'Item Name';

  @override
  String get itemsEmptyTitle => 'Item Not Found';

  @override
  String get itemsEmptySubtitle => 'Item might be not in your list';

  @override
  String get itemsCreateButton => 'Create New Item';

  @override
  String get itemsSkuOnlyFilter => 'Search SKU only';

  @override
  String get itemsAdjustStockTooltip => 'Adjust Stock';

  @override
  String get itemsCreateTooltip => 'Create Item';

  @override
  String itemsStockChip(Object count) {
    return 'Stock: $count';
  }

  @override
  String get itemsFormTitleCreate => 'Create Item';

  @override
  String get itemsFormTitleEdit => 'Edit Item';

  @override
  String get itemsFormSectionBasicInfo => 'Basic Info';

  @override
  String get itemsFormSectionNote => 'Note';

  @override
  String get itemsFormSectionImage => 'Image';

  @override
  String get itemsFieldName => 'Item Name';

  @override
  String get itemsFieldCode => 'Item Code';

  @override
  String get itemsFieldUnitCost => 'Unit Cost (៛)';

  @override
  String get itemsFieldPrice => 'Price (៛)';

  @override
  String get itemsFieldStock => 'Stock';

  @override
  String get itemsFieldNoteHint => 'Write your note';

  @override
  String get itemsAddImage => 'Add Image';

  @override
  String get itemsPriceValidation => 'Price must be greater than or equal to the unit cost';

  @override
  String get itemsSkuExists => 'SKU already exists';

  @override
  String get itemsSkuFormat => 'Use 3-32 characters: letters, digits, _ or -';

  @override
  String get customersSearchHint => 'Name, Phone';

  @override
  String get customersEmptyTitle => 'Customer Not Found';

  @override
  String get customersEmptySubtitle => 'Customer might be not in your list';

  @override
  String get customersCreateButton => 'Create New Customer';

  @override
  String get customersCreateTooltip => 'Create Customer';

  @override
  String get customersFormTitleCreate => 'Create Customer';

  @override
  String get customersFormTitleEdit => 'Edit Customer';

  @override
  String get customersSectionBasicInfo => 'Basic Info';

  @override
  String get customersSectionAddress => 'Address';

  @override
  String get customersSectionNote => 'Note';

  @override
  String get customersFieldFullName => 'Full Name';

  @override
  String get customersFieldPhone => 'Phone';

  @override
  String get customersFieldAltPhone => 'Alternative Phone';

  @override
  String get customersFieldVatTin => 'VAT TIN';

  @override
  String get customersFieldAddressHint => 'Address';

  @override
  String get customersFieldNoteHint => 'Write your note';

  @override
  String get customersVatLabel => 'VAT';

  @override
  String get customersPrivacyHint => "We respect your customers' privacy and never share their details.";

  @override
  String get customersDeleted => 'Customer deleted';

  @override
  String get commonDone => 'Done';

  @override
  String get formRequired => 'Required';

  @override
  String get formNonNegative => 'Must be zero or greater';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageKm => 'Khmer';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsSyncNow => 'Sync now';

  @override
  String get settingsSyncIdle => 'Sync idle';

  @override
  String get settingsSyncing => 'Syncing...';

  @override
  String settingsSyncError(Object message) {
    return 'Sync error: $message';
  }

  @override
  String get settingsSyncDeleted => 'Deleted';

  @override
  String get undo => 'UNDO';

  @override
  String get noProducts => 'No products';

  @override
  String get noSales => 'No sales';

  @override
  String get noPayments => 'No payments';

  @override
  String lastSyncAt(Object time) {
    return 'Last sync: $time';
  }

  @override
  String get settingsShowSyncBanner => 'Show sync banner';

  @override
  String get settingsEnableBatchSync => 'Enable batch sync';

  @override
  String get settingsBatchSize => 'Batch size';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutDbVersion => 'DB version';

  @override
  String get aboutAppVersion => 'App version';

  @override
  String get aboutLastSync => 'Last sync';

  @override
  String get aboutQaParams => 'QA params';

  @override
  String get aboutCopied => 'Copied';

  @override
  String get aboutResetLocalDb => 'Reset local data';

  @override
  String get aboutResetLocalDbHint => 'Long-press to reset';

  @override
  String get aboutConfirmTitle => 'Confirm reset';

  @override
  String get aboutConfirmMessage => 'This will delete local data. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get aboutResetDone => 'Local data cleared';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutTotal => 'Total';

  @override
  String get checkoutCash => 'Cash';

  @override
  String get checkoutTransfer => 'Transfer';

  @override
  String get checkoutAmountReceived => 'Amount received (៛)';

  @override
  String get checkoutChangeDue => 'Change due';

  @override
  String get checkoutRemaining => 'Remaining';

  @override
  String get checkoutCompleteSale => 'Complete Sale';

  @override
  String saleCompletedChange(Object amount) {
    return 'Sale completed. Change: $amount';
  }

  @override
  String saleCompletedRemaining(Object amount) {
    return 'Sale recorded. Remaining: $amount';
  }

  @override
  String get receivePayment => 'Receive Payment';

  @override
  String get balance => 'Balance';

  @override
  String get saleDetailsTitle => 'Sale Details';

  @override
  String get saleNotFound => 'Sale not found';

  @override
  String get paid => 'Paid';

  @override
  String get settingsKhqrTitle => 'Static KHQR';

  @override
  String get settingsUploadKhqr => 'Upload KHQR PNG';

  @override
  String get settingsRemoveKhqr => 'Remove KHQR';

  @override
  String get settingsKhqrNotSet => 'No KHQR uploaded';

  @override
  String get checkoutTxReference => 'Transfer reference (optional)';

  @override
  String get checkoutScanKhqr => 'Ask customer to scan this KHQR';

  @override
  String txRefLabel(Object ref) {
    return 'Ref: $ref';
  }

  @override
  String get settingsLowStockThreshold => 'Low stock threshold';

  @override
  String get adjustStockTitle => 'Adjust Stock';

  @override
  String get stockLabel => 'Stock';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String get setStock => 'Set Stock';

  @override
  String get lowStock => 'Low';

  @override
  String get insufficientStock => 'Insufficient stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String notEnoughStockFor(Object name, Object qty) {
    return 'Not enough stock for $name. Available: $qty';
  }

  @override
  String get settingsAllowOversell => 'Allow oversell (warn only)';

  @override
  String get exceedsStock => 'Exceeds stock';

  @override
  String get receipt => 'Receipt';

  @override
  String get print => 'Print';

  @override
  String get share => 'Share';

  @override
  String get pairPrinter => 'Pair Printer';

  @override
  String get printingStarted => 'Printing...';

  @override
  String get printingDone => 'Printed';

  @override
  String get printingFailed => 'Printing failed';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get printBluetooth => 'Print (58mm Bluetooth)';

  @override
  String get sendTelegram => 'Send to Telegram';

  @override
  String get telegramNotConfigured => 'Telegram is not configured';

  @override
  String get discount => 'Discount';

  @override
  String get voidSale => 'Void/Cancel sale';

  @override
  String get offline => 'Offline';

  @override
  String get allSynced => 'All synced';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get khqr => 'KHQR';

  @override
  String get scanDevices => 'Scan devices';

  @override
  String get scanning => 'Scanning...';

  @override
  String get noDevicesFound => 'No devices found';

  @override
  String get tapToSelect => 'Tap to select device';

  @override
  String get testPrint => 'Test Print';

  @override
  String get unpair => 'Unpair';
}
