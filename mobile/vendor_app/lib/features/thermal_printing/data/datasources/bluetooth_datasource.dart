import 'dart:typed_data';

import 'package:spp_connection_plugin/spp_connection_plugin.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/printer_device.dart';

/// Thin wrapper over [SppConnectionPlugin] (Bluetooth Classic SPP — the
/// profile used by ESC/POS thermal printers) that exposes only what the
/// printing feature needs. Keeps the plugin isolated from the business
/// layer so the transport can be swapped without touching callers.
class BluetoothDataSource {
  BluetoothDataSource({SppConnectionPlugin? plugin})
      : _plugin = plugin ?? SppConnectionPlugin();

  final SppConnectionPlugin _plugin;

  String? _connectedAddress;

  /// ESC/POS printers are paired through the Android system settings
  /// first, so discovery lists the PAIRED (bonded) devices. Classic SPP
  /// devices cannot be paired from an in-app scan on modern Android, and
  /// listing bonded devices is the same flow the previous plugin used.
  Future<List<PrinterDevice>> discoverDevices() async {
    try {
      if (!await _ensurePermissions()) {
        throw const AppException(
          message: 'Bluetooth permission is required to list printers.',
        );
      }

      final enabled = await _plugin.isBluetoothEnabled();
      if (!enabled) {
        throw const AppException(message: 'Bluetooth is not enabled.');
      }

      final devices = await _plugin.getPairedDevices();
      return devices
          .where((d) => d.name.trim().isNotEmpty)
          .map((d) => PrinterDevice(name: d.displayName, address: d.address))
          .toList();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        message: 'Bluetooth discovery failed. Ensure Bluetooth is on.',
      );
    }
  }

  Future<void> connect(String address) async {
    if (_connectedAddress == address && isConnected) {
      return; // Already connected to this printer.
    }

    try {
      if (!await _ensurePermissions()) {
        throw const AppException(
          message: 'Bluetooth permission is required to connect.',
        );
      }

      await _plugin.connectToDevice(address);

      // connectToDevice resolves when the socket is open on Android, but
      // double-check the state stream so a slow/failing link is reported
      // instead of surfacing later as a write error.
      if (_plugin.connectionState != BluetoothConnectionState.connected) {
        await _plugin.connectionStateStream
            .firstWhere((s) => s == BluetoothConnectionState.connected)
            .timeout(const Duration(seconds: 15));
      }

      _connectedAddress = address;
    } on AppException {
      rethrow;
    } catch (_) {
      _connectedAddress = null;
      throw const AppException(message: 'Could not connect to printer device');
    }
  }

  Future<void> disconnect() async {
    try {
      if (_connectedAddress != null) {
        await _plugin.disconnect();
      }
    } catch (_) {
      // already closed
    }
    _connectedAddress = null;
  }

  Future<void> write(List<int> bytes) async {
    if (_connectedAddress == null) {
      throw const AppException(message: 'Printer is not connected');
    }

    try {
      await _plugin.sendData(Uint8List.fromList(bytes));
    } catch (_) {
      throw const AppException(message: 'Failed to send data to printer');
    }
  }

  bool get isConnected =>
      _connectedAddress != null &&
      _plugin.connectionState == BluetoothConnectionState.connected;

  String? get connectedAddress => _connectedAddress;

  Future<bool> _ensurePermissions() async {
    if (await _plugin.hasPermissions()) {
      return true;
    }

    return await _plugin.requestPermissions();
  }
}
