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
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final flags = context.watch<FeatureFlagsCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          _SettingsSection(
            title: l10n.settingsGeneralSection,
            subtitle: l10n.settingsGeneralSectionSubtitle,
            children: [
              _SettingsTile(
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
                  return _SettingsTile(
                    leading: const Icon(Icons.sync),
                    title: Text(text),
                    trailing: FilledButton.icon(
                      icon: const Icon(Icons.cloud_upload_outlined),
                      onPressed: state.isSyncing
                          ? null
                          : () => context.read<SyncBloc>().add(
                              const SyncTriggered(),
                            ),
                      label: Text(l10n.settingsSyncNow),
                    ),
                  );
                },
              ),
              BlocBuilder<SyncBloc, SyncState>(
                buildWhen: (previous, current) =>
                    previous.lastSynced != current.lastSynced,
                builder: (context, state) {
                  if (state.lastSynced == null) return const SizedBox.shrink();
                  return _SettingsTile(
                    leading: const Icon(Icons.task_alt, color: Colors.green),
                    title: Text(
                      l10n.lastSyncAt(
                        DateFormat.Hm().format(state.lastSynced!.toLocal()),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: l10n.settingsPreferencesSection,
            subtitle: l10n.settingsPreferencesSectionSubtitle,
            children: [
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                secondary: const Icon(Icons.dark_mode_outlined),
                title: Text(l10n.settingsDarkMode),
                value: isDark,
                onChanged: (v) => context.read<ThemeCubit>().setDark(v),
              ),
              _SettingsTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.settingsLanguage),
                subtitle: Text(
                  locale?.languageCode == 'km'
                      ? l10n.settingsLanguageKm
                      : l10n.settingsLanguageEn,
                ),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<Locale>(
                    value: locale ?? const Locale('en'),
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: Locale('km'),
                        child: Text('ខ្មែរ'),
                      ),
                    ],
                    onChanged: (loc) =>
                        context.read<LocaleCubit>().setLocale(loc),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: l10n.settingsSyncSection,
            subtitle: l10n.settingsSyncSectionSubtitle,
            children: [
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                secondary: const Icon(Icons.campaign_outlined),
                title: Text(l10n.settingsShowSyncBanner),
                value: flags.showSyncBanner,
                onChanged: (v) =>
                    context.read<FeatureFlagsCubit>().setShowSyncBanner(v),
              ),
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                secondary: const Icon(Icons.playlist_add_check_circle_outlined),
                title: Text(l10n.settingsEnableBatchSync),
                value: flags.enableBatchSync,
                onChanged: (v) =>
                    context.read<FeatureFlagsCubit>().setEnableBatchSync(v),
              ),
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                secondary: const Icon(Icons.inventory_2_outlined),
                title: Text(l10n.settingsAllowOversell),
                value: (KeyValueService.get<bool>('allow_oversell') ?? false),
                onChanged: (v) async {
                  await KeyValueService.set<bool>('allow_oversell', v);
                  if (context.mounted) (context as Element).markNeedsBuild();
                },
              ),
              _SettingsTile(
                leading: const Icon(Icons.tune),
                title: Text(l10n.settingsBatchSize),
                subtitle: Text(l10n.settingsBatchSizeHint(flags.batchSize)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Slider(
                  value: flags.batchSize.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: flags.batchSize.toString(),
                  onChanged: (v) =>
                      context.read<FeatureFlagsCubit>().setBatchSize(v.round()),
                ),
              ),
              Builder(
                builder: (context) {
                  final threshold =
                      KeyValueService.get<int>('low_stock_threshold') ?? 5;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingsTile(
                        leading: const Icon(Icons.inventory_outlined),
                        title: Text(l10n.settingsLowStockThreshold),
                        subtitle: Text(
                          l10n.settingsLowStockThresholdDescription(threshold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Slider(
                          value: threshold.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: threshold.toString(),
                          onChanged: (v) async {
                            await KeyValueService.set<int>(
                              'low_stock_threshold',
                              v.round(),
                            );
                            if (context.mounted)
                              (context as Element).markNeedsBuild();
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: l10n.settingsReceiptSection,
            subtitle: l10n.settingsReceiptSectionSubtitle,
            children: const [
              _SettingTextField(label: 'Shop name', storageKey: 'shop_name'),
              _SettingsDivider(),
              _SettingTextField(label: 'Address', storageKey: 'shop_address'),
              _SettingsDivider(),
              _SettingTextField(label: 'Phone', storageKey: 'shop_phone'),
              _SettingsDivider(),
              _SettingTextField(
                label: 'Footer note',
                storageKey: 'shop_footer',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: l10n.settingsPaymentSection,
            subtitle: l10n.settingsPaymentSectionSubtitle,
            children: [
              Builder(
                builder: (context) {
                  final khqrPath = KeyValueService.get<String>(
                    'khqr_image_path',
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingsTile(
                        leading: const Icon(Icons.qr_code_2),
                        title: Text(l10n.settingsKhqrTitle),
                        subtitle: Text(khqrPath ?? l10n.settingsKhqrNotSet),
                      ),
                      if (khqrPath != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(khqrPath),
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.upload),
                              label: Text(l10n.settingsUploadKhqr),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (picked == null) return;
                                final appDir =
                                    await getApplicationDocumentsDirectory();
                                final dst = File('${appDir.path}/khqr.png');
                                await File(picked.path).copy(dst.path);
                                await KeyValueService.set<String>(
                                  'khqr_image_path',
                                  dst.path,
                                );
                                if (context.mounted)
                                  (context as Element).markNeedsBuild();
                              },
                            ),
                            if (khqrPath != null)
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                label: Text(l10n.settingsRemoveKhqr),
                                onPressed: () async {
                                  await KeyValueService.remove(
                                    'khqr_image_path',
                                  );
                                  if (context.mounted)
                                    (context as Element).markNeedsBuild();
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const _SettingsDivider(),
              const _SettingTextField(
                label: 'Telegram bot token',
                storageKey: 'tg_bot_token',
              ),
              const _SettingsDivider(),
              const _SettingTextField(
                label: 'Telegram chat id',
                storageKey: 'tg_chat_id',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: l10n.settingsDangerZone,
            subtitle: l10n.settingsDangerZoneSubtitle,
            children: [
              _SettingsTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n.loginTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.redAccent),
                ),
                onTap: () async {
                  context.read<AuthBloc>().add(const AuthSignedOut());
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
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
    _ctrl = TextEditingController(
      text: KeyValueService.get<String>(widget.storageKey) ?? '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextField(
        controller: _ctrl,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.4),
            ),
          ),
          isDense: true,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
            theme.brightness == Brightness.dark ? 0.24 : 0.5,
          ),
        ),
        onChanged: (v) =>
            KeyValueService.set<String>(widget.storageKey, v.trim()),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  const _SettingsSection({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final foregroundMuted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: textTheme.bodySmall?.copyWith(color: foregroundMuted),
          ),
        ],
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          margin: EdgeInsets.zero,
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(
            theme.brightness == Brightness.dark ? 0.3 : 0.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              for (final widget in children) ...[
                if (widget is _SettingsDivider)
                  const Divider(height: 1)
                else
                  widget,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final foregroundMuted = theme.colorScheme.onSurfaceVariant;

    return ListTile(
      leading: leading == null
          ? null
          : IconTheme.merge(
              data: IconThemeData(color: theme.colorScheme.primary),
              child: leading!,
            ),
      minLeadingWidth: 32,
      title: DefaultTextStyle.merge(style: textTheme.titleMedium, child: title),
      subtitle: subtitle == null
          ? null
          : DefaultTextStyle.merge(
              style: textTheme.bodySmall?.copyWith(color: foregroundMuted),
              child: subtitle!,
            ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      horizontalTitleGap: 12,
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
