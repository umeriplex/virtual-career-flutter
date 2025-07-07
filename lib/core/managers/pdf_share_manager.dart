import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class PDFShareManager {
  static Future<void> sharePDF(String url, String title) async {
    try {



      String uri = url;
      final response = await http.get(Uri.parse(uri));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
      final bytes = response.bodyBytes;

      Directory generalDownloadDir = Directory('/storage/emulated/0/Download'); //! THIS WORKS for android only !!!!!!

      //qr image file saved to general downloads folder
      File qrJpg = await File('${generalDownloadDir.path}/$title.pdf').create();
      XFile file = XFile(qrJpg.path,name: '$title.pdf', mimeType: 'application/pdf');

      await SharePlus.instance.share(ShareParams(files: [file],));
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }
}