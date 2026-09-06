import '../repositories/printer_repository.dart';

class ConnectPrinterUseCase {
  ConnectPrinterUseCase({required this.repository});

  final PrinterRepository repository;

  Future<bool> call(String address) => repository.connect(address);

  Future<void> disconnect() => repository.disconnect();
}
