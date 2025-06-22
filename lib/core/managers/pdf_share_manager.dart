import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PDFShareManager {
  static Future<void> sharePDF(String url, String title) async {
    try {
      // Download the file first (it will be cached)
      final file = await DefaultCacheManager().getSingleFile(url);

      // Share the file
      // await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Check out this PDF', title: title),);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Check out this PDF', title: file.path.split('/').last),);
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }
}