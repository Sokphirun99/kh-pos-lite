/// Build flavor configuration (dev/stg/prod) placeholder.
enum BuildFlavor { dev, stg, prod }

class EnvConfig {
  final BuildFlavor flavor;
  final String apiBaseUrl;

  const EnvConfig({required this.flavor, required this.apiBaseUrl});

  static const EnvConfig dev = EnvConfig(
    flavor: BuildFlavor.dev,
    apiBaseUrl: 'http://172.16.5.103:8080/api',
  );
}
