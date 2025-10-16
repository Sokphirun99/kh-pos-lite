import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';
import 'package:cashier_app/features/settings/bloc/feature_flags_cubit.dart';
import 'package:cashier_app/l10n/app_localizations.dart';

class SyncBanner extends StatefulWidget {
  const SyncBanner({super.key});
  @override
  State<SyncBanner> createState() => _SyncBannerState();
}

class _SyncBannerState extends State<SyncBanner> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final online =
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);
      setState(() => _offline = !online);
    });
    Connectivity().checkConnectivity().then((results) {
      final online =
          (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi));
      if (mounted) setState(() => _offline = !online);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flags = context.watch<FeatureFlagsCubit>().state;
    if (!flags.showSyncBanner) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, sync) {
        Widget? chip;
        if (_offline) {
          chip = Chip(
            avatar: const Icon(Icons.wifi_off, size: 18),
            label: Text(l10n.offline),
          );
        } else if (sync.isSyncing) {
          chip = Chip(
            avatar: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: Text(l10n.settingsSyncing),
          );
        } else if (sync.error != null) {
          chip = Chip(
            avatar: const Icon(Icons.error, color: Colors.red, size: 18),
            label: Text(l10n.settingsSyncError(sync.error!)),
          );
        } else {
          chip = Chip(
            avatar: const Icon(Icons.check, color: Colors.green, size: 18),
            label: Text(l10n.allSynced),
          );
        }
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: chip,
          ),
        );
      },
    );
  }
}
