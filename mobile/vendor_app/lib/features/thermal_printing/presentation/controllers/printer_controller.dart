import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/printer_device.dart';
import '../../domain/usecases/connect_printer_usecase.dart';
import '../../domain/usecases/discover_printers_usecase.dart';
import '../../domain/usecases/print_order_usecase.dart';
import '../../domain/usecases/test_print_usecase.dart';

class PrinterController extends ChangeNotifier {
  PrinterController({
    required this.discoverPrintersUseCase,
    required this.connectPrinterUseCase,
    required this.printOrderUseCase,
    required this.testPrintUseCase,
  });

  final DiscoverPrintersUseCase discoverPrintersUseCase;
  final ConnectPrinterUseCase connectPrinterUseCase;
  final PrintOrderUseCase printOrderUseCase;
  final TestPrintUseCase testPrintUseCase;

  bool isDiscovering = false;
  bool isConnecting = false;
  bool isPrinting = false;
  bool isConnected = false;
  String? connectedAddress;
  List<PrinterDevice> devices = [];
  Failure? failure;
  String? lastVendorName;
  String? lastBranchName;

  Future<void> discover() async {
    isDiscovering = true;
    failure = null;
    notifyListeners();

    try {
      devices = await discoverPrintersUseCase();
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isDiscovering = false;
    notifyListeners();
  }

  Future<bool> connect(String address) async {
    isConnecting = true;
    failure = null;
    notifyListeners();

    try {
      await connectPrinterUseCase(address);
      isConnected = true;
      connectedAddress = address;
      return true;
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
      return false;
    } catch (_) {
      failure = const Failure.unknown();
      return false;
    } finally {
      isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await connectPrinterUseCase.disconnect();
    isConnected = false;
    connectedAddress = null;
    notifyListeners();
  }

  Future<bool> testPrint() async {
    if (!isConnected) {
      failure = const Failure('Connect a printer first', code: 'PRINTER_NOT_CONNECTED');
      notifyListeners();
      return false;
    }
    isPrinting = true;
    failure = null;
    notifyListeners();

    try {
      final ok = await testPrintUseCase();
      return ok;
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
      return false;
    } catch (_) {
      failure = const Failure.unknown();
      return false;
    } finally {
      isPrinting = false;
      notifyListeners();
    }
  }

  Future<bool> printOrder(Order order) async {
    if (!isConnected) {
      failure = const Failure('Connect a printer first', code: 'PRINTER_NOT_CONNECTED');
      notifyListeners();
      return false;
    }
    isPrinting = true;
    failure = null;
    notifyListeners();

    try {
      await printOrderUseCase(order,
          vendorName: lastVendorName ?? 'VendorHub', branchName: lastBranchName ?? '');
      return true;
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
      return false;
    } catch (_) {
      failure = const Failure.unknown();
      return false;
    } finally {
      isPrinting = false;
      notifyListeners();
    }
  }
}
