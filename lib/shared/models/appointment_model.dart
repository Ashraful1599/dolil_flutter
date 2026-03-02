class AppointmentModel {
  final int id;
  final String clientName;
  final String clientPhone;
  final String? clientEmail;
  final String preferredDate;
  final String? message;
  final String status;
  final int writerId;
  final String? writerName;
  final String createdAt;

  const AppointmentModel({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    required this.preferredDate,
    this.message,
    required this.status,
    required this.writerId,
    this.writerName,
    required this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => AppointmentModel(
    id: json['id'] ?? 0,
    clientName: json['client_name'] ?? '',
    clientPhone: json['client_phone'] ?? '',
    clientEmail: json['client_email'],
    preferredDate: json['preferred_date'] ?? '',
    message: json['message'],
    status: json['status'] ?? 'pending',
    writerId: json['writer_id'] ?? json['dolil_writer_id'] ?? 0,
    writerName: json['writer']?['name'] ?? json['dolil_writer']?['name'],
    createdAt: json['created_at'] ?? '',
  );
}
