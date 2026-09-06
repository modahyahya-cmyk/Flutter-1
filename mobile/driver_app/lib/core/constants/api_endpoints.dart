/// Driver app API endpoint paths (relative to [AppConfig.BASE_API_URL]).
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String driverLogin = '/driver/auth/login';
  static const String driverLogout = '/driver/auth/logout';
  static const String driverProfile = '/driver/profile';
  static const String driverRegister = '/driver/auth/register';

  // Deliveries
  static const String driverDeliveries = '/driver/deliveries';
  static String deliveryDetail(String id) => '/driver/deliveries/$id';
  static String deliveryAccept(String id) => '/driver/deliveries/$id/accept';
  static String deliveryStatus(String id) => '/driver/deliveries/$id/status';
  static String deliveryComplete(String id) => '/driver/deliveries/$id/complete';
  static const String deliveriesSync = '/driver/deliveries/sync';

  // Location
  static const String locationBatch = '/driver/location/batch';
  static String locationUpload(String deliveryId) => '/driver/location/$deliveryId';

  // Earnings
  static const String driverEarnings = '/driver/earnings';
  static const String driverEarningsSync = '/driver/earnings/sync';
}
