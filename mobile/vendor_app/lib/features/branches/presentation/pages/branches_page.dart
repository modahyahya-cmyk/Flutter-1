import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/app_config.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../core/errors/failures.dart';
import '../controllers/branch_controller.dart';

class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key});

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  BranchController get _controller => locator<BranchController>();

  @override
  void initState() {
    super.initState();
    _controller.loadBranches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Branches')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/branches/new'),
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (_controller.failure != null && _controller.branches.isEmpty) {
            return Center(child: Text(mapFailureToMessage(_controller.failure!)));
          }
          if (_controller.branches.isEmpty) return const Center(child: Text('No branches yet'));
          return RefreshIndicator(
            onRefresh: _controller.loadBranches,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _controller.branches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final b = _controller.branches[i];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.storefront_outlined, color: AppConfig.PRIMARY_COLOR),
                    title: Text(b.name),
                    subtitle: Text(b.address ?? b.phone ?? '—'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!b.isActive) const Chip(label: Text('Closed')),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => context.push('/branches/${b.id}/edit'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
