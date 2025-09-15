import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reports_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cashier_app/features/settings/bloc/feature_flags_cubit.dart';
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          BlocBuilder<FeatureFlagsCubit, FeatureFlagsState>(
            builder: (context, flags) => flags.showSyncBanner
                ? BlocBuilder<SyncBloc, SyncState>(
                    builder: (context, sync) {
                      final l10n = AppLocalizations.of(context);
                      if (sync.isSyncing) {
                        return ListTile(leading: const Icon(Icons.sync), title: Text(l10n?.settingsSyncing ?? 'Syncing...'));
                      }
                      if (sync.error != null) {
                        return ListTile(leading: const Icon(Icons.error, color: Colors.red), title: Text(l10n?.settingsSyncError(sync.error!) ?? 'Sync error: ${sync.error}'));
                      }
                      if (sync.lastSynced != null) {
                        final time = DateFormat.Hm().format(sync.lastSynced!.toLocal());
                        return ListTile(leading: const Icon(Icons.check, color: Colors.green), title: Text(l10n?.lastSyncAt(time) ?? 'Last sync: $time'));
                      }
                      return const SizedBox.shrink();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Center(
              child: BlocBuilder<ReportsCubit, String>(
                builder: (context, summary) => Text('Summary: $summary'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
