import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/dependency_injection.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/branch.dart';
import '../controllers/branch_controller.dart';

class BranchFormPage extends StatefulWidget {
  const BranchFormPage({super.key, this.branchId});

  final int? branchId;

  @override
  State<BranchFormPage> createState() => _BranchFormPageState();
}

class _BranchFormPageState extends State<BranchFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _opensAt = TextEditingController();
  final _closesAt = TextEditingController();
  late bool _active;

  bool get _isEdit => widget.branchId != null;
  BranchController get _controller => locator<BranchController>();

  @override
  void initState() {
    super.initState();
    _active = true;
    if (_isEdit) {
      _controller.loadBranches().then((_) {
        VendorBranch? b;
        for (final e in _controller.branches) {
          if (e.id == widget.branchId) {
            b = e;
            break;
          }
        }
        if (b != null) {
          _name.text = b.name;
          _address.text = b.address ?? '';
          _phone.text = b.phone ?? '';
          _opensAt.text = b.opensAt ?? '';
          _closesAt.text = b.closesAt ?? '';
          _active = b.isActive;
        }
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _opensAt.dispose();
    _closesAt.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'phone': _phone.text.trim(),
      'opens_at': _opensAt.text.trim(),
      'closes_at': _closesAt.text.trim(),
      'is_active': _active,
    };

    final result = _isEdit
        ? await _controller.update(widget.branchId!, payload)
        : await _controller.create(payload);

    if (!mounted) return;
    if (result != null) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFailureToMessage(_controller.failure ?? const Failure('Save failed')))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit branch' : 'New branch')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Branch name', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _opensAt,
                    decoration: const InputDecoration(labelText: 'Opens (HH:mm)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _closesAt,
                    decoration: const InputDecoration(labelText: 'Closes (HH:mm)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Open'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _controller.isMutating ? null : _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
