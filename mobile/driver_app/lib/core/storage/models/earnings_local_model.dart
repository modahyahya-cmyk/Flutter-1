import 'package:isar/isar.dart';

part 'earnings_local_model.g.dart';

@collection
class EarningsLocalModel {
  EarningsLocalModel({
    required this.earningId,
    required this.deliveryId,
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.deliveryFee,
    required this.tipAmount,
    required this.platformCommission,
    required this.date,
    required this.status,
    this.isSynced = false,
  });

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String earningId;

  late String deliveryId;
  late String orderId;
  late String orderNumber;

  late double amount;
  late double deliveryFee;
  late double tipAmount;
  late double platformCommission;

  @Index()
  late DateTime date;

  late String status;

  late bool isSynced;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'earning_id': earningId,
      'delivery_id': deliveryId,
      'order_id': orderId,
      'order_number': orderNumber,
      'amount': amount,
      'delivery_fee': deliveryFee,
      'tip_amount': tipAmount,
      'platform_commission': platformCommission,
      'date': date.toIso8601String(),
      'status': status,
      'is_synced': isSynced,
    };
  }
}
