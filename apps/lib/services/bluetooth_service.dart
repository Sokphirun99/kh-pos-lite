// Simple Bluetooth printer service abstraction.
// Replace internals with a real plugin (e.g., bluetooth_print) when ready.
class BluetoothDeviceInfo {
  final String name;
  final String address;
  BluetoothDeviceInfo({required this.name, required this.address});
}

class BluetoothService {
  Future<List<BluetoothDeviceInfo>> listDevices({Duration timeout = const Duration(seconds: 8)}) async {
    // TODO: Integrate real discovery. Stub returns empty list.
    return const <BluetoothDeviceInfo>[];
  }

  Future<void> connectTo(String address, {Duration timeout = const Duration(seconds: 8)}) async {
    // TODO: Integrate connect logic
  }

  Future<void> sendBytes(List<int> data, {Duration timeout = const Duration(seconds: 8)}) async {
    // TODO: Integrate send logic
  }

  Future<void> disconnect() async {
    // TODO: Integrate disconnect logic
  }
}
