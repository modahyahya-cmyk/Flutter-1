import 'package:equatable/equatable.dart';

class Earnings extends Equatable {
  const Earnings({
    required this.id,
    required this.deliveryId,
    required this.orderId,
    required this.orderNumber,
    required this.deliveryFee,
    required this.tipAmount,
    required this.platformCommission,
    required this.totalEarnings,
    required this.date,
    required this.status,
  });

  final String id;
  final String deliveryId;
  final String orderId;
  final String orderNumber;
  final double deliveryFee;
  final double tipAmount;
  final double platformCommission;
  final double totalEarnings;
  final DateTime date;
  final EarningStatus status;

  double get netEarnings => totalEarnings - platformCommission;

  @override
  List<Object?> get props => [id, deliveryId, orderId, date, totalEarnings];
}

class EarningsSummary extends Equatable {
  const EarningsSummary({
    required this.totalEarnings,
    required this.totalDeliveryFees,
    required this.totalTips,
    required this.totalCommissions,
    required this.netEarnings,
    required this.totalDeliveries,
    required this.averageEarningPerDelivery,
    required this.periodStart,
    required this.periodEnd,
  });

  final double totalEarnings;
  final double totalDeliveryFees;
  final double totalTips;
  final double totalCommissions;
  final double netEarnings;
  final int totalDeliveries;
  final double averageEarningPerDelivery;
  final DateTime periodStart;
  final DateTime periodEnd;

  @override
  List<Object?> get props => [totalEarnings, totalDeliveries, periodStart, periodEnd];
}

enum EarningStatus { pending, completed, paid }

extension EarningStatusX on EarningStatus {
  String get wire => switch (this) {
        EarningStatus.pending => 'pending',
        EarningStatus.completed => 'completed',
        EarningStatus.paid => 'paid',
      };

  static EarningStatus fromWire(String? value) => switch (value) {
        'completed' => EarningStatus.completed,
        'paid' => EarningStatus.paid,
        _ => EarningStatus.pending,
      };

  String get label => switch (this) {
        EarningStatus.pending => 'Pending',
        EarningStatus.completed => 'Completed',
        EarningStatus.paid => 'Paid',
      };
}
