import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/track_order_usecase.dart';

class OrderController extends ChangeNotifier {
  OrderController({
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
    required this.trackOrderUseCase,
  });

  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final TrackOrderUseCase trackOrderUseCase;

  bool isLoading = false;
  List<Order> orders = [];
  Order? trackedOrder;
  Failure? failure;

  Future<void> loadOrders() async {
    isLoading = true;
    failure = null;
    notifyListeners();

    try {
      orders = await getOrdersUseCase();
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<Order?> create(Map<String, dynamic> payload) async {
    try {
      final order = await createOrderUseCase(payload);
      orders.insert(0, order);
      notifyListeners();
      return order;
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
      notifyListeners();
      return null;
    }
  }

  Future<void> track(int orderId) async {
    try {
      trackedOrder = await trackOrderUseCase(orderId);
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    }
    notifyListeners();
  }
}
