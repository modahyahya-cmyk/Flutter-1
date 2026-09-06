import '../../../../core/storage/models/earnings_local_model.dart';
import '../../domain/entities/earnings.dart';

class EarningsMapper {
  EarningsMapper._();

  static EarningsLocalModel toLocal(Earnings e, {bool isSynced = false}) {
    return EarningsLocalModel(
      earningId: e.id,
      deliveryId: e.deliveryId,
      orderId: e.orderId,
      orderNumber: e.orderNumber,
      amount: e.totalEarnings,
      deliveryFee: e.deliveryFee,
      tipAmount: e.tipAmount,
      platformCommission: e.platformCommission,
      date: e.date,
      status: e.status.wire,
      isSynced: isSynced,
    );
  }

  static Earnings fromLocal(EarningsLocalModel m) {
    return Earnings(
      id: m.earningId,
      deliveryId: m.deliveryId,
      orderId: m.orderId,
      orderNumber: m.orderNumber,
      deliveryFee: m.deliveryFee,
      tipAmount: m.tipAmount,
      platformCommission: m.platformCommission,
      totalEarnings: m.amount,
      date: m.date,
      status: EarningStatusX.fromWire(m.status),
    );
  }

  static Earnings fromJson(Map<String, dynamic> json) {
    return Earnings(
      id: (json['id'] ?? json['earning_id'] ?? '').toString(),
      deliveryId: (json['delivery_id'] ?? '').toString(),
      orderId: (json['order_id'] ?? '').toString(),
      orderNumber: json['order_number'] as String? ?? 'N/A',
      deliveryFee: _d(json['delivery_fee']),
      tipAmount: _d(json['tip_amount']),
      platformCommission: _d(json['platform_commission']),
      totalEarnings: _d(json['total_earnings'] ?? json['amount']),
      date: json['date'] is String
          ? (DateTime.tryParse(json['date'] as String) ?? DateTime.now())
          : DateTime.now(),
      status: EarningStatusX.fromWire(json['status'] as String?),
    );
  }

  static double _d(Object? v) => v is num ? v.toDouble() : 0;
}
