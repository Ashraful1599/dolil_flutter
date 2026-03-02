class AppConstants {
  static const String apiBaseUrl = 'https://dolilbd-api-main-h3nzlk.laravel.cloud/api';
  static const String tokenKey = 'dolil_token';
  static const int maxFileSize = 20 * 1024 * 1024; // 20 MB
  static const List<String> allowedDocTypes = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];
  static const List<String> allowedMimeTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'image/jpeg',
    'image/png',
  ];
  static const Map<String, String> districtAliasMap = {
    'chittagong': 'chattogram',
    'comilla': 'cumilla',
    'jessore': 'jashore',
  };
}
