import '../entities/printer_device.dart';

/// Device management + connection state for the thermal printer.
///
/// NOTE: the actual byte transmission (receipt building + write) lives in
/// [PrintService] and is orchestrated by the use cases — this repository
/// intentionally only owns the transport/connection lifecycle.
abstract class PrinterRepository {
  Future<List<PrinterDevice>> discoverDevices();
  Future<bool> connect(String address);
  Future<void> disconnect();
  bool get isConnected;
  String? get connectedAddress;
}
