class EarningsSummary {
  const EarningsSummary({
    required this.todayEarnings,
    required this.weekEarnings,
    required this.monthEarnings,
    required this.totalEarnings,
    required this.totalOrders,
    this.todayOrders = 0,
    this.weekOrders = 0,
    this.monthOrders = 0,
    this.averageOrderValue = 0,
    required this.lastUpdated,
  });

  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;
  final double totalEarnings;
  final int totalOrders;
  final int todayOrders;
  final int weekOrders;
  final int monthOrders;
  final double averageOrderValue;
  final DateTime lastUpdated;
}
