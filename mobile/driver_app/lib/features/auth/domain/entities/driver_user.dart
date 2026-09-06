import 'package:equatable/equatable.dart';

class DriverUser extends Equatable {
  const DriverUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    this.currentBranchId,
    this.isOnline = false,
    this.vehicleType,
    this.vehiclePlate,
    this.rating,
    this.totalDeliveries = 0,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final int? currentBranchId;
  final bool isOnline;
  final String? vehicleType;
  final String? vehiclePlate;
  final double? rating;
  final int totalDeliveries;

  @override
  List<Object?> get props => [id, name, email, phone, isOnline];
}
