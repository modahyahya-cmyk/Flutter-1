import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/printer_device.dart';
import '../../domain/repositories/printer_repository.dart';
import '../datasources/bluetooth_datasource.dart';

class PrinterRepositoryImpl implements PrinterRepository {
  PrinterRepositoryImpl({
    required this.bluetoothDataSource,
    required this.localStorage,
  });

  final BluetoothDataSource bluetoothDataSource;
  final LocalStorage localStorage;

  PrinterDevice? _selected;

  @override
  Future<List<PrinterDevice>> discoverDevices() => bluetoothDataSource.discoverDevices();

  @override
  Future<bool> connect(String address) async {
    await bluetoothDataSource.connect(address);
    _selected = await _findSelected(address);
    await localStorage.saveString(StorageKeys.selectedPrinterAddress, address);
    if (_selected != null) {
      await localStorage.saveString(StorageKeys.selectedPrinterName, _selected!.name);
    }
    return true;
  }

  @override
  Future<void> disconnect() => bluetoothDataSource.disconnect();

  @override
  Future<void> printOrder({required int orderId}) async {
    if (!bluetoothDataSource.isConnected) {
      throw const AppException(message: 'Printer is not connected');
    }
  }

  @override
  Future<bool> testPrint() async {
    if (!bluetoothDataSource.isConnected) {
      throw const AppException(message: 'Printer is not connected');
    }
    return true;
  }

  @override
  bool get isConnected => bluetoothDataSource.isConnected;

  @override
  String? get connectedAddress => bluetoothDataSource.connectedAddress;

  String? get selectedPrinterName => localStorage.getString(StorageKeys.selectedPrinterName);

  Future<PrinterDevice?> _findSelected(String address) async {
    final devices = await bluetoothDataSource.discoverDevices();
    for (final d in devices) {
      if (d.address == address) return d;
    }
    return PrinterDevice(name: address, address: address);
  }
}
