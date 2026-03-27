class BdDivision {
  final String id;
  final String nameBn;
  final String nameEn;
  const BdDivision({required this.id, required this.nameBn, required this.nameEn});
  factory BdDivision.fromJson(Map<String, dynamic> j) =>
      BdDivision(id: j['id'].toString(), nameBn: j['name_bn'] ?? '', nameEn: j['name_en'] ?? '');
  String get displayName => '$nameBn ($nameEn)';
}

class BdDistrict {
  final String id;
  final String divisionId;
  final String nameBn;
  final String nameEn;
  const BdDistrict({required this.id, required this.divisionId, required this.nameBn, required this.nameEn});
  factory BdDistrict.fromJson(Map<String, dynamic> j) =>
      BdDistrict(id: j['id'].toString(), divisionId: j['division_id'].toString(), nameBn: j['name_bn'] ?? '', nameEn: j['name_en'] ?? '');
  String get displayName => '$nameBn ($nameEn)';
}

class BdThana {
  final String id;
  final String districtId;
  final String nameBn;
  final String nameEn;
  const BdThana({required this.id, required this.districtId, required this.nameBn, required this.nameEn});
  factory BdThana.fromJson(Map<String, dynamic> j) =>
      BdThana(id: j['id'].toString(), districtId: j['district_id'].toString(), nameBn: j['name_bn'] ?? '', nameEn: j['name_en'] ?? '');
  String get displayName => '$nameBn ($nameEn)';
}

class BdUnion {
  final String id;
  final String thanaId;
  final String nameBn;
  final String nameEn;
  const BdUnion({required this.id, required this.thanaId, required this.nameBn, required this.nameEn});
  factory BdUnion.fromJson(Map<String, dynamic> j) =>
      BdUnion(id: j['id'].toString(), thanaId: j['thana_id'].toString(), nameBn: j['name_bn'] ?? '', nameEn: j['name_en'] ?? '');
  String get displayName => '$nameBn ($nameEn)';
}

class BdMunicipality {
  final String id;
  final String districtId;
  final String nameBn;
  final String nameEn;
  const BdMunicipality({required this.id, required this.districtId, required this.nameBn, required this.nameEn});
  factory BdMunicipality.fromJson(Map<String, dynamic> j) =>
      BdMunicipality(id: j['id'].toString(), districtId: j['district_id'].toString(), nameBn: j['name_bn'] ?? '', nameEn: j['name_en'] ?? '');
  String get displayName => '$nameBn ($nameEn)';
}

class BdCityCorporation {
  final String id;
  final String districtId;
  final String nameBn;
  final String nameEn;
  const BdCityCorporation({required this.id, required this.districtId, required this.nameBn, required this.nameEn});
  factory BdCityCorporation.fromJson(Map<String, dynamic> j) =>
      BdCityCorporation(id: j['id'].toString(), districtId: j['district_id'].toString(), nameBn: j['name_bn'] ?? '', nameEn: j['name_en'] ?? '');
  String get displayName => '$nameBn ($nameEn)';
}

class BdPostOffice {
  final String id;
  final String districtId;
  final String nameBn;
  final String nameEn;
  final String code;
  const BdPostOffice({required this.id, required this.districtId, required this.nameBn, required this.nameEn, required this.code});
  factory BdPostOffice.fromJson(Map<String, dynamic> j) =>
      BdPostOffice(id: j['id'].toString(), districtId: j['district_id'].toString(), nameBn: j['name_bn'] ?? '', nameEn: j['name_en'] ?? '', code: j['code']?.toString() ?? '');
  String get displayName => '$nameBn ($code) $nameEn ($code)';
}

class BdWard {
  final String value;
  final String labelBn;
  final String labelEn;
  const BdWard({required this.value, required this.labelBn, required this.labelEn});
  factory BdWard.fromJson(Map<String, dynamic> j) =>
      BdWard(value: j['value'].toString(), labelBn: j['label_bn'] ?? '', labelEn: j['label_en'] ?? '');
  String get displayName => '$labelBn ($labelEn)';
}

class BdAddressData {
  final List<BdDivision> divisions;
  final List<BdDistrict> districts;
  final List<BdThana> thanas;
  final List<BdUnion> unions;
  final List<BdMunicipality> municipalities;
  final List<BdCityCorporation> cityCorporations;
  final List<BdPostOffice> postOffices;
  final List<BdWard> wards;

  const BdAddressData({
    required this.divisions,
    required this.districts,
    required this.thanas,
    required this.unions,
    required this.municipalities,
    required this.cityCorporations,
    required this.postOffices,
    required this.wards,
  });

  factory BdAddressData.fromJson(Map<String, dynamic> j) => BdAddressData(
    divisions: (j['divisions'] as List? ?? []).map((e) => BdDivision.fromJson(e)).toList(),
    districts: (j['districts'] as List? ?? []).map((e) => BdDistrict.fromJson(e)).toList(),
    thanas: (j['thanas'] as List? ?? []).map((e) => BdThana.fromJson(e)).toList(),
    unions: (j['unions'] as List? ?? []).map((e) => BdUnion.fromJson(e)).toList(),
    municipalities: (j['municipalities'] as List? ?? []).map((e) => BdMunicipality.fromJson(e)).toList(),
    cityCorporations: (j['cityCorporations'] as List? ?? []).map((e) => BdCityCorporation.fromJson(e)).toList(),
    postOffices: (j['postOffices'] as List? ?? []).map((e) => BdPostOffice.fromJson(e)).toList(),
    wards: (j['wards'] as List? ?? []).map((e) => BdWard.fromJson(e)).toList(),
  );
}

class BdAddressSelection {
  final String addressType;      // 'Union' | 'Municipality' | 'City Corporation'
  final String? divisionId;
  final String? districtId;
  final String? thanaId;
  final String? unionId;
  final String? municipalityId;
  final String? cityCorporationId;
  final String? postOfficeId;
  final String? ward;

  const BdAddressSelection({
    this.addressType = 'Union',
    this.divisionId,
    this.districtId,
    this.thanaId,
    this.unionId,
    this.municipalityId,
    this.cityCorporationId,
    this.postOfficeId,
    this.ward,
  });

  BdAddressSelection copyWith({
    String? addressType,
    Object? divisionId = _sentinel,
    Object? districtId = _sentinel,
    Object? thanaId = _sentinel,
    Object? unionId = _sentinel,
    Object? municipalityId = _sentinel,
    Object? cityCorporationId = _sentinel,
    Object? postOfficeId = _sentinel,
    Object? ward = _sentinel,
  }) {
    return BdAddressSelection(
      addressType: addressType ?? this.addressType,
      divisionId: divisionId == _sentinel ? this.divisionId : divisionId as String?,
      districtId: districtId == _sentinel ? this.districtId : districtId as String?,
      thanaId: thanaId == _sentinel ? this.thanaId : thanaId as String?,
      unionId: unionId == _sentinel ? this.unionId : unionId as String?,
      municipalityId: municipalityId == _sentinel ? this.municipalityId : municipalityId as String?,
      cityCorporationId: cityCorporationId == _sentinel ? this.cityCorporationId : cityCorporationId as String?,
      postOfficeId: postOfficeId == _sentinel ? this.postOfficeId : postOfficeId as String?,
      ward: ward == _sentinel ? this.ward : ward as String?,
    );
  }
}

const _sentinel = Object();
