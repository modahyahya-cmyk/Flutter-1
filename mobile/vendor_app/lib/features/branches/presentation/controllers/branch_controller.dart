import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/branch.dart';
import '../../domain/usecases/create_branch_usecase.dart';
import '../../domain/usecases/get_branches_usecase.dart';
import '../../domain/usecases/update_branch_usecase.dart';

class BranchController extends ChangeNotifier {
  BranchController({
    required this.getBranchesUseCase,
    required this.createBranchUseCase,
    required this.updateBranchUseCase,
  });

  final GetBranchesUseCase getBranchesUseCase;
  final CreateBranchUseCase createBranchUseCase;
  final UpdateBranchUseCase updateBranchUseCase;

  bool isLoading = false;
  bool isMutating = false;
  List<VendorBranch> branches = [];
  Failure? failure;

  Future<void> loadBranches() async {
    isLoading = true;
    failure = null;
    notifyListeners();

    try {
      branches = await getBranchesUseCase();
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<VendorBranch?> create(Map<String, dynamic> payload) =>
      _mutate(() => createBranchUseCase(payload));

  Future<VendorBranch?> update(int id, Map<String, dynamic> payload) =>
      _mutate(() => updateBranchUseCase(id, payload));

  Future<VendorBranch?> _mutate(Future<VendorBranch> Function() action) async {
    isMutating = true;
    failure = null;
    notifyListeners();

    try {
      final result = await action();
      final index = branches.indexWhere((b) => b.id == result.id);
      if (index >= 0) {
        branches[index] = result;
      } else {
        branches.add(result);
      }
      return result;
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
      return null;
    } catch (_) {
      failure = const Failure.unknown();
      return null;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }
}
