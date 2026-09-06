/// API endpoint paths relative to [AppConfig.BASE_API_URL].
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String customerRegister = '/customer/auth/register';
  static const String customerLogin = '/customer/auth/login';
  static const String customerLogout = '/customer/auth/logout';
  static const String vendorLogin = '/vendor/auth/login';
  static const String driverLogin = '/driver/auth/login';
  static const String adminLogin = '/admin/auth/login';

  // Profile
  static const String profile = '/customer/profile';
  static const String changePassword = '/customer/profile/password';

  // Products
  static const String products = '/products';
  static const String featuredProducts = '/products/featured';
  static const String bestSellers = '/products/best-sellers';
  static String productDetail(int id) => '/products/$id';

  // Cart
  static const String cart = '/customer/cart';
  static const String cartItems = '/customer/cart/items';
  static String cartItem(int id) => '/customer/cart/items/$id';

  // Orders
  static const String orders = '/customer/orders';
  static String orderDetail(int id) => '/customer/orders/$id';
  static String cancelOrder(int id) => '/customer/orders/$id/cancel';

  // Subscription
  static const String subscriptionPlans = '/customer/subscriptions/plans';
  static const String subscriptions = '/customer/subscriptions';
  static const String mySubscription = '/customer/subscriptions/me';
  static String cancelSubscription(int id) => '/customer/subscriptions/$id/cancel';

  // Videos
  static const String videos = '/videos';
  static String videoDetail(int id) => '/videos/$id';
  static String videoLike(int id) => '/customer/videos/$id/like';

  // Vendor
  static const String vendorProducts = '/vendor/products';
  static const String vendorOrders = '/vendor/orders';
  static const String vendorBranches = '/vendor/branches';

  // Driver
  static const String driverDeliveries = '/driver/deliveries';
  static const String driverAvailable = '/driver/deliveries/available';
  static const String driverLocation = '/driver/location';
  static const String driverEarnings = '/driver/earnings';
}
