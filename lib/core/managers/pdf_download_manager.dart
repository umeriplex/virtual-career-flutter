import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PDFDownloadManager {
  static Future<String?> savePDF(String url, String fileName) async {
    try {
      debugPrint('Downloading PDF from: $url with name: $fileName');

      // Ask for storage permission
      if (!await Permission.manageExternalStorage.request().isGranted) {
        debugPrint('Storage permission not granted');
        return null;
      }


      // Download the PDF file from URL
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF');
      }

      // Path to the public Downloads directory
      final String downloadsPath = '/storage/emulated/0/Download';
      final File file = File('$downloadsPath/$fileName.pdf');

      // Save the file
      await file.writeAsBytes(response.bodyBytes);
      debugPrint('PDF saved at: ${file.path}');
      return file.path;

    } catch (e) {
      debugPrint('Error saving PDF: $e');
      return null;
    }
  }




}