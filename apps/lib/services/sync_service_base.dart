import '../data/remote/api_client.dart';

abstract class SyncServiceBase {
  final ApiClient api;
  SyncServiceBase(this.api);

  Future<void> push();
  Future<void> pull();
}