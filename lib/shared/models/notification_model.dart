class NotificationModel {
  final int id;
  final String type;
  final Map<String, dynamic> data;
  final bool read;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.data,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json['id'] ?? 0,
    type: json['type'] ?? '',
    data: Map<String, dynamic>.from(json['data'] ?? {}),
    read: json['read'] == true || json['read_at'] != null,
    createdAt: json['created_at'] ?? '',
  );

  String get message => data['message'] ?? '';
  int? get dolilId => data['dolil_id'];
  String? get dolilTitle => data['dolil_title'];

  static String labelForType(String type) {
    const labels = {
      'dolil_assigned': 'Dolil Assigned',
      'dolil_created': 'Dolil Created',
      'status_changed': 'Status Changed',
      'comment_added': 'New Comment',
      'document_uploaded': 'Document Uploaded',
      'appointment_requested': 'Appointment Request',
      'appointment_updated': 'Appointment Update',
    };
    return labels[type] ?? type;
  }
}
