import '../../domain/entities/vendor_user.dart';

class VendorUserModel extends VendorUser {
  const VendorUserModel({
    required super.id,
    required super.email,
    super.firstName,
    super.lastName,
    super.vendorId,
    super.storeName,
    super.slug,
    super.status,
    super.avatar,
  });

  factory VendorUserModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map<String, dynamic>?;
    return VendorUserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      vendorId: vendor?['id'] as int? ?? json['vendor_id'] as int?,
      storeName: vendor?['business_name'] as String?,
      slug: vendor?['slug'] as String?,
      status: vendor?['status'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'vendor_id': vendorId,
        'status': status,
        'avatar': avatar,
      };
}
