import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/features/auth/bloc/auth_bloc.dart';
import 'package:cashier_app/features/settings/bloc/theme_cubit.dart';
import 'package:cashier_app/features/settings/bloc/locale_cubit.dart';
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier_app/features/settings/bloc/feature_flags_cubit.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cashier_app/services/key_value_service.dart';

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
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => context.go('/about'),
          ),
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, state) {
              final text = state.isSyncing
                  ? l10n.settingsSyncing
                  : (state.error != null
                      ? l10n.settingsSyncError(state.error!)
                      : l10n.settingsSyncIdle);
              return ListTile(
                title: Text(text),
                trailing: FilledButton.icon(
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
          SwitchListTile(
            title: Text(AppLocalizations.of(context).settingsAllowOversell),
            value: (KeyValueService.get<bool>('allow_oversell') ?? false),
            onChanged: (v) async {
              await KeyValueService.set<bool>('allow_oversell', v);
              if (context.mounted) (context as Element).markNeedsBuild();
            },
          ),
          ListTile(
            title: Text(l10n.settingsBatchSize),
            subtitle: Text(flags.batchSize.toString()),
          ),
          Slider(
            value: flags.batchSize.toDouble(),
            min: 5,
            max: 50,
            divisions: 9,
            label: flags.batchSize.toString(),
            onChanged: (v) => context.read<FeatureFlagsCubit>().setBatchSize(v.round()),
          ),
          // Low stock threshold
          Builder(builder: (context) {
            final threshold = KeyValueService.get<int>('low_stock_threshold') ?? 5;
            return Column(
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context).settingsLowStockThreshold),
                  subtitle: Text(threshold.toString()),
                ),
                Slider(
                  value: threshold.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: threshold.toString(),
                  onChanged: (v) async {
                    await KeyValueService.set<int>('low_stock_threshold', v.round());
                    if (context.mounted) (context as Element).markNeedsBuild();
                  },
                ),
              ],
            );
          }),
          const Divider(),
          // Shop header/footer for receipts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).receipt, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _SettingTextField(
                  label: 'Shop name',
                  storageKey: 'shop_name',
                ),
                const SizedBox(height: 8),
                _SettingTextField(
                  label: 'Address',
                  storageKey: 'shop_address',
                ),
                const SizedBox(height: 8),
                _SettingTextField(
                  label: 'Phone',
                  storageKey: 'shop_phone',
                ),
                const SizedBox(height: 8),
                _SettingTextField(
                  label: 'Footer note',
                  storageKey: 'shop_footer',
                ),
              ],
            ),
          ),
          const Divider(),
          // Telegram bot settings (for direct send)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SettingTextField(label: 'Telegram bot token', storageKey: 'tg_bot_token'),
                SizedBox(height: 8),
                _SettingTextField(label: 'Telegram chat id', storageKey: 'tg_chat_id'),
              ],
            ),
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
          // Static KHQR settings
          Builder(builder: (context) {
            final khqrPath = KeyValueService.get<String>('khqr_image_path');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(l10n.settingsKhqrTitle),
                  subtitle: Text(khqrPath == null ? l10n.settingsKhqrNotSet : khqrPath),
                ),
                if (khqrPath != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(khqrPath), height: 160, fit: BoxFit.contain),
                    ),
                  ),
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: Text(l10n.settingsUploadKhqr),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked == null) return;
                        final appDir = await getApplicationDocumentsDirectory();
                        final dst = File('${appDir.path}/khqr.png');
                        await File(picked.path).copy(dst.path);
                        await KeyValueService.set<String>('khqr_image_path', dst.path);
                        if (context.mounted) (context as Element).markNeedsBuild();
                      },
                    ),
                    if (khqrPath != null)
                      TextButton.icon(
                        icon: const Icon(Icons.delete),
                        label: Text(l10n.settingsRemoveKhqr),
                        onPressed: () async {
                          await KeyValueService.remove('khqr_image_path');
                          if (context.mounted) (context as Element).markNeedsBuild();
                        },
                      ),
                  ],
                ),
                const Divider(),
              ],
            );
          }),
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

class _SettingTextField extends StatefulWidget {
  final String label;
  final String storageKey;
  const _SettingTextField({required this.label, required this.storageKey});

  @override
  State<_SettingTextField> createState() => _SettingTextFieldState();
}

class _SettingTextFieldState extends State<_SettingTextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: KeyValueService.get<String>(widget.storageKey) ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder(), isDense: true),
      onChanged: (v) => KeyValueService.set<String>(widget.storageKey, v.trim()),
    );
  }
}
