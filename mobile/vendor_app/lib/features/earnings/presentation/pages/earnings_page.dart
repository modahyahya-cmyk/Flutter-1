import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../core/errors/failures.dart';
import '../controllers/earnings_controller.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  EarningsController get _controller => locator<EarningsController>();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.failure != null && _controller.summary == null) {
            return Center(child: Text(mapFailureToMessage(_controller.failure!)));
          }
          final s = _controller.summary;
          if (s == null) return const Center(child: Text('No earnings data'));
          return RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BigStatCard(
                  label: 'Total earnings',
                  value: AppConfig.formatCurrency(s.totalEarnings),
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(label: 'Today', value: AppConfig.formatCurrency(s.todayEarnings), sub: '${s.todayOrders} orders'),
                    _StatCard(label: 'This week', value: AppConfig.formatCurrency(s.weekEarnings), sub: '${s.weekOrders} orders'),
                    _StatCard(label: 'This month', value: AppConfig.formatCurrency(s.monthEarnings), sub: '${s.monthOrders} orders'),
                    _StatCard(label: 'Avg. order', value: AppConfig.formatCurrency(s.averageOrderValue), sub: '${s.totalOrders} total orders'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Updated ${s.lastUpdated.toString().split('.').first}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  const _BigStatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppConfig.PRIMARY_COLOR.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: AppConfig.PRIMARY_COLOR), const SizedBox(width: 8), Text(label)]),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.sub});

  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
            const Spacer(),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(sub, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
