import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../domain/entities/earnings.dart';
import '../controllers/earnings_controller.dart';

/// Driver earnings, backed by [EarningsController] (remote API + offline
/// Isar cache): a period summary plus the recent per-delivery ledger.
class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  EarningsController get _controller => getIt<EarningsController>();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: BlocBuilder<EarningsController, EarningsState>(
        bloc: _controller,
        builder: (context, state) {
          if (state.isLoading && state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      state.error ?? 'Failed to load earnings',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _controller.load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = state.data!;
          final summary =
              data.monthSummary ?? data.weekSummary ?? data.todaySummary;

          return RefreshIndicator(
            onRefresh: () => _controller.load(silent: true),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Card(
                  color: AppConfig.PRIMARY_COLOR.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net earnings'
                          '${summary != null ? ' · this month' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConfig.formatCurrency(
                            summary?.netEarnings ??
                                data.earnings
                                    .fold<double>(
                                        0, (sum, e) => sum + e.netEarnings),
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConfig.SUCCESS_COLOR,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _StatTile(
                              label: 'Deliveries',
                              value: '${summary?.totalDeliveries ?? data.earnings.length}',
                            ),
                            _StatTile(
                              label: 'Tips',
                              value: AppConfig.formatCurrency(
                                summary?.totalTips ??
                                    data.earnings
                                        .fold<double>(
                                            0, (sum, e) => sum + e.tipAmount),
                              ),
                            ),
                            _StatTile(
                              label: 'Commission',
                              value: AppConfig.formatCurrency(
                                summary?.totalCommissions ??
                                    data.earnings.fold<double>(
                                        0,
                                        (sum, e) =>
                                            sum + e.platformCommission),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Recent deliveries',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (data.earnings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No earnings yet.'),
                    ),
                  )
                else
                  for (final e in data.earnings.take(20))
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.payments,
                            color: AppConfig.SUCCESS_COLOR),
                        title: Text(
                          '#${e.orderNumber}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${_shortDate(e.date)} · ${e.status.label}',
                        ),
                        trailing: Text(
                          '+${AppConfig.formatCurrency(e.netEarnings)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConfig.SUCCESS_COLOR,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _shortDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
