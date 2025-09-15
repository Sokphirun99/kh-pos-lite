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
  String get tabProducts => 'ផលិតផល';

  @override
  String get tabSales => 'លក់';

  @override
  String get tabPayments => 'ការទូទាត់';

  @override
  String get tabReports => 'របាយការណ៍';

  @override
  String get tabSettings => 'ការកំណត់';

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
  String get noPayments => 'គ្មានការទូទាត់';

  @override
  String lastSyncAt(Object time) {
    return 'សមកាលកម្មចុងក្រោយ: $time';
  }
}
