import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/printer_device.dart';

/// Thin wrapper over [FlutterBluetoothSerial] that exposes only what the
/// printing feature needs. Keeps the plugin isolated from the business layer.
class BluetoothDataSource {
  BluetoothDataSource({FlutterBluetoothSerial? serial})
      : _serial = serial ?? FlutterBluetoothSerial.instance;

  final FlutterBluetoothSerial _serial;
  BluetoothConnection? _connection;
  String? _connectedAddress;

  Future<List<PrinterDevice>> discoverDevices() async {
    try {
      final bonded = await _serial.getBondedDevices();
      final results = await _serial.startDiscovery().toList();
      final discovered = results
          .where((r) => r.device.name != null && r.device.name!.isNotEmpty)
          .map((r) => PrinterDevice(name: r.device.name!, address: r.device.address))
          .toList();

      final seed = <String, PrinterDevice>{};
      for (final b in bonded) {
        if (b.name != null && b.name!.isNotEmpty) {
          seed[b.address] = PrinterDevice(name: b.name!, address: b.address);
        }
      }
      for (final d in discovered) {
        seed[d.address] = d;
      }
      return seed.values.toList();
    } catch (_) {
      throw const AppException(message: 'Bluetooth discovery failed. Ensure Bluetooth is on.');
    }
  }

  Future<void> connect(String address) async {
    try {
      _connection = await BluetoothConnection.toAddress(address);
      _connectedAddress = address;
      _connection!.input?.listen((_) {});
      
    } catch (_) {
      throw const AppException(message: 'Could not connect to printer device');
    }
  }

  Future<void> disconnect() async {
    try {
      await _connection?.close();
    } catch (_) {
      // already closed
    }
    _connection = null;
    _connectedAddress = null;
  }

  Future<void> write(List<int> bytes) async {
    if (_connection == null) {
      throw const AppException(message: 'Printer is not connected');
    }
    try {
      _connection!.output.add(Uint8List.fromList(bytes));
    } catch (_) {
      throw const AppException(message: 'Failed to send data to printer');
    }
  }

  bool get isConnected => _connection != null;
  String? get connectedAddress => _connectedAddress;
}
