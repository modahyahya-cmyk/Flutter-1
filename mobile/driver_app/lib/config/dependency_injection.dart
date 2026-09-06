import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/network/interceptors/auth_interceptor.dart';
import '../core/network/interceptors/logging_interceptor.dart';
import '../core/network/interceptors/error_interceptor.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/secure_storage.dart';
import '../core/storage/isar_service.dart';

// Local Database Models
import '../core/storage/models/delivery_local_model.dart';
import '../core/storage/models/location_log_model.dart';
import '../core/storage/models/earnings_local_model.dart';
import '../core/storage/models/sync_queue_model.dart';

// Features - Auth
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';

// Features - Deliveries
import '../features/deliveries/data/datasources/delivery_remote_datasource.dart';
import '../features/deliveries/data/datasources/delivery_local_datasource.dart';
import '../features/deliveries/data/repositories/delivery_repository_impl.dart';
import '../features/deliveries/domain/repositories/delivery_repository.dart';
import '../features/deliveries/domain/usecases/get_deliveries_usecase.dart';
import '../features/deliveries/domain/usecases/accept_delivery_usecase.dart';
import '../features/deliveries/domain/usecases/complete_delivery_usecase.dart';
import '../features/deliveries/domain/usecases/sync_offline_deliveries_usecase.dart';
import '../features/deliveries/presentation/controllers/delivery_controller.dart';

// Features - Location Tracking
import '../features/location_tracking/data/datasources/location_datasource.dart';
import '../features/location_tracking/data/datasources/background_location_service.dart';
import '../features/location_tracking/data/repositories/location_repository_impl.dart';
import '../features/location_tracking/domain/repositories/location_repository.dart';
import '../features/location_tracking/domain/usecases/start_tracking_usecase.dart';
import '../features/location_tracking/domain/usecases/stop_tracking_usecase.dart';
import '../features/location_tracking/domain/usecases/upload_location_usecase.dart';
import '../features/location_tracking/presentation/controllers/location_controller.dart';

