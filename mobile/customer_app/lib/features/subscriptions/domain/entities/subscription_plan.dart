class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    this.description,
    this.billingCycle = 'monthly',
    this.durationDays = 30,
    this.featured = false,
    this.features = const [],
  });

  final int id;
  final String name;
  final String code;
  final double price;
  final String? description;
  final String billingCycle;
  final int durationDays;
  final bool featured;
  final List<String> features;
}
