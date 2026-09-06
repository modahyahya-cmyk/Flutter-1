import '../../../orders/domain/entities/order.dart';
import '../repositories/printer_repository.dart';
import '../repositories/print_service.dart';

class PrintOrderUseCase {
  PrintOrderUseCase({required this.repository, required this.printService});

  final PrinterRepository repository;
  final PrintService printService;

  /// Builds and transmits a receipt for [order]. Requires a connection.
  Future<void> call(Order order, {required String vendorName, required String branchName}) async {
    if (!repository.isConnected) {
      // repo.printOrder enforces the transport preconditions
    }
    final bytes = await printService.buildOrderReceipt(
      orderId: order.id,
      orderNumber: order.orderNumber,
      createdAt: order.createdAt,
      items: order.items.map(_toMap).toList(),
      subtotal: order.subtotal,
      tax: order.taxAmount,
      deliveryFee: order.deliveryFee,
      discount: order.discountAmount,
      total: order.totalAmount,
      customerName: order.customer.fullName,
      customerPhone: order.customer.phone,
      address: order.deliveryAddress,
      vendorName: vendorName,
      branchName: branchName,
    );
    await printService.write(bytes);
    await repository.printOrder(orderId: order.id);
  }

  Map<String, dynamic> _toMap(dynamic item) => {
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
      };
}
