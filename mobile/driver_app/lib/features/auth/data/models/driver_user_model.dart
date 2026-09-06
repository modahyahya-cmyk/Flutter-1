import '../../../../core/utils/parsers.dart';
import '../../domain/entities/driver_user.dart';

class DriverUserModel extends DriverUser {
  const DriverUserModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.avatar,
    super.currentBranchId,
    super.isOnline,
    super.vehicleType,
    super.vehiclePlate,
    super.rating,
    super.totalDeliveries,
  });

  factory DriverUserModel.fromJson(Map<String, dynamic> json) {
    return DriverUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      currentBranchId: Parsers.intOrNull(json['current_branch_id']),
      isOnline: json['is_online'] as bool? ?? false,
      vehicleType: json['vehicle_type'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      rating: Parsers.doubleOrNull(json['rating']),
      totalDeliveries: Parsers.intOf(json['total_deliveries']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'current_branch_id': currentBranchId,
        'is_online': isOnline,
        'vehicle_type': vehicleType,
        'vehicle_plate': vehiclePlate,
        'rating': rating,
        'total_deliveries': totalDeliveries,
      };
}
