class DolilModel {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String? partyA;
  final String? partyB;
  final String? partyAContact;
  final String? partyBContact;
  final String? landDescription;
  final String? mouza;
  final String? khatian;
  final String? plot;
  final String? area;
  final String? registrationOffice;
  final String? notes;
  final int createdById;
  final int? assignedToId;
  final String? createdByName;
  final String? assignedToName;
  final String createdAt;
  final String updatedAt;

  const DolilModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.partyA,
    this.partyB,
    this.partyAContact,
    this.partyBContact,
    this.landDescription,
    this.mouza,
    this.khatian,
    this.plot,
    this.area,
    this.registrationOffice,
    this.notes,
    required this.createdById,
    this.assignedToId,
    this.createdByName,
    this.assignedToName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DolilModel.fromJson(Map<String, dynamic> json) => DolilModel(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    description: json['description'],
    status: json['status'] ?? 'pending',
    partyA: json['party_a'],
    partyB: json['party_b'],
    partyAContact: json['party_a_contact'],
    partyBContact: json['party_b_contact'],
    landDescription: json['land_description'],
    mouza: json['mouza'],
    khatian: json['khatian'],
    plot: json['plot'],
    area: json['area'],
    registrationOffice: json['registration_office'],
    notes: json['notes'],
    createdById: json['created_by'] ?? json['created_by_id'] ?? 0,
    assignedToId: json['assigned_to'] ?? json['assigned_to_id'],
    createdByName: json['created_by_user']?['name'] ?? json['creator']?['name'],
    assignedToName: json['assigned_to_user']?['name'] ?? json['assignee']?['name'],
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
  );

  bool isCompletedOrArchived() => status == 'completed' || status == 'archived';
}
