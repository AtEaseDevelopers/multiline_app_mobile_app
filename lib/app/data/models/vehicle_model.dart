class Vehicle {
  final int id;
  final String registrationNumber;
  final String companyName;

  Vehicle({
    required this.id,
    required this.registrationNumber,
    required this.companyName,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      registrationNumber: json['registration_number'] as String,
      companyName: json['company_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration_number': registrationNumber,
      'company_name': companyName,
    };
  }
}

class VehiclesResponse {
  final List<Vehicle> vehicles;

  VehiclesResponse({required this.vehicles});

  factory VehiclesResponse.fromJson(Map<String, dynamic> json) {
    final vehiclesList = json['vehicles'] as List<dynamic>;
    return VehiclesResponse(
      vehicles: vehiclesList
          .map((v) => Vehicle.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'vehicles': vehicles.map((v) => v.toJson()).toList()};
  }
}
