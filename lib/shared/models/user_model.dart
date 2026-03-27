class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatar;
  final bool emailVerified;
  final bool phoneVerified;
  final bool isActive;
  // Writer fields
  final String? registrationNumber;
  final String? officeName;
  final String? bio;
  final int? divisionId;
  final int? districtId;
  final int? upazilaId;
  final String? divisionName;
  final String? districtName;
  final String? upazilaName;
  final double? averageRating;
  final int? totalReviews;
  final String? referralCode;
  final String? addressType;
  final String? bdUnionId;
  final String? bdMunicipalityId;
  final String? bdCityCorporationId;
  final String? bdPostOfficeId;
  final String? bdWard;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.isActive = true,
    this.registrationNumber,
    this.officeName,
    this.bio,
    this.divisionId,
    this.districtId,
    this.upazilaId,
    this.divisionName,
    this.districtName,
    this.upazilaName,
    this.averageRating,
    this.totalReviews,
    this.referralCode,
    this.addressType,
    this.bdUnionId,
    this.bdMunicipalityId,
    this.bdCityCorporationId,
    this.bdPostOfficeId,
    this.bdWard,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'],
    role: json['role'] ?? 'user',
    avatar: json['avatar'],
    emailVerified: json['email_verified'] == true || json['email_verified_at'] != null,
    phoneVerified: json['phone_verified'] == true,
    isActive: json['is_active'] != false,
    registrationNumber: json['registration_number'],
    officeName: json['office_name'],
    bio: json['bio'],
    divisionId: json['division_id'],
    districtId: json['district_id'],
    upazilaId: json['upazila_id'],
    divisionName: json['division_name'] ?? json['division']?['name'],
    districtName: json['district_name'] ?? json['district']?['name'],
    upazilaName: json['upazila_name'] ?? json['upazila']?['name'],
    averageRating: (json['average_rating'] as num?)?.toDouble(),
    totalReviews: json['total_reviews'],
    referralCode: json['referral_code'],
    addressType: json['address_type'],
    bdUnionId: json['bd_union_id'],
    bdMunicipalityId: json['bd_municipality_id'],
    bdCityCorporationId: json['bd_city_corporation_id'],
    bdPostOfficeId: json['bd_post_office_id'],
    bdWard: json['bd_ward'],
  );

  bool get isAdmin => role == 'admin';
  bool get isDolilWriter => role == 'dolil_writer';
  bool get isUser => role == 'user';
}
