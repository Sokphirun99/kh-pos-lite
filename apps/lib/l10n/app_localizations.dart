import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'KH POS Lite'**
  String get appTitle;

  /// No description provided for @tabItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get tabItems;

  /// No description provided for @tabCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get tabCustomers;

  /// No description provided for @tabInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get tabInvoices;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @itemsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemsSearchHint;

  /// No description provided for @itemsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Item Not Found'**
  String get itemsEmptyTitle;

  /// No description provided for @itemsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Item might be not in your list'**
  String get itemsEmptySubtitle;

  /// No description provided for @itemsCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create New Item'**
  String get itemsCreateButton;

  /// No description provided for @itemsSkuOnlyFilter.
  ///
  /// In en, this message translates to:
  /// **'Search SKU only'**
  String get itemsSkuOnlyFilter;

  /// No description provided for @itemsAdjustStockTooltip.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get itemsAdjustStockTooltip;

  /// No description provided for @itemsCreateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create Item'**
  String get itemsCreateTooltip;

  /// No description provided for @itemsStockChip.
  ///
  /// In en, this message translates to:
  /// **'Stock: {count}'**
  String itemsStockChip(Object count);

  /// No description provided for @itemsFormTitleCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Item'**
  String get itemsFormTitleCreate;

  /// No description provided for @itemsFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get itemsFormTitleEdit;

  /// No description provided for @itemsFormSectionBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get itemsFormSectionBasicInfo;

  /// No description provided for @itemsFormSectionNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get itemsFormSectionNote;

  /// No description provided for @itemsFormSectionImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get itemsFormSectionImage;

  /// No description provided for @itemsFieldName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemsFieldName;

  /// No description provided for @itemsFieldCode.
  ///
  /// In en, this message translates to:
  /// **'Item Code'**
  String get itemsFieldCode;

  /// No description provided for @itemsFieldUnitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit Cost (៛)'**
  String get itemsFieldUnitCost;

  /// No description provided for @itemsFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (៛)'**
  String get itemsFieldPrice;

  /// No description provided for @itemsFieldStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get itemsFieldStock;

  /// No description provided for @itemsFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write your note'**
  String get itemsFieldNoteHint;

  /// No description provided for @itemsAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get itemsAddImage;

  /// No description provided for @itemsPriceValidation.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than or equal to the unit cost'**
  String get itemsPriceValidation;

  /// No description provided for @itemsSkuExists.
  ///
  /// In en, this message translates to:
  /// **'SKU already exists'**
  String get itemsSkuExists;

  /// No description provided for @itemsSkuFormat.
  ///
  /// In en, this message translates to:
  /// **'Use 3-32 characters: letters, digits, _ or -'**
  String get itemsSkuFormat;

  /// No description provided for @customersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name, Phone'**
  String get customersSearchHint;

  /// No description provided for @customersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Not Found'**
  String get customersEmptyTitle;

  /// No description provided for @customersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customer might be not in your list'**
  String get customersEmptySubtitle;

  /// No description provided for @customersCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create New Customer'**
  String get customersCreateButton;

  /// No description provided for @customersCreateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create Customer'**
  String get customersCreateTooltip;

  /// No description provided for @customersFormTitleCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Customer'**
  String get customersFormTitleCreate;

  /// No description provided for @customersFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get customersFormTitleEdit;

  /// No description provided for @customersSectionBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get customersSectionBasicInfo;

  /// No description provided for @customersSectionAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get customersSectionAddress;

  /// No description provided for @customersSectionNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get customersSectionNote;

  /// No description provided for @customersFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get customersFieldFullName;

  /// No description provided for @customersFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get customersFieldPhone;

  /// No description provided for @customersFieldAltPhone.
  ///
  /// In en, this message translates to:
  /// **'Alternative Phone'**
  String get customersFieldAltPhone;

  /// No description provided for @customersFieldVatTin.
  ///
  /// In en, this message translates to:
  /// **'VAT TIN'**
  String get customersFieldVatTin;

  /// No description provided for @customersFieldAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get customersFieldAddressHint;

  /// No description provided for @customersFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write your note'**
  String get customersFieldNoteHint;

  /// No description provided for @customersVatLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get customersVatLabel;

  /// No description provided for @customersPrivacyHint.
  ///
  /// In en, this message translates to:
  /// **"We respect your customers' privacy and never share their details."**
  String get customersPrivacyHint;

  /// No description provided for @customersDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted'**
  String get customersDeleted;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @formRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get formRequired;

  /// No description provided for @formNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Must be zero or greater'**
  String get formNonNegative;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageKm.
  ///
  /// In en, this message translates to:
  /// **'Khmer'**
  String get settingsLanguageKm;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get settingsSyncNow;

  /// No description provided for @settingsSyncIdle.
  ///
  /// In en, this message translates to:
  /// **'Sync idle'**
  String get settingsSyncIdle;

  /// No description provided for @settingsSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get settingsSyncing;

  /// No description provided for @settingsSyncError.
  ///
  /// In en, this message translates to:
  /// **'Sync error: {message}'**
  String settingsSyncError(Object message);

  /// No description provided for @settingsSyncDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get settingsSyncDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get noProducts;

  /// No description provided for @noSales.
  ///
  /// In en, this message translates to:
  /// **'No sales'**
  String get noSales;

  /// No description provided for @salesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a sale to start tracking payments.'**
  String get salesEmptyDescription;

  /// No description provided for @noPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments'**
  String get noPayments;

  /// No description provided for @lastSyncAt.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {time}'**
  String lastSyncAt(Object time);

  /// No description provided for @settingsShowSyncBanner.
  ///
  /// In en, this message translates to:
  /// **'Show sync banner'**
  String get settingsShowSyncBanner;

  /// No description provided for @settingsEnableBatchSync.
  ///
  /// In en, this message translates to:
  /// **'Enable batch sync'**
  String get settingsEnableBatchSync;

  /// No description provided for @settingsBatchSize.
  ///
  /// In en, this message translates to:
  /// **'Batch size'**
  String get settingsBatchSize;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutDbVersion.
  ///
  /// In en, this message translates to:
  /// **'DB version'**
  String get aboutDbVersion;

  /// No description provided for @aboutAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get aboutAppVersion;

  /// No description provided for @aboutLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get aboutLastSync;

  /// No description provided for @aboutQaParams.
  ///
  /// In en, this message translates to:
  /// **'QA params'**
  String get aboutQaParams;

  /// No description provided for @aboutCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get aboutCopied;

  /// No description provided for @aboutResetLocalDb.
  ///
  /// In en, this message translates to:
  /// **'Reset local data'**
  String get aboutResetLocalDb;

  /// No description provided for @aboutResetLocalDbHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press to reset'**
  String get aboutResetLocalDbHint;

  /// No description provided for @aboutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm reset'**
  String get aboutConfirmTitle;

  /// No description provided for @aboutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete local data. Continue?'**
  String get aboutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @aboutResetDone.
  ///
  /// In en, this message translates to:
  /// **'Local data cleared'**
  String get aboutResetDone;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get checkoutTotal;

  /// No description provided for @checkoutCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get checkoutCash;

  /// No description provided for @checkoutTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get checkoutTransfer;

  /// No description provided for @checkoutAmountReceived.
  ///
  /// In en, this message translates to:
  /// **'Amount received (៛)'**
  String get checkoutAmountReceived;

  /// No description provided for @checkoutChangeDue.
  ///
  /// In en, this message translates to:
  /// **'Change due'**
  String get checkoutChangeDue;

  /// No description provided for @checkoutRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get checkoutRemaining;

  /// No description provided for @checkoutCompleteSale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get checkoutCompleteSale;

  /// No description provided for @saleCompletedChange.
  ///
  /// In en, this message translates to:
  /// **'Sale completed. Change: {amount}'**
  String saleCompletedChange(Object amount);

  /// No description provided for @saleCompletedRemaining.
  ///
  /// In en, this message translates to:
  /// **'Sale recorded. Remaining: {amount}'**
  String saleCompletedRemaining(Object amount);

  /// No description provided for @salesAppBarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor customer payments and balances'**
  String get salesAppBarSubtitle;

  /// No description provided for @receivePayment.
  ///
  /// In en, this message translates to:
  /// **'Receive Payment'**
  String get receivePayment;

  /// No description provided for @salesSummaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total sales'**
  String get salesSummaryTotal;

  /// No description provided for @salesSummaryOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding balance'**
  String get salesSummaryOutstanding;

  /// No description provided for @salesSummaryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Paid in full'**
  String get salesSummaryCompleted;

  /// No description provided for @salesCardTotal.
  ///
  /// In en, this message translates to:
  /// **'Sale total'**
  String get salesCardTotal;

  /// No description provided for @salesStatusOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get salesStatusOutstanding;

  /// No description provided for @salesViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get salesViewDetails;

  /// No description provided for @salesDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete sale'**
  String get salesDeleteTooltip;

  /// No description provided for @salesNewSale.
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get salesNewSale;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @saleDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale Details'**
  String get saleDetailsTitle;

  /// No description provided for @saleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sale not found'**
  String get saleNotFound;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @settingsKhqrTitle.
  ///
  /// In en, this message translates to:
  /// **'Static KHQR'**
  String get settingsKhqrTitle;

  /// No description provided for @settingsUploadKhqr.
  ///
  /// In en, this message translates to:
  /// **'Upload KHQR PNG'**
  String get settingsUploadKhqr;

  /// No description provided for @settingsRemoveKhqr.
  ///
  /// In en, this message translates to:
  /// **'Remove KHQR'**
  String get settingsRemoveKhqr;

  /// No description provided for @settingsKhqrNotSet.
  ///
  /// In en, this message translates to:
  /// **'No KHQR uploaded'**
  String get settingsKhqrNotSet;

  /// No description provided for @checkoutTxReference.
  ///
  /// In en, this message translates to:
  /// **'Transfer reference (optional)'**
  String get checkoutTxReference;

  /// No description provided for @checkoutScanKhqr.
  ///
  /// In en, this message translates to:
  /// **'Ask customer to scan this KHQR'**
  String get checkoutScanKhqr;

  /// No description provided for @txRefLabel.
  ///
  /// In en, this message translates to:
  /// **'Ref: {ref}'**
  String txRefLabel(Object ref);

  /// No description provided for @settingsLowStockThreshold.
  ///
  /// In en, this message translates to:
  /// **'Low stock threshold'**
  String get settingsLowStockThreshold;

  /// No description provided for @adjustStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get adjustStockTitle;

  /// No description provided for @stockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockLabel;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @setStock.
  ///
  /// In en, this message translates to:
  /// **'Set Stock'**
  String get setStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowStock;

  /// No description provided for @insufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Insufficient stock'**
  String get insufficientStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @notEnoughStockFor.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock for {name}. Available: {qty}'**
  String notEnoughStockFor(Object name, Object qty);

  /// No description provided for @settingsAllowOversell.
  ///
  /// In en, this message translates to:
  /// **'Allow oversell (warn only)'**
  String get settingsAllowOversell;

  /// No description provided for @exceedsStock.
  ///
  /// In en, this message translates to:
  /// **'Exceeds stock'**
  String get exceedsStock;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @pairPrinter.
  ///
  /// In en, this message translates to:
  /// **'Pair Printer'**
  String get pairPrinter;

  /// No description provided for @printingStarted.
  ///
  /// In en, this message translates to:
  /// **'Printing...'**
  String get printingStarted;

  /// No description provided for @printingDone.
  ///
  /// In en, this message translates to:
  /// **'Printed'**
  String get printingDone;

  /// No description provided for @printingFailed.
  ///
  /// In en, this message translates to:
  /// **'Printing failed'**
  String get printingFailed;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @printBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Print (58mm Bluetooth)'**
  String get printBluetooth;

  /// No description provided for @sendTelegram.
  ///
  /// In en, this message translates to:
  /// **'Send to Telegram'**
  String get sendTelegram;

  /// No description provided for @telegramNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Telegram is not configured'**
  String get telegramNotConfigured;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @voidSale.
  ///
  /// In en, this message translates to:
  /// **'Void/Cancel sale'**
  String get voidSale;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @allSynced.
  ///
  /// In en, this message translates to:
  /// **'All synced'**
  String get allSynced;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @khqr.
  ///
  /// In en, this message translates to:
  /// **'KHQR'**
  String get khqr;

  /// No description provided for @scanDevices.
  ///
  /// In en, this message translates to:
  /// **'Scan devices'**
  String get scanDevices;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFound;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select device'**
  String get tapToSelect;

  /// No description provided for @testPrint.
  ///
  /// In en, this message translates to:
  /// **'Test Print'**
  String get testPrint;

  /// No description provided for @unpair.
  ///
  /// In en, this message translates to:
  /// **'Unpair'**
  String get unpair;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
