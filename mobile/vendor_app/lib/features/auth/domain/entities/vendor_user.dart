/// Authenticated vendor user identity.
class VendorUser {
  const VendorUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.vendorId,
    this.storeName,
    this.slug,
    this.status,
    this.avatar,
  });

  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final int? vendorId;
  final String? storeName;
  final String? slug;
  final String? status;
  final String? avatar;

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  bool get isApproved => status == 'approved';
}
