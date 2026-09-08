import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_config.dart';

import '../core/network/api_client.dart';
import '../core/network/interceptors/auth_interceptor.dart';
import '../core/network/interceptors/error_interceptor.dart';
import '../core/network/interceptors/logging_interceptor.dart';
import '../core/network/network_info.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/secure_storage.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/branches/data/datasources/branch_remote_datasource.dart';
import '../features/branches/data/repositories/branch_repository_impl.dart';
import '../features/branches/domain/repositories/branch_repository.dart';
import '../features/branches/domain/usecases/create_branch_usecase.dart';
import '../features/branches/domain/usecases/get_branches_usecase.dart';
import '../features/branches/domain/usecases/update_branch_usecase.dart';
import '../features/branches/presentation/controllers/branch_controller.dart';
import '../features/earnings/data/datasources/earnings_remote_datasource.dart';
import '../features/earnings/data/repositories/earnings_repository_impl.dart';
import '../features/earnings/domain/repositories/earnings_repository.dart';
import '../features/earnings/domain/usecases/get_earnings_summary_usecase.dart';
import '../features/earnings/presentation/controllers/earnings_controller.dart';
import '../features/inventory/data/datasources/inventory_local_datasource.dart';
import '../features/inventory/data/datasources/inventory_remote_datasource.dart';
import '../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../features/inventory/domain/repositories/inventory_repository.dart';
import '../features/inventory/domain/usecases/adjust_stock_usecase.dart';
import '../features/inventory/domain/usecases/get_inventory_usecase.dart';
import '../features/inventory/domain/usecases/sync_inventory_usecase.dart';
import '../features/inventory/presentation/controllers/inventory_controller.dart';
import '../features/orders/data/datasources/order_remote_datasource.dart';
import '../features/orders/data/repositories/order_repository_impl.dart';
import '../features/orders/domain/repositories/order_repository.dart';
import '../features/orders/domain/usecases/accept_order_usecase.dart';
import '../features/orders/domain/usecases/get_orders_usecase.dart';
import '../features/orders/domain/usecases/reject_order_usecase.dart';
import '../features/orders/domain/usecases/update_order_status_usecase.dart';
import '../features/orders/presentation/controllers/order_controller.dart';
import '../features/products/data/datasources/product_remote_datasource.dart';
import '../features/products/data/repositories/product_repository_impl.dart';
import '../features/products/domain/repositories/product_repository.dart';
import '../features/products/domain/usecases/create_product_usecase.dart';
import '../features/products/domain/usecases/delete_product_usecase.dart';
import '../features/products/domain/usecases/get_products_usecase.dart';
import '../features/products/domain/usecases/update_product_usecase.dart';
import '../features/products/presentation/controllers/product_controller.dart';
import '../features/thermal_printing/data/datasources/bluetooth_datasource.dart';
import '../features/thermal_printing/data/repositories/printer_repository_impl.dart';
import '../features/thermal_printing/domain/repositories/print_service.dart';
import '../features/thermal_printing/domain/repositories/printer_repository.dart';
import '../features/thermal_printing/domain/usecases/connect_printer_usecase.dart';
import '../features/thermal_printing/domain/usecases/discover_printers_usecase.dart';
import '../features/thermal_printing/domain/usecases/print_order_usecase.dart';
import '../features/thermal_printing/domain/usecases/test_print_usecase.dart';
import '../features/thermal_printing/presentation/controllers/printer_controller.dart';

final GetIt locator = GetIt.instance;

