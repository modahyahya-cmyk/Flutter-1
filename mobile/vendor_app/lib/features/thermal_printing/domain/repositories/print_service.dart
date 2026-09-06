import 'package:esc_pos_utils/esc_pos_utils.dart';

import '../../data/datasources/bluetooth_datasource.dart';

/// Builds ESC/POS byte buffers for receipts and sends them over the
/// Bluetooth transport. Keeps the ESC/POS encoding concerns isolated from the
/// repository and is transport-only (no network, no business state).
class PrintService {
  PrintService({required this.bluetoothDataSource});

  final BluetoothDataSource bluetoothDataSource;

  /// Build the full ESC/POS receipt buffer for a vendor order.
  Future<List<int>> buildOrderReceipt({
    required int orderId,
    required String orderNumber,
    required DateTime createdAt,
    required List<dynamic> items,
    required double subtotal,
    required double tax,
    required double deliveryFee,
    required double discount,
    required double total,
    String? customerName,
    String? customerPhone,
    String? address,
    required String vendorName,
    required String branchName,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];

    bytes += generator.reset();

    bytes += generator.text(vendorName, styles: PosStyles(bold: true, align: PosAlign.center, height: PosTextSize.size2));
    bytes += generator.text(branchName, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('$orderNumber', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('$createdAt', styles: const PosStyles(bold: true, align: PosAlign.center));

    bytes += generator.hr();

    for (final item in items) {
      final name = (item is Map ? item['name'] : null)?.toString() ?? 'Item';
      final qty = ((item is Map ? item['quantity'] : null) as num?)?.toInt() ?? 1;
      final price = ((item is Map ? item['price'] : null) as num?)?.toDouble() ?? 0;
      bytes += generator.row([
        PosColumn(text: '${qty}x $name', width: 8),
        PosColumn(text: _money(price * qty), width: 4, styles: PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: 'Subtotal', width: 8),
      PosColumn(text: _money(subtotal), width: 4, styles: const PosStyles(align: PosAlign.right)),
    ]);
    if (deliveryFee > 0) {
      bytes += generator.row([
        PosColumn(text: 'Delivery', width: 8),
        PosColumn(text: _money(deliveryFee), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }
    if (discount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Discount', width: 8),
        PosColumn(text: '-${_money(discount)}', width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }
    if (tax > 0) {
      bytes += generator.row([
        PosColumn(text: 'Tax', width: 8),
        PosColumn(text: _money(tax), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 8, styles: const PosStyles(bold: true)),
      PosColumn(text: _money(total), width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.hr();

    if (customerName != null && customerName.isNotEmpty) bytes += generator.text('Customer: $customerName');
    if (customerPhone != null && customerPhone.isNotEmpty) bytes += generator.text('Phone: $customerPhone');
    if (address != null && address.isNotEmpty) bytes += generator.text('Address: $address');

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  /// Small self-test receipt to verify the printer is working.
  Future<List<int>> buildTestBuffer() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    bytes += generator.reset();
    bytes += generator.text('TEST PRINT', styles: PosStyles(bold: true, align: PosAlign.center, height: PosTextSize.size2));
    bytes += generator.feed(1);
    bytes += generator.text('VendorHub POS', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Printer is working correctly.', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  /// Send already-built [bytes] to the connected printer.
  Future<void> write(List<int> bytes) => bluetoothDataSource.write(bytes);

  String _money(double value) => '\$${value.toStringAsFixed(2)}';
}
