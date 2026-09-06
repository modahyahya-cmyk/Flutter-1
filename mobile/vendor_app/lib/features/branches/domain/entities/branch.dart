class VendorBranch {
  const VendorBranch({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.opensAt,
    this.closesAt,
    this.timezone,
  });

  final int id;
  final String name;
  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final String? opensAt;
  final String? closesAt;
  final String? timezone;

  bool get isOpen {
    if (opensAt == null || closesAt == null) return true;
    final now = TimeOfDayConverter.now();
    return now.compareTo(opensAt!) >= 0 && now.compareTo(closesAt!) <= 0;
  }
}

class TimeOfDayConverter {
  TimeOfDayConverter._();
  static String now() => DateTime.now().toIso8601String().substring(11, 16);
}