/// Bootstraps the entire vendor / POS application object graph.
/// Call once from `main()` before `runApp`.
Future<void> setupDependencyInjection() async {
  // ---------------------------------------------------------------------------
  // Core platform singletons
  // ---------------------------------------------------------------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  locator.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  locator.registerSingleton<Connectivity>(Connectivity());
  locator.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker(),
  );

  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------
  locator.registerLazySingleton<LocalStorage>(() => LocalStorageImpl(sharedPreferences: locator()));
  locator.registerLazySingleton<SecureStorage>(() => SecureStorageImpl(secureStorage: locator()));

  // ---------------------------------------------------------------------------
  // Network info
  // ---------------------------------------------------------------------------
  locator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(
        connectivity: locator(),
        internetChecker: locator(),
      ));

  // ---------------------------------------------------------------------------
  // Dio + interceptors + ApiClient
  // ---------------------------------------------------------------------------
  locator.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.BASE_API_URL,
      connectTimeout: AppConfig.API_CONNECTION_TIMEOUT,
      receiveTimeout: AppConfig.API_CONNECTION_TIMEOUT,
      sendTimeout: AppConfig.API_CONNECTION_TIMEOUT,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));
    dio.interceptors.add(AuthInterceptor(secureStorage: locator()));
    if (AppConfig.ENABLE_API_LOGGING) {
      dio.interceptors.add(LoggingInterceptor());
    }
    dio.interceptors.add(ErrorInterceptor());
    return dio;
  });
  locator.registerLazySingleton<ApiClient>(() => ApiClient(dio: locator()));

  // ---------------------------------------------------------------------------
  // Feature: Auth
  // ---------------------------------------------------------------------------
  locator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(locator()));
  locator.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(localStorage: locator(), secureStorage: locator()));
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: locator(),
        localDataSource: locator(),
        networkInfo: locator(),
      ));
  locator.registerLazySingleton<LoginUseCase>(() => LoginUseCase(repository: locator()));
  locator.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(repository: locator()));
  locator.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(repository: locator()));
  locator.registerLazySingleton<AuthController>(() => AuthController(
        loginUseCase: locator(),
        logoutUseCase: locator(),
        getCurrentUserUseCase: locator(),
      ));

  // ---------------------------------------------------------------------------
  // Feature: Orders
  // ---------------------------------------------------------------------------
  locator.registerLazySingleton<OrderRemoteDataSource>(() => OrderRemoteDataSource(locator()));
  locator.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(
        remoteDataSource: locator(),
        networkInfo: locator(),
      ));
  locator.registerLazySingleton<GetOrdersUseCase>(() => GetOrdersUseCase(repository: locator()));
  locator.registerLazySingleton<AcceptOrderUseCase>(() => AcceptOrderUseCase(repository: locator()));
  locator.registerLazySingleton<RejectOrderUseCase>(() => RejectOrderUseCase(repository: locator()));
  locator.registerLazySingleton<UpdateOrderStatusUseCase>(
      () => UpdateOrderStatusUseCase(repository: locator()));
  locator.registerLazySingleton<OrderController>(() => OrderController(
        getOrdersUseCase: locator(),
        acceptOrderUseCase: locator(),
        rejectOrderUseCase: locator(),
        updateOrderStatusUseCase: locator(),
      ));

  // ---------------------------------------------------------------------------
  // Feature: Products
  // ---------------------------------------------------------------------------
  locator.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSource(locator()));
  locator.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(
        remoteDataSource: locator(),
        networkInfo: locator(),
      ));
  locator.registerLazySingleton<GetProductsUseCase>(() => GetProductsUseCase(repository: locator()));
  locator.registerLazySingleton<CreateProductUseCase>(
      () => CreateProductUseCase(repository: locator()));
  locator.registerLazySingleton<UpdateProductUseCase>(
      () => UpdateProductUseCase(repository: locator()));
  locator.registerLazySingleton<DeleteProductUseCase>(
      () => DeleteProductUseCase(repository: locator()));
  locator.registerLazySingleton<ProductController>(() => ProductController(
        getProductsUseCase: locator(),
        createProductUseCase: locator(),
        updateProductUseCase: locator(),
        deleteProductUseCase: locator(),
      ));

  // ---------------------------------------------------------------------------
  // Feature: Inventory (offline-first)
  // ---------------------------------------------------------------------------
  locator.registerLazySingleton<InventoryRemoteDataSource>(
      () => InventoryRemoteDataSource(locator()));
  locator.registerLazySingleton<InventoryLocalDataSource>(
      () => InventoryLocalDataSource(locator()));
  locator.registerLazySingleton<InventoryRepository>(() => InventoryRepositoryImpl(
        remoteDataSource: locator(),
        localDataSource: locator(),
        networkInfo: locator(),
      ));
  locator.registerLazySingleton<GetInventoryUseCase>(
      () => GetInventoryUseCase(repository: locator()));
  locator.registerLazySingleton<AdjustStockUseCase>(
      () => AdjustStockUseCase(repository: locator()));
  locator.registerLazySingleton<SyncInventoryUseCase>(
      () => SyncInventoryUseCase(repository: locator()));
  locator.registerLazySingleton<InventoryController>(() => InventoryController(
        getInventoryUseCase: locator(),
        adjustStockUseCase: locator(),
        syncInventoryUseCase: locator(),
      ));

  // ---------------------------------------------------------------------------
  // Feature: Branches
  // ---------------------------------------------------------------------------
  locator.registerLazySingleton<BranchRemoteDataSource>(() => BranchRemoteDataSource(locator()));
  locator.registerLazySingleton<BranchRepository>(() => BranchRepositoryImpl(
        remoteDataSource: locator(),
        networkInfo: locator(),
      ));
  locator.registerLazySingleton<GetBranchesUseCase>(() => GetBranchesUseCase(repository: locator()));
  locator.registerLazySingleton<CreateBranchUseCase>(
      () => CreateBranchUseCase(repository: locator()));
  locator.registerLazySingleton<UpdateBranchUseCase>(
      () => UpdateBranchUseCase(repository: locator()));
  locator.registerLazySingleton<BranchController>(() => BranchController(
        getBranchesUseCase: locator(),
        createBranchUseCase: locator(),
        updateBranchUseCase: locator(),
      ));

  // ---------------------------------------------------------------------------
  // Feature: Thermal Printing (Bluetooth ESC/POS)
  // ---------------------------------------------------------------------------
  locator.registerLazySingleton<BluetoothDataSource>(() => BluetoothDataSource());
  locator.registerLazySingleton<PrintService>(() => PrintService(bluetoothDataSource: locator()));
  locator.registerLazySingleton<PrinterRepository>(() => PrinterRepositoryImpl(
        bluetoothDataSource: locator(),
        localStorage: locator(),
      ));
  locator.registerLazySingleton<DiscoverPrintersUseCase>(
      () => DiscoverPrintersUseCase(repository: locator()));
  locator.registerLazySingleton<ConnectPrinterUseCase>(
      () => ConnectPrinterUseCase(repository: locator()));
  locator.registerLazySingleton<PrintOrderUseCase>(() => PrintOrderUseCase(
        repository: locator(),
        printService: locator(),
      ));
  locator.registerLazySingleton<TestPrintUseCase>(() => TestPrintUseCase(
        repository: locator(),
        printService: locator(),
      ));
  locator.registerLazySingleton<PrinterController>(() => PrinterController(
        discoverPrintersUseCase: locator(),
        connectPrinterUseCase: locator(),
        printOrderUseCase: locator(),
        testPrintUseCase: locator(),
      ));

  // ---------------------------------------------------------------------------
  // Feature: Earnings
  // ---------------------------------------------------------------------------
  locator.registerLazySingleton<EarningsRemoteDataSource>(
      () => EarningsRemoteDataSource(locator()));
  locator.registerLazySingleton<EarningsRepository>(() => EarningsRepositoryImpl(
        remoteDataSource: locator(),
        networkInfo: locator(),
      ));
  locator.registerLazySingleton<GetEarningsSummaryUseCase>(
      () => GetEarningsSummaryUseCase(repository: locator()));
  locator.registerLazySingleton<EarningsController>(
      () => EarningsController(getEarningsSummaryUseCase: locator()));
}
