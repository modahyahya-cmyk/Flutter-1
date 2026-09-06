class PrinterDevice {
  const PrinterDevice({required this.name, required this.address});

  final String name;
  final String address;

  @override
  bool operator ==(Object other) =>
      other is PrinterDevice && other.address == address;

  @override
  int get hashCode => address.hashCode;
}
