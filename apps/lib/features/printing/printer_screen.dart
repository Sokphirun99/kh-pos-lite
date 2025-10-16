import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:cashier_app/services/bluetooth_service.dart';
import 'package:cashier_app/services/key_value_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  List<BluetoothDeviceInfo> devices = const [];
  final _manualName = TextEditingController();
  final _manualAddr = TextEditingController();
  bool scanning = false;
  bool testing = false;
  List<_SavedPrinter> saved = const [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadSaved();
  }

  Future<void> _load() async {
    setState(() => scanning = true);
    try {
      final found = await BluetoothService().listDevices().timeout(
        const Duration(seconds: 10),
      );
      if (!mounted) return;
      setState(() {
        devices = found;
        scanning = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() => scanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).printingFailed)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => scanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).printingFailed)),
      );
    }
  }

  void _loadSaved() {
    final list = KeyValueService.get<List<dynamic>>('bt_printers') ?? const [];
    final sp = <_SavedPrinter>[];
    for (final e in list) {
      if (e is String) {
        final parts = e.split('||');
        if (parts.length >= 2)
          sp.add(_SavedPrinter(addr: parts[0], name: parts[1]));
      }
    }
    setState(() => saved = sp);
  }

  Future<void> _savePrinter(
    String addr,
    String name, {
    bool setDefault = true,
  }) async {
    // Add to saved list if not present
    final key = '$addr||$name';
    final list = List<String>.from(
      KeyValueService.get<List<dynamic>>(
            'bt_printers',
          )?.map((e) => e.toString()) ??
          const [],
    );
    if (!list.contains(key)) list.add(key);
    await KeyValueService.set('bt_printers', list);
    if (setDefault) {
      await KeyValueService.set('bt_printer_addr', addr);
      await KeyValueService.set('bt_printer_name', name);
    }
    _loadSaved();
    if (mounted) setState(() {});
  }

  Future<void> _setDefault(_SavedPrinter sp) async {
    await KeyValueService.set('bt_printer_addr', sp.addr);
    await KeyValueService.set('bt_printer_name', sp.name);
    if (mounted) setState(() {});
  }

  Future<void> _removeSaved(_SavedPrinter sp) async {
    final list = List<String>.from(
      KeyValueService.get<List<dynamic>>(
            'bt_printers',
          )?.map((e) => e.toString()) ??
          const [],
    );
    list.removeWhere((e) => e.startsWith('${sp.addr}||'));
    await KeyValueService.set('bt_printers', list);
    // If current default, clear it
    final currAddr = KeyValueService.get<String>('bt_printer_addr');
    if (currAddr == sp.addr) {
      await KeyValueService.remove('bt_printer_addr');
      await KeyValueService.remove('bt_printer_name');
    }
    _loadSaved();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _manualName.dispose();
    _manualAddr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selName = KeyValueService.get<String>('bt_printer_name');
    final selAddr = KeyValueService.get<String>('bt_printer_addr');
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pairPrinter)),
      body: ListView(
        children: [
          if (selAddr != null)
            ListTile(
              title: Text(selName ?? selAddr),
              subtitle: Text(selAddr),
              leading: const Icon(Icons.print, color: Colors.green),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: testing
                        ? null
                        : () async {
                            setState(() => testing = true);
                            try {
                              // Connect
                              await BluetoothService()
                                  .connectTo(selAddr)
                                  .timeout(const Duration(seconds: 8));
                              // Build simple test ticket
                              final data = <int>[];
                              data.addAll([0x1B, 0x40]); // init
                              data.addAll([0x1B, 0x61, 1]); // center
                              data.addAll(('TEST PRINT\n').codeUnits);
                              data.addAll([0x1B, 0x61, 0]); // left
                              data.addAll(
                                ('Hello from KH POS Lite\n').codeUnits,
                              );
                              data.addAll([0x1B, 0x64, 0x02]); // feed 2
                              data.addAll([0x1D, 0x56, 0x01]); // cut
                              await BluetoothService()
                                  .sendBytes(data)
                                  .timeout(const Duration(seconds: 8));
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.printingDone)),
                                );
                              }
                            } on TimeoutException {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.printingFailed)),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.printingFailed)),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => testing = false);
                            }
                          },
                    child: testing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.testPrint),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      await KeyValueService.remove('bt_printer_name');
                      await KeyValueService.remove('bt_printer_addr');
                      if (mounted) setState(() {});
                    },
                    child: Text(l10n.unpair),
                  ),
                ],
              ),
            ),
          ListTile(
            title: Text(l10n.printBluetooth),
            subtitle: Text(
              scanning
                  ? l10n.scanning
                  : (devices.isEmpty ? l10n.noDevicesFound : l10n.tapToSelect),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _load,
            ),
          ),
          if (devices.isNotEmpty)
            ...devices.map(
              (d) => ListTile(
                leading: const Icon(Icons.bluetooth_searching),
                title: Text(d.name),
                subtitle: Text(d.address),
                trailing: TextButton(
                  onPressed: () async =>
                      _savePrinter(d.address, d.name, setDefault: true),
                  child: Text(l10n.ok),
                ),
              ),
            ),
          const Divider(),
          if (saved.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Saved printers',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ...saved.map((sp) {
            final isDefault =
                (KeyValueService.get<String>('bt_printer_addr') ?? '') ==
                sp.addr;
            return ListTile(
              leading: Icon(
                isDefault ? Icons.radio_button_checked : Icons.radio_button_off,
              ),
              title: Text(sp.name),
              subtitle: Text(sp.addr),
              onTap: () => _setDefault(sp),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeSaved(sp),
              ),
            );
          }),
          for (final d in devices)
            ListTile(
              leading: const Icon(Icons.print),
              title: Text(d.name),
              subtitle: Text(d.address),
              onTap: () async {
                await _savePrinter(d.address, d.name, setDefault: true);
                if (mounted) Navigator.pop(context);
              },
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manual add (address + name)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _manualAddr,
                  decoration: const InputDecoration(
                    labelText: 'MAC/address',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _manualName,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () async {
                      final addr = _manualAddr.text.trim();
                      final name = _manualName.text.trim();
                      if (addr.isEmpty) return;
                      await KeyValueService.set(
                        'bt_printer_name',
                        name.isEmpty ? addr : name,
                      );
                      await KeyValueService.set('bt_printer_addr', addr);
                      if (mounted) Navigator.pop(context);
                    },
                    child: Text(l10n.ok),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedPrinter {
  final String addr;
  final String name;
  _SavedPrinter({required this.addr, required this.name});
}
