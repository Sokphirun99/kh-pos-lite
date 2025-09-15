import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cashier_app/features/auth/bloc/auth_bloc.dart';
import 'package:cashier_app/features/settings/bloc/theme_cubit.dart';
import 'package:cashier_app/features/settings/bloc/locale_cubit.dart';
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final flags = context.watch<FeatureFlagsCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: ListView(
        children: [
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, state) {
              final text = state.isSyncing
                  ? l10n.settingsSyncing
                  : (state.error != null
                      ? l10n.settingsSyncError(state.error!)
                      : l10n.settingsSyncIdle);
              return ListTile(
                title: Text(text),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.sync),
                  onPressed: state.isSyncing
                      ? null
                      : () => context.read<SyncBloc>().add(const SyncTriggered()),
                  label: Text(l10n.settingsSyncNow),
                ),
              );
            },
          ),
          SwitchListTile(
            title: Text(l10n.settingsDarkMode),
            value: isDark,
            onChanged: (v) => context.read<ThemeCubit>().setDark(v),
          ),
          SwitchListTile(
            title: Text(l10n.settingsShowSyncBanner),
            value: flags.showSyncBanner,
            onChanged: (v) => context.read<FeatureFlagsCubit>().setShowSyncBanner(v),
          ),
          SwitchListTile(
            title: Text(l10n.settingsEnableBatchSync),
            value: flags.enableBatchSync,
            onChanged: (v) => context.read<FeatureFlagsCubit>().setEnableBatchSync(v),
          ),
          if (context.read<SyncBloc>().state.lastSynced != null)
            ListTile(
              leading: const Icon(Icons.check, color: Colors.green),
              title: Text(
                l10n.lastSyncAt(
                  DateFormat.Hm().format(context.read<SyncBloc>().state.lastSynced!.toLocal()),
                ),
              ),
            ),
          ListTile(
            title: Text(l10n.settingsLanguage),
            subtitle: Text(locale?.languageCode == 'km'
                ? l10n.settingsLanguageKm
                : l10n.settingsLanguageEn),
            trailing: DropdownButton<Locale>(
              value: locale ?? const Locale('en'),
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('km'), child: Text('ខ្មែរ')),
              ],
              onChanged: (loc) => context.read<LocaleCubit>().setLocale(loc),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.loginTitle),
            leading: const Icon(Icons.logout),
            onTap: () async {
              context.read<AuthBloc>().add(const AuthSignedOut());
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
