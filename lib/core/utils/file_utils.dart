import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
/// Generate a placeholder image with "PDF" text in the center
Future<File> generatePlaceholderImage() async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 200, 200));
  final paint = Paint()..color = Colors.white;

  // Draw white background
  canvas.drawRect(Rect.fromLTWH(0, 0, 200, 200), paint);

  // Draw "PDF" text in the center
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'PDF',
      style: TextStyle(
        color: Colors.black,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (200 - textPainter.width) / 2,
      (200 - textPainter.height) / 2,
    ),
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(200, 200);
  final byteData = await img.toByteData(format: ImageByteFormat.png);

  // Save the image as a file
  final directory = (await getTemporaryDirectory()).path;
  final file = File('$directory/placeholder_${DateTime.now().millisecondsSinceEpoch}.png');
  await file.writeAsBytes(byteData!.buffer.asUint8List());

  return file;
}