// Features - Earnings
import '../features/earnings/data/datasources/earnings_remote_datasource.dart';
import '../features/earnings/data/datasources/earnings_local_datasource.dart';
import '../features/earnings/data/repositories/earnings_repository_impl.dart';
import '../features/earnings/domain/repositories/earnings_repository.dart';
import '../features/earnings/domain/usecases/get_earnings_usecase.dart';
import '../features/earnings/domain/usecases/sync_earnings_usecase.dart';
import '../features/earnings/presentation/controllers/earnings_controller.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // =========================================================================
  // EXTERNAL DEPENDENCIES
  // =========================================================================

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker());

  getIt.registerLazySingleton<GeolocatorPlatform>(() => GeolocatorPlatform.instance);

  // =========================================================================
  // ISAR LOCAL DATABASE
  // =========================================================================

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      DeliveryLocalModelSchema,
      LocationLogModelSchema,
      EarningsLocalModelSchema,
      SyncQueueModelSchema,
    ],
    directory: dir.path,
    name: 'driver_app_db',
  );

  getIt.registerLazySingleton<Isar>(() => isar);
  getIt.registerLazySingleton<IsarService>(() => IsarService(isar: isar));

  // =========================================================================
  // CORE SERVICES
  // =========================================================================

  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectivity: getIt<Connectivity>(),
      internetChecker: getIt<InternetConnectionChecker>(),
    ),
  );

  getIt.registerLazySingleton<LocalStorage>(
    () => LocalStorageImpl(sharedPreferences: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<SecureStorage>(
    () => SecureStorageImpl(secureStorage: getIt<FlutterSecureStorage>()),
  );

  // =========================================================================
  // HTTP CLIENT
  // =========================================================================

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.BASE_API_URL,
      connectTimeout: AppConfig.API_CONNECTION_TIMEOUT,
      receiveTimeout: AppConfig.API_RECEIVE_TIMEOUT,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.addAll([
      AuthInterceptor(secureStorage: getIt<SecureStorage>()),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);

    return dio;
  });

  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));

  // =========================================================================
  // AUTH FEATURE
  // =========================================================================

  getIt.registerLazySingleton<AuthRemoteDataSourceImpl>(
    () => AuthRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AuthLocalDataSourceImpl>(
    () => AuthLocalDataSourceImpl(
      localStorage: getIt<LocalStorage>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSourceImpl>(),
      localDataSource: getIt<AuthLocalDataSourceImpl>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton(() => LoginUseCase(repository: getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(repository: getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(repository: getIt<AuthRepository>()));

  getIt.registerLazySingleton<AuthController>(
    () => AuthController(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  // =========================================================================
  // DELIVERIES FEATURE
  // =========================================================================

  getIt.registerLazySingleton<DeliveryRemoteDataSourceImpl>(
    () => DeliveryRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<DeliveryLocalDataSourceImpl>(
    () => DeliveryLocalDataSourceImpl(isarService: getIt<IsarService>()),
  );

  getIt.registerLazySingleton<DeliveryRepository>(
    () => DeliveryRepositoryImpl(
      remoteDataSource: getIt<DeliveryRemoteDataSourceImpl>(),
      localDataSource: getIt<DeliveryLocalDataSourceImpl>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton(() => GetDeliveriesUseCase(repository: getIt<DeliveryRepository>()));
  getIt.registerLazySingleton(() => AcceptDeliveryUseCase(repository: getIt<DeliveryRepository>()));
  getIt.registerLazySingleton(() => CompleteDeliveryUseCase(repository: getIt<DeliveryRepository>()));
  getIt.registerLazySingleton(() => SyncOfflineDeliveriesUseCase(repository: getIt<DeliveryRepository>()));

  getIt.registerLazySingleton<DeliveryController>(
    () => DeliveryController(
      getDeliveriesUseCase: getIt<GetDeliveriesUseCase>(),
      acceptDeliveryUseCase: getIt<AcceptDeliveryUseCase>(),
      completeDeliveryUseCase: getIt<CompleteDeliveryUseCase>(),
      syncOfflineDeliveriesUseCase: getIt<SyncOfflineDeliveriesUseCase>(),
      repository: getIt<DeliveryRepository>(),
      locationController: getIt<LocationController>(),
    ),
  );

  // =========================================================================
  // LOCATION TRACKING FEATURE
  // =========================================================================

  getIt.registerLazySingleton<LocationDataSourceImpl>(
    () => LocationDataSourceImpl(geolocator: getIt<GeolocatorPlatform>()),
  );

  getIt.registerSingleton<BackgroundLocationService>(
    BackgroundLocationService(
      isarService: getIt<IsarService>(),
      apiClient: getIt<ApiClient>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      locationDataSource: getIt<LocationDataSourceImpl>(),
      backgroundService: getIt<BackgroundLocationService>(),
      isarService: getIt<IsarService>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton(() => StartTrackingUseCase(repository: getIt<LocationRepository>()));
  getIt.registerLazySingleton(() => StopTrackingUseCase(repository: getIt<LocationRepository>()));
  getIt.registerLazySingleton(() => UploadLocationUseCase(repository: getIt<LocationRepository>()));

  getIt.registerLazySingleton<LocationController>(
    () => LocationController(
      startTrackingUseCase: getIt<StartTrackingUseCase>(),
      stopTrackingUseCase: getIt<StopTrackingUseCase>(),
      uploadLocationUseCase: getIt<UploadLocationUseCase>(),
    ),
  );

  // =========================================================================
  // EARNINGS FEATURE
  // =========================================================================

  getIt.registerLazySingleton<EarningsRemoteDataSourceImpl>(
    () => EarningsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<EarningsLocalDataSourceImpl>(
    () => EarningsLocalDataSourceImpl(isarService: getIt<IsarService>()),
  );

  getIt.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(
      remoteDataSource: getIt<EarningsRemoteDataSourceImpl>(),
      localDataSource: getIt<EarningsLocalDataSourceImpl>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton(() => GetEarningsUseCase(repository: getIt<EarningsRepository>()));
  getIt.registerLazySingleton(() => SyncEarningsUseCase(repository: getIt<EarningsRepository>()));

  getIt.registerLazySingleton<EarningsController>(() => EarningsController());
}
