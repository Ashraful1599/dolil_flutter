import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static String extension(String filename) =>
      p.extension(filename).replaceFirst('.', '').toLowerCase();

  static bool isImage(String filename) {
    final ext = extension(filename);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  static bool isPdf(String filename) => extension(filename) == 'pdf';

  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static Future<File> saveToTemp(List<int> bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }
}
