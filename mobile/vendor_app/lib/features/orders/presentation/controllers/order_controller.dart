import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/accept_order_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/reject_order_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';

class OrderController extends ChangeNotifier {
  OrderController({
    required this.getOrdersUseCase,
    required this.acceptOrderUseCase,
    required this.rejectOrderUseCase,
    required this.updateOrderStatusUseCase,
  });

  final GetOrdersUseCase getOrdersUseCase;
  final AcceptOrderUseCase acceptOrderUseCase;
  final RejectOrderUseCase rejectOrderUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  bool isLoading = false;
  bool isMutating = false;
  List<Order> orders = [];
  Order? selectedOrder;
  Failure? failure;

  Future<void> loadOrders({String? status}) async {
    isLoading = true;
    failure = null;
    notifyListeners();

    try {
      orders = await getOrdersUseCase(status: status);
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<Order?> accept(int orderId) async {
    return _mutate(() => acceptOrderUseCase(orderId));
  }

  Future<Order?> reject(int orderId, String reason) async {
    return _mutate(() => rejectOrderUseCase(orderId, reason));
  }

  Future<Order?> advanceStatus(int orderId, OrderStatus status) async {
    return _mutate(() => updateOrderStatusUseCase(orderId, status));
  }

  Future<void> selectOrder(Order order) async {
    selectedOrder = order;
    notifyListeners();
  }

  Future<Order?> _mutate(Future<Order> Function() action) async {
    isMutating = true;
    failure = null;
    notifyListeners();

    try {
      final updated = await action();
      final index = orders.indexWhere((o) => o.id == updated.id);
      if (index >= 0) {
        orders[index] = updated;
      }
      if (selectedOrder?.id == updated.id) {
        selectedOrder = updated;
      }
      return updated;
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
