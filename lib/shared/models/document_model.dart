class DocumentModel {
  final int id;
  final int dolilId;
  final String name;
  final String? originalName;
  final String? mimeType;
  final int? size;
  final String url;
  final String createdAt;

  const DocumentModel({
    required this.id,
    required this.dolilId,
    required this.name,
    this.originalName,
    this.mimeType,
    this.size,
    required this.url,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    id: json['id'] ?? 0,
    dolilId: json['dolil_id'] ?? 0,
    name: json['name'] ?? json['file_name'] ?? '',
    originalName: json['original_name'],
    mimeType: json['mime_type'],
    size: json['size'],
    url: json['url'] ?? json['download_url'] ?? '',
    createdAt: json['created_at'] ?? '',
  );
}
