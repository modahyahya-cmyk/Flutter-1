import '../entities/printer_device.dart';

abstract class PrinterRepository {
  Future<List<PrinterDevice>> discoverDevices();
  Future<bool> connect(String address);
  Future<void> disconnect();
  Future<void> printOrder({required int orderId});
  Future<bool> testPrint();
  bool get isConnected;
  String? get connectedAddress;
}
