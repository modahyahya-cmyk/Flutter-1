import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
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
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/reset_session_usecase.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';

import '../features/video_feed/data/datasources/video_remote_datasource.dart';
import '../features/video_feed/data/repositories/video_repository_impl.dart';
import '../features/video_feed/domain/repositories/video_repository.dart';
import '../features/video_feed/domain/usecases/get_videos_usecase.dart';
import '../features/video_feed/domain/usecases/like_video_usecase.dart';
import '../features/video_feed/domain/usecases/share_video_usecase.dart';
import '../features/video_feed/presentation/controllers/video_feed_controller.dart';

import '../features/products/data/datasources/product_remote_datasource.dart';
import '../features/products/data/repositories/product_repository_impl.dart';
import '../features/products/domain/repositories/product_repository.dart';
import '../features/products/domain/usecases/get_product_detail_usecase.dart';
import '../features/products/domain/usecases/get_products_usecase.dart';
import '../features/products/presentation/controllers/product_controller.dart';

import '../features/cart/data/datasources/cart_local_datasource.dart';
import '../features/cart/data/datasources/cart_remote_datasource.dart';
import '../features/cart/data/repositories/cart_repository_impl.dart';
import '../features/cart/domain/repositories/cart_repository.dart';
import '../features/cart/domain/usecases/add_to_cart_usecase.dart';
import '../features/cart/domain/usecases/clear_cart_usecase.dart';
import '../features/cart/domain/usecases/get_cart_usecase.dart';
import '../features/cart/domain/usecases/remove_from_cart_usecase.dart';
import '../features/cart/presentation/controllers/cart_controller.dart';

import '../features/subscriptions/data/datasources/subscription_remote_datasource.dart';
import '../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../features/subscriptions/domain/repositories/subscription_repository.dart';
import '../features/subscriptions/domain/usecases/cancel_subscription_usecase.dart';
import '../features/subscriptions/domain/usecases/get_plans_usecase.dart';
import '../features/subscriptions/domain/usecases/subscribe_usecase.dart';
import '../features/subscriptions/presentation/controllers/subscription_controller.dart';

import '../features/orders/data/datasources/order_remote_datasource.dart';
import '../features/orders/data/repositories/order_repository_impl.dart';
import '../features/orders/domain/repositories/order_repository.dart';
import '../features/orders/domain/usecases/create_order_usecase.dart';
import '../features/orders/domain/usecases/get_orders_usecase.dart';
import '../features/orders/domain/usecases/track_order_usecase.dart';
import '../features/orders/presentation/controllers/order_controller.dart';

import '../features/map/presentation/controllers/map_controller.dart';

final getIt = GetIt.instance;

