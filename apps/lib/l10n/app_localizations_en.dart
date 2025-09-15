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
  String get noPayments => 'No payments';

  @override
  String lastSyncAt(Object time) {
    return 'Last sync: $time';
  }
}
