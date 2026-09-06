class Subscription {
  const Subscription({
    required this.id,
    required this.status,
    this.planId,
    this.amount = 0,
    this.planName,
    this.endsAt,
  });

  final int id;
  final int? planId;
  final String status;
  final double amount;
  final String? planName;
  final DateTime? endsAt;

  bool get isActive => status == 'active';
}