/// Sets up service locator registrations.
///
/// Optional overrides can be provided for testability:
/// - [sharedPreferencesOverride] to inject a test SharedPreferences instance
/// - [flutterSecureStorageOverride] to inject a FlutterSecureStorage instance
/// - [secureStorageOverride] to inject the app's SecureStorage abstraction
/// - [connectivityOverride] to inject a test Connectivity implementation
/// - [dioOverride] to inject a Dio instance (preconfigured/fake)
/// - [apiClientOverride] to inject an ApiClient instance (preconfigured/fake)
Future<void> setupDependencyInjection({
  SharedPreferences? sharedPreferencesOverride,
  FlutterSecureStorage? flutterSecureStorageOverride,
  SecureStorage? secureStorageOverride,
  Connectivity? connectivityOverride,
  Dio? dioOverride,
  ApiClient? apiClientOverride,
}) async {
  // Ensure a clean locator state when called (useful for tests).
  await getIt.reset();

  final sharedPreferences =
      sharedPreferencesOverride ?? await SharedPreferences.getInstance();

  getIt.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );

  if (secureStorageOverride != null) {
    // If caller provided a SecureStorage implementation, register it
    // directly and skip FlutterSecureStorage registration.
    getIt.registerLazySingleton<SecureStorage>(() => secureStorageOverride);
  } else {
    // Register the FlutterSecureStorage (allow override for tests)
    getIt.registerLazySingleton<FlutterSecureStorage>(
      () => flutterSecureStorageOverride ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              encryptedSharedPreferences: true,
            ),
          ),
    );

    getIt.registerLazySingleton<SecureStorage>(
      () => SecureStorageImpl(
        secureStorage: getIt<FlutterSecureStorage>(),
      ),
    );
  }

  // Connectivity: allow override for tests
  getIt.registerLazySingleton<Connectivity>(
    () => connectivityOverride ?? Connectivity(),
  );

  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectivity: getIt<Connectivity>(),
    ),
  );

  getIt.registerLazySingleton<LocalStorage>(
    () => LocalStorageImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // If an ApiClient override is provided, use it and skip Dio setup.
  if (apiClientOverride != null) {
    getIt.registerLazySingleton<ApiClient>(() => apiClientOverride);
  } else {
    // Register Dio (allow override for tests)
    getIt.registerLazySingleton<Dio>(() {
      final dio = dioOverride ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.BASE_API_URL,
              connectTimeout: AppConfig.API_CONNECTION_TIMEOUT,
              receiveTimeout: AppConfig.API_RECEIVE_TIMEOUT,
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );

      dio.interceptors.addAll([
        AuthInterceptor(
          secureStorage: getIt<SecureStorage>(),
        ),
        LoggingInterceptor(),
        // On 401/403 the session is expired/revoked: force a local sign-out so
        // the router's auth guard returns the user to login. No network call —
        // the token is already invalid.
        ErrorInterceptor(
          onUnauthorized: () => getIt<AuthController>().forceLogout(),
        ),
      ]);

      return dio;
    });

    // Register ApiClient using the registered Dio
    getIt.registerLazySingleton<ApiClient>(
      () => ApiClient(dio: getIt<Dio>()),
    );
  }

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      localStorage: getIt<LocalStorage>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(
      repository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(
      repository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(
      repository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(
      repository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<ResetSessionUseCase>(
    () => ResetSessionUseCase(
      repository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<AuthController>(
    () => AuthController(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      resetSessionUseCase: getIt<ResetSessionUseCase>(),
    ),
  );

  getIt.registerLazySingleton<VideoRemoteDataSource>(
    () => VideoRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(
      remoteDataSource: getIt<VideoRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<GetVideosUseCase>(
    () => GetVideosUseCase(
      repository: getIt<VideoRepository>(),
    ),
  );

  getIt.registerLazySingleton<LikeVideoUseCase>(
    () => LikeVideoUseCase(
      repository: getIt<VideoRepository>(),
    ),
  );

  getIt.registerLazySingleton<ShareVideoUseCase>(
    () => ShareVideoUseCase(
      repository: getIt<VideoRepository>(),
    ),
  );

  getIt.registerLazySingleton<VideoFeedController>(
    () => VideoFeedController(
      getVideosUseCase: getIt<GetVideosUseCase>(),
      likeVideoUseCase: getIt<LikeVideoUseCase>(),
      shareVideoUseCase: getIt<ShareVideoUseCase>(),
    ),
  );

  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: getIt<ProductRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(
      repository: getIt<ProductRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetProductDetailUseCase>(
    () => GetProductDetailUseCase(
      repository: getIt<ProductRepository>(),
    ),
  );

  getIt.registerLazySingleton<ProductController>(
    () => ProductController(
      getProductsUseCase: getIt<GetProductsUseCase>(),
      getProductDetailUseCase: getIt<GetProductDetailUseCase>(),
    ),
  );

  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSource(
      localStorage: getIt<LocalStorage>(),
    ),
  );

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      remoteDataSource: getIt<CartRemoteDataSource>(),
      localDataSource: getIt<CartLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<AddToCartUseCase>(
    () => AddToCartUseCase(
      repository: getIt<CartRepository>(),
    ),
  );

  getIt.registerLazySingleton<RemoveFromCartUseCase>(
    () => RemoveFromCartUseCase(
      repository: getIt<CartRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetCartUseCase>(
    () => GetCartUseCase(
      repository: getIt<CartRepository>(),
    ),
  );

  getIt.registerLazySingleton<ClearCartUseCase>(
    () => ClearCartUseCase(
      repository: getIt<CartRepository>(),
    ),
  );

  getIt.registerLazySingleton<CartController>(
    () => CartController(
      addToCartUseCase: getIt<AddToCartUseCase>(),
      removeFromCartUseCase: getIt<RemoveFromCartUseCase>(),
      getCartUseCase: getIt<GetCartUseCase>(),
      clearCartUseCase: getIt<ClearCartUseCase>(),
    ),
  );

  getIt.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      remoteDataSource: getIt<SubscriptionRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<GetPlansUseCase>(
    () => GetPlansUseCase(
      repository: getIt<SubscriptionRepository>(),
    ),
  );

  getIt.registerLazySingleton<SubscribeUseCase>(
    () => SubscribeUseCase(
      repository: getIt<SubscriptionRepository>(),
    ),
  );

  getIt.registerLazySingleton<CancelSubscriptionUseCase>(
    () => CancelSubscriptionUseCase(
      repository: getIt<SubscriptionRepository>(),
    ),
  );

  getIt.registerLazySingleton<SubscriptionController>(
    () => SubscriptionController(
      getPlansUseCase: getIt<GetPlansUseCase>(),
      subscribeUseCase: getIt<SubscribeUseCase>(),
      cancelSubscriptionUseCase: getIt<CancelSubscriptionUseCase>(),
    ),
  );

  getIt.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: getIt<OrderRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<CreateOrderUseCase>(
    () => CreateOrderUseCase(
      repository: getIt<OrderRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(
      repository: getIt<OrderRepository>(),
    ),
  );

  getIt.registerLazySingleton<TrackOrderUseCase>(
    () => TrackOrderUseCase(
      repository: getIt<OrderRepository>(),
    ),
  );

  getIt.registerLazySingleton<OrderController>(
    () => OrderController(
      createOrderUseCase: getIt<CreateOrderUseCase>(),
      getOrdersUseCase: getIt<GetOrdersUseCase>(),
      trackOrderUseCase: getIt<TrackOrderUseCase>(),
    ),
  );

  getIt.registerLazySingleton<MapProviderController>(
    () => MapProviderController(),
  );
}
