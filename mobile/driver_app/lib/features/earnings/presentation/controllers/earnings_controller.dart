import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/earnings.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../../domain/usecases/get_earnings_usecase.dart';

class EarningsState extends Equatable {
  const EarningsState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  final bool isLoading;
  final String? error;
  final EarningsData? data;

  /// [error] is cleared whenever it is not supplied (success paths reset it);
  /// [data] keeps the previous value when null is passed so the UI never
  /// flickers back to an empty state during background refreshes.
  EarningsState copyWith({
    bool? isLoading,
    String? error,
    EarningsData? data,
  }) {
    return EarningsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, data];
}

/// Driver earnings (delivery fee + tip − platform commission) loaded from
/// the backend and merged with the offline Isar cache via the use case.
class EarningsController extends Cubit<EarningsState> {
  EarningsController({required this.getEarningsUseCase})
      : super(const EarningsState(isLoading: true));

  final GetEarningsUseCase getEarningsUseCase;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(isLoading: true));
    }

    final result =
        await getEarningsUseCase(const GetEarningsParams(includeOffline: true));

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (data) => emit(state.copyWith(isLoading: false, data: data)),
    );
  }
}
