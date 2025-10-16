import 'sync_service_base.dart';
import '../data/remote/api_client.dart';

/// Web-compatible implementation of SyncService
///
/// This is a platform-specific implementation for web browsers.
/// Unlike the mobile version that uses local database synchronization,
/// the web version operates directly through REST API calls.
///
/// All sync operations are currently no-ops as the web platform
/// typically doesn't require offline-first synchronization.
class SyncService extends SyncServiceBase {
  /// Creates a new web sync service instance
  ///
  /// [api] - The API client for making HTTP requests
  SyncService(ApiClient api) : super(api);

  @override
  Future<void> push() async {
    // No-op for web platform
    // Web applications typically send data directly via API calls
    // rather than using background synchronization
  }

  @override
  Future<void> pull() async {
    // No-op for web platform
    // Web applications typically fetch data on-demand
    // rather than pre-synchronizing for offline use
  }

  /// Performs bidirectional synchronization
  ///
  /// For web platform, this is currently a no-op since
  /// synchronization is typically handled directly through API calls
  Future<void> sync() async {
    // No-op for web platform
  }
}
