/// Core [User] entity — independent of any data source/model.
class User {
  const User({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.status,
  });

  final int id;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final String? status;

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  bool get isVendor => role == 'vendor';
  bool get isDriver => role == 'driver';
  bool get isAdmin => role == 'admin';
  bool get isActive => status == null || status == 'active';
}
