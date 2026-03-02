class DivisionModel {
  final int id;
  final String name;
  const DivisionModel({required this.id, required this.name});
  factory DivisionModel.fromJson(Map<String, dynamic> json) =>
      DivisionModel(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class DistrictModel {
  final int id;
  final String name;
  final int divisionId;
  const DistrictModel({required this.id, required this.name, required this.divisionId});
  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    divisionId: json['division_id'] ?? 0,
  );
}

class UpazilaModel {
  final int id;
  final String name;
  final int districtId;
  const UpazilaModel({required this.id, required this.name, required this.districtId});
  factory UpazilaModel.fromJson(Map<String, dynamic> json) => UpazilaModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    districtId: json['district_id'] ?? 0,
  );
}
