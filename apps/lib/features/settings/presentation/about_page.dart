import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:isar/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cashier_app/core/isar_db.dart';
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:cashier_app/features/settings/bloc/feature_flags_cubit.dart';
import 'package:cashier_app/services/key_value_service.dart';
import 'package:cashier_app/data/local/isar_collections.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<Map<String, String>> _loadInfo() async {
    final pkg = await PackageInfo.fromPlatform();
    final isar = await openIsarDb();
    final ver = await isar.collection<MetaKV>().filter().keyEqualTo('dbVersion').findFirst();
    return {
      'appVersion': '${pkg.version}+${pkg.buildNumber}',
      'dbVersion': ver?.value ?? 'unknown',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final last = context.watch<SyncBloc>().state.lastSynced;
    final lastSyncText = last != null ? (l10n.lastSyncAt(DateFormat.Hm().format(last.toLocal())) ?? '') : '-';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle ?? 'About')),
      body: FutureBuilder<Map<String, String>>(
        future: _loadInfo(),
        builder: (context, snap) {
          final data = snap.data;
          return ListView(
            children: [
              ListTile(
                title: Text(l10n.aboutAppVersion ?? 'App version'),
                subtitle: Text(data?['appVersion'] ?? '...'),
                trailing: const Icon(Icons.copy),
                onTap: () async {
                  final text = data?['appVersion'] ?? '';
                  await Clipboard.setData(ClipboardData(text: text));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.aboutCopied ?? 'Copied')),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.aboutDbVersion ?? 'DB version'),
                subtitle: Text(data?['dbVersion'] ?? '...'),
              ),
              ListTile(
                title: Text(l10n.aboutLastSync ?? 'Last sync'),
                subtitle: Text(lastSyncText),
              ),
              const Divider(),
              Builder(builder: (context) {
                final flags = context.watch<FeatureFlagsCubit>().state;
                final params = Uri(queryParameters: {
                  'showSyncBanner': flags.showSyncBanner ? '1' : '0',
                  'enableBatchSync': flags.enableBatchSync ? '1' : '0',
                  'batchSize': flags.batchSize.toString(),
                }).query;
                return ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(l10n.aboutQaParams ?? 'QA params'),
                  subtitle: Text(params),
                  trailing: const Icon(Icons.copy),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: params));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.aboutCopied ?? 'Copied')),
                    );
                  },
                );
              }),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(l10n.aboutResetLocalDb ?? 'Reset local data'),
                subtitle: Text(l10n.aboutResetLocalDbHint ?? 'Long-press to reset'),
                onLongPress: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.aboutConfirmTitle ?? 'Confirm reset'),
                      content: Text(l10n.aboutConfirmMessage ?? 'This will delete local data. Continue?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel ?? 'Cancel')),
                        ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.ok ?? 'OK')),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  // Perform reset
                  try {
                    final isar = await openIsarDb();
                    await isar.writeTxn(() async {
                      await isar.collection<ProductModel>().clear();
                      await isar.collection<SaleModel>().clear();
                      await isar.collection<PaymentModel>().clear();
                      await isar.collection<OutboxOp>().clear();
                      await isar.collection<MetaKV>().clear();
                    });
                    await KeyValueService.clear();
                    await HydratedBloc.storage.clear();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.aboutResetDone ?? 'Local data cleared')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.error ?? 'Error'}: $e')),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
