import '../repositories/printer_repository.dart';
import '../repositories/print_service.dart';

class TestPrintUseCase {
  TestPrintUseCase({required this.repository, required this.printService});

  final PrinterRepository repository;
  final PrintService printService;

  Future<bool> call() async {
    if (!repository.isConnected) return false;
    final bytes = await printService.buildTestBuffer();
    await printService.write(bytes);
    return true;
  }
}
