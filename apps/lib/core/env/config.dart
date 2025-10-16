/// Build flavor configuration (dev/stg/prod) placeholder.
enum BuildFlavor { dev, stg, prod }

class EnvConfig {
  final BuildFlavor flavor;
  final String apiBaseUrl;
  final bool isOfflineOnly;

  const EnvConfig({
    required this.flavor, 
    required this.apiBaseUrl,
    this.isOfflineOnly = false,
  });

  static const EnvConfig dev = EnvConfig(
    flavor: BuildFlavor.dev,
    apiBaseUrl: 'https://dev.example.com/api',
    isOfflineOnly: false,
  );

  static const EnvConfig prod = EnvConfig(
    flavor: BuildFlavor.prod,
    apiBaseUrl: '', // No API needed for offline mode
    isOfflineOnly: true,
  );

  /// Get current environment based on build flavor or dart-define
  static EnvConfig get current {
    const String mode = String.fromEnvironment('BUILD_MODE', defaultValue: 'dev');
    switch (mode) {
      case 'prod':
      case 'offline':
        return prod;
      default:
        return dev;
    }
  }
}
