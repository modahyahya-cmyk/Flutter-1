import '../../domain/entities/subscription.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.status,
    super.planId,
    super.amount,
    super.planName,
    super.endsAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>?;
    return SubscriptionModel(
      id: json['id'] as int,
      planId: json['plan_id'] as int?,
      status: json['status'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      planName: plan?['name'] as String?,
      endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'] as String) : null,
    );
  }
}
