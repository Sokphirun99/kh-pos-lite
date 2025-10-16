import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sync_bloc.dart';

class ConnectivitySyncListener extends StatefulWidget {
  final Widget child;
  const ConnectivitySyncListener({super.key, required this.child});

  @override
  State<ConnectivitySyncListener> createState() =>
      _ConnectivitySyncListenerState();
}

class _ConnectivitySyncListenerState extends State<ConnectivitySyncListener> {
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        context.read<SyncBloc>().add(const SyncTriggered());
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
