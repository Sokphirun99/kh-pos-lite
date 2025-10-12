// Web-compatible stub for sync service
// This is a dummy implementation for web platform

import 'sync_service_base.dart';
import '../data/remote/api_client.dart';
import '../data/local/mappers/web_entity_mappers.dart';

class SyncService extends SyncServiceBase {
  SyncService(ApiClient api) : super(api);

  @override
  Future<void> push() async {
    // No-op for web - could be implemented with REST API directly
    // The web mappers are available if needed for API sync
  }

  @override
  Future<void> pull() async {
    // No-op for web - could be implemented with REST API directly  
  }

  Future<void> sync() async {
    // No-op for web
  }
}