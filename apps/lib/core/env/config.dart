/// Build flavor configuration (dev/stg/prod) placeholder.
enum BuildFlavor { dev, stg, prod }

class EnvConfig {
  final BuildFlavor flavor;
  final String apiBaseUrl;

  const EnvConfig({
    required this.flavor,
    required this.apiBaseUrl,
  });

  static const EnvConfig dev = EnvConfig(
    flavor: BuildFlavor.dev,
<<<<<<< HEAD
    apiBaseUrl: 'http://10.0.2.2:8080/api',
=======
    apiBaseUrl: String.fromEnvironment('DEV_API_BASE_URL', defaultValue: 'http://127.0.0.1:8000'),
>>>>>>> 717db89c69e9b566e752aa48dc90caa193504c12
  );
}

