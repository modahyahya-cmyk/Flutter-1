import '../../../../core/utils/parsers.dart';
import '../../domain/entities/branch.dart';

class BranchModel extends VendorBranch {
  const BranchModel({
    required super.id,
    required super.name,
    super.address,
    super.phone,
    super.latitude,
    super.longitude,
    super.isActive,
    super.opensAt,
    super.closesAt,
    super.timezone,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      latitude: Parsers.doubleOrNull(json['latitude']),
      longitude: Parsers.doubleOrNull(json['longitude']),
      isActive: json['is_active'] as bool? ?? true,
      opensAt: json['opens_at'] as String?,
      closesAt: json['closes_at'] as String?,
      timezone: json['timezone'] as String?,
    );
  }
}
