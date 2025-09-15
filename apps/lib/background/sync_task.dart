import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:cashier_app/services/sync_service.dart';
import 'package:cashier_app/data/remote/api_client.dart';
import 'package:cashier_app/services/token_storage.dart';

const String syncTaskName = 'periodicSync';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Load token from secure storage for authed sync
    final storage = TokenStorage();
    final token = await storage.read();
    final api = buildApiClient(token: token);
    final sync = SyncService(api);
    try {
      await sync.push();
      await sync.pull();
      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  });
}
