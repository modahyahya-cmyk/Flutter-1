/// Vendor app API endpoint paths (relative to [AppConfig.BASE_API_URL]).
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String vendorLogin = '/vendor/auth/login';
  static const String vendorLogout = '/vendor/auth/logout';
  static const String vendorProfile = '/vendor/profile';
  static const String vendorRegister = '/vendor/auth/register';

  // Orders
  static const String vendorOrders = '/vendor/orders';
  static String orderDetail(int id) => '/vendor/orders/$id';
  static String orderStatus(int id) => '/vendor/orders/$id/status';

  // Products
  static const String vendorProducts = '/vendor/products';
  static String productDetail(int id) => '/vendor/products/$id';
  static String productToggle(int id) => '/vendor/products/$id/toggle-active';

  // Branches
  static const String vendorBranches = '/vendor/branches';
  static String branchDetail(int id) => '/vendor/branches/$id';

  // Earnings
  static const String vendorEarnings = '/vendor/earnings';
}
