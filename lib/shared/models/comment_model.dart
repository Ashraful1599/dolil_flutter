class CommentModel {
  final int id;
  final int dolilId;
  final int userId;
  final String? userName;
  final String? userAvatar;
  final String body;
  final String? attachmentName;
  final String? attachmentUrl;
  final String createdAt;

  const CommentModel({
    required this.id,
    required this.dolilId,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.body,
    this.attachmentName,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'] ?? 0,
    dolilId: json['dolil_id'] ?? 0,
    userId: json['user_id'] ?? 0,
    userName: json['user']?['name'],
    userAvatar: json['user']?['avatar'],
    body: json['body'] ?? '',
    attachmentName: json['attachment_name'],
    attachmentUrl: json['attachment_url'],
    createdAt: json['created_at'] ?? '',
  );
}
