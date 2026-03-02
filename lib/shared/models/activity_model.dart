class ActivityModel {
  final int id;
  final String action;
  final String? description;
  final int? userId;
  final String? userName;
  final String createdAt;

  const ActivityModel({
    required this.id,
    required this.action,
    this.description,
    this.userId,
    this.userName,
    required this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    id: json['id'] ?? 0,
    action: json['action'] ?? json['event'] ?? '',
    description: json['description'],
    userId: json['user_id'],
    userName: json['user']?['name'] ?? json['causer']?['name'],
    createdAt: json['created_at'] ?? '',
  );
}
