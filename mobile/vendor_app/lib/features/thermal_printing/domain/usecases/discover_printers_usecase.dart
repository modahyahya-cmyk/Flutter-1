import '../entities/printer_device.dart';
import '../repositories/printer_repository.dart';

class DiscoverPrintersUseCase {
  DiscoverPrintersUseCase({required this.repository});

  final PrinterRepository repository;

  Future<List<PrinterDevice>> call() => repository.discoverDevices();
}
