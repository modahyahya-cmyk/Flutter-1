import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/subscription_plan.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionPlansPage extends StatefulWidget {
  const SubscriptionPlansPage({super.key});

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
  final _controller = getIt<SubscriptionController>();

  @override
  void initState() {
    super.initState();
    _controller.loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plans')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (_controller.failure != null) {
            return Center(child: Text(mapFailureToMessage(_controller.failure!)));
          }
          if (_controller.plans.isEmpty) return const Center(child: Text('No plans available.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.plans.length,
            itemBuilder: (context, i) {
              final SubscriptionPlan plan = _controller.plans[i];
              return _PlanCard(
                plan: plan,
                subscribing: _controller.isSubscribing,
                onSubscribe: () async {
                  final ok = await _controller.subscribe(plan.code);
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Subscription activated.')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.subscribing, required this.onSubscribe});

  final SubscriptionPlan plan;
  final bool subscribing;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: plan.featured
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppConfig.PRIMARY_COLOR, width: 2),
            )
          : null,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                if (plan.featured)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppConfig.PRIMARY_COLOR,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Popular',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppConfig.formatCurrency(plan.price),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plan.features
                  .map((f) => Chip(label: Text(f, style: const TextStyle(fontSize: 12))))
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: subscribing ? null : onSubscribe,
              child: Text(
                plan.price == 0 ? 'Get Started' : 'Subscribe',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
