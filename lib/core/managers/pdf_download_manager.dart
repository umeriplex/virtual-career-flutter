import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PDFDownloadManager {

  static Future<String?> save(String url, { String? fileName }) async {
    try {
      String uri = url;
      final response = await http.get(Uri.parse(uri));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
      final bytes = response.bodyBytes;

      Directory generalDownloadDir = Directory('/storage/emulated/0/Download'); //! THIS WORKS for android only !!!!!!

      //qr image file saved to general downloads folder
      File qrJpg = await File('${generalDownloadDir.path}/$fileName.pdf').create();
      await qrJpg.writeAsBytes(bytes);
      print('PDF saved to: ${qrJpg.path}');
      return qrJpg.path;
    } catch (e) {
      print('Error saving PDF: $e');
      return null;
    }
  }


  static Future<String?> downloadAndSavePdf(String pdfUrl, {String? fileName}) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission denied');
          }
        }
      }

      // Create Dio instance
      Dio dio = Dio();

      // Get the application documents directory
      Directory appDocDir = await getApplicationDocumentsDirectory();

      // Create filename if not provided
      fileName ??= 'downloaded_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Ensure filename has .pdf extension
      if (!fileName.endsWith('.pdf')) {
        fileName += '.pdf';
      }

      // Create full file path
      String filePath = '${appDocDir.path}/$fileName';

      // Download the PDF
      Response response = await dio.download(
        pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      if (response.statusCode == 200) {
        print('PDF downloaded successfully to: $filePath');
        return filePath;
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }

    } catch (e) {
      print('Error downloading PDF: $e');
      return null;
    }
  }

  // Alternative method to save to external storage (Android)
  static Future<String?> downloadPdfToExternalStorage(String pdfUrl, {String? fileName}) async {
    try {
      if (!Platform.isAndroid) {
        throw Exception('External storage only available on Android');
      }

      // Request storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      // Create Dio instance
      Dio dio = Dio();

      // Get external storage directory
      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        throw Exception('External storage not available');
      }

      // Create filename if not provided
      fileName ??= 'downloaded_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Ensure filename has .pdf extension
      if (!fileName.endsWith('.pdf')) {
        fileName += '.pdf';
      }

      // Create Downloads folder if it doesn't exist
      Directory downloadsDir = Directory('${externalDir.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Create full file path
      String filePath = '${downloadsDir.path}/$fileName';

      // Download the PDF
      Response response = await dio.download(
        pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      if (response.statusCode == 200) {
        print('PDF downloaded successfully to: $filePath');
        return filePath;
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }

    } catch (e) {
      print('Error downloading PDF: $e');
      return null;
    }
  }
}