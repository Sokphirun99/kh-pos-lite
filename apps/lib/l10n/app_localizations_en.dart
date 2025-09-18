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
  String get tabProducts => 'Products';

  @override
  String get tabSales => 'Sales';

  @override
  String get tabPayments => 'Payments';

  @override
  String get tabReports => 'Reports';

  @override
  String get tabSettings => 'Settings';

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
  String get salesEmptyDescription => 'Create a sale to start tracking payments.';

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
  String get salesAppBarSubtitle => 'Monitor customer payments and balances';

  @override
  String get receivePayment => 'Receive Payment';

  @override
  String get salesSummaryTotal => 'Total sales';

  @override
  String get salesSummaryOutstanding => 'Outstanding balance';

  @override
  String get salesSummaryCompleted => 'Paid in full';

  @override
  String get salesCardTotal => 'Sale total';

  @override
  String get salesStatusOutstanding => 'Outstanding';

  @override
  String get salesViewDetails => 'View details';

  @override
  String get salesDeleteTooltip => 'Delete sale';

  @override
  String get salesNewSale => 'New sale';

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
