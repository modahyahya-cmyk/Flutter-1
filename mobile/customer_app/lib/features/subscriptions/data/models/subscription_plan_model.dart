import '../../domain/entities/subscription_plan.dart';

class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.code,
    required super.price,
    super.description,
    super.billingCycle,
    super.durationDays,
    super.featured,
    super.features,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      billingCycle: json['billing_cycle'] as String? ?? 'monthly',
      durationDays: json['duration_days'] as int? ?? 30,
      featured: json['featured'] as bool? ?? false,
      features: (json['features'] as List?)?.cast<String>() ?? const [],
    );
  }
}
