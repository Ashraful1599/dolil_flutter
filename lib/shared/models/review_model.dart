class ReviewModel {
  final int id;
  final int dolilId;
  final int userId;
  final String? userName;
  final String? userAvatar;
  final int rating;
  final String? comment;
  final String createdAt;

  const ReviewModel({
    required this.id,
    required this.dolilId,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'] ?? 0,
    dolilId: json['dolil_id'] ?? 0,
    userId: json['user_id'] ?? 0,
    userName: json['user']?['name'],
    userAvatar: json['user']?['avatar'],
    rating: json['rating'] ?? 0,
    comment: json['comment'],
    createdAt: json['created_at'] ?? '',
  );
}
