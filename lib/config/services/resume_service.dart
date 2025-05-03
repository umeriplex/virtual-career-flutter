import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as material;

import '../../features/resume_builder/model/resumer_model.dart';
import '../../main.dart';

class PdfResumeService {
  static Future<File> generateResume(Resume resume, int templateNumber) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);
    final fileName = 'resume_${resume.heading?.name?.replaceAll(' ', '_') ?? 'unknown'}_$formattedDate.pdf';

    // Load avatar if exists
    pw.ImageProvider? avatarImage;
    if (resume.heading?.avatar != null && resume.heading!.avatar!.isNotEmpty) {
      try {
        // Handle network images
        if (resume.heading!.avatar!.startsWith('http') || resume.heading!.avatar!.startsWith('https')) {
          final response = await HttpClient().getUrl(Uri.parse(resume.heading!.avatar!)).then((req) => req.close());
          final bytes = await consolidateHttpClientResponseBytes(response);
          avatarImage = pw.MemoryImage(bytes);
        }
        // Handle asset images
        else if (resume.heading!.avatar!.startsWith('assets/')) {
          final byteData = await rootBundle.load(resume.heading!.avatar!);
          avatarImage = pw.MemoryImage(byteData.buffer.asUint8List());
        }
      } catch (e) {
        print('Error loading avatar: $e');
      }
    }

    switch (templateNumber) {
      case 1:
        _buildCorporateBlue(pdf, resume, avatarImage);
        break;
      case 2:
        _buildModernGreen(pdf, resume, avatarImage);
        break;
      case 3:
        _buildElegantPurple(pdf, resume, avatarImage);
        break;
      case 4:
        _buildCreativeRed(pdf, resume, avatarImage);
        break;
      case 5:
        _buildMinimalistBlack(pdf, resume, avatarImage);
        break;
      case 6:
        _buildTemplate06(pdf, resume, avatarImage);
        break;
      case 7:
        _buildTemplate07(pdf, resume, avatarImage);
        break;
      case 8:
        _buildTemplate08(pdf, resume, avatarImage);
        break;
      case 9:
        _buildTemplate09(pdf, resume, avatarImage);
        break;
      case 10:
        _buildTemplate10(pdf, resume, avatarImage);
        break;
      case 11:
        _buildTemplate11(pdf, resume, avatarImage);
        break;
      case 12:
        _buildTemplate12(pdf, resume, avatarImage);
        break;
      case 13:
        _buildTemplate13(pdf, resume, avatarImage);
        break;
      case 14:
        _buildTemplate14(pdf, resume, avatarImage);
        break;

      case 15:
        _buildTemplate15(pdf, resume, avatarImage);
        break;

      default:
        _buildCorporateBlue(pdf, resume, avatarImage);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ====================
  // TEMPLATE 1: Corporate Blue
  // ====================
  static void _buildCorporateBlue(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Row(
            children: [
              // Left sidebar - 30% width
              pw.Container(
                width: context.page.pageFormat.availableWidth * 0.3,
                color: PdfColors.blue.shade(900),
                padding:  pw.EdgeInsets.all(25),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    if (avatarImage != null)
                      pw.Center(
                        child: pw.Container(
                          width: 120,
                          height: 120,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            image: pw.DecorationImage(
                              image: avatarImage,
                              fit: pw.BoxFit.cover,
                            ),
                            border: pw.Border.all(
                              color: PdfColors.white,
                              width: 3,
                            ),
                          ),
                        ),
                      )
                    else if (resume.heading?.name != null)
                      pw.Center(
                        child: pw.Container(
                          width: 120,
                          height: 120,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColors.blue.shade(700),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              resume.heading!.name!.substring(0, 1).toUpperCase(),
                              style: pw.TextStyle( font: ttfFont,
                                color: PdfColors.white,
                                fontSize: 48,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                    pw.SizedBox(height: 15),

                    // Name and Title
                    if (resume.heading?.name != null)
                      pw.Text(
                        resume.heading!.name!,
                        style: pw.TextStyle( font: ttfFont,
                          color: PdfColors.white,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                    if (resume.heading?.position != null)
                      pw.Text(
                        resume.heading!.position!,
                        style: pw.TextStyle( font: ttfFont,
                          color: PdfColors.white,
                          fontSize: 14,
                        ),
                      ),

                    pw.SizedBox(height: 10),

                    // Contact Information
                    if (resume.contact != null && resume.contact!.isNotEmpty)
                      _buildSidebarSection(
                        title: 'CONTACT',
                        titleColor: PdfColors.white,
                        items: resume.contact!
                            .where((c) => c.value != null && c.value!.isNotEmpty)
                            .map((c) => pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              c.type?.toUpperCase() ?? '',
                              style: pw.TextStyle(
                                font: ttfFont,
                                color: PdfColors.white,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              c.value!,
                              style:  pw.TextStyle( font: ttfFont,
                                color: PdfColors.white,
                                fontSize: 10,
                              ),
                            ),
                            pw.SizedBox(height: 3),
                          ],
                        ))
                            .toList(),
                      ),


                    // Skills
                    if (resume.skills != null && resume.skills!.isNotEmpty)
                      _buildSidebarSection(
                        title: 'SKILLS',
                        titleColor: PdfColors.white,
                        items: resume.skills!.expand((skillCat) => [
                          pw.Text(
                            skillCat.category?.toUpperCase() ?? '',
                            style: pw.TextStyle( font: ttfFont,
                              color: PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          ...(skillCat.items ?? [])
                              .map((skill) => pw.Text(
                            '• $skill',
                            style: pw.TextStyle( font: ttfFont,
                              color: PdfColors.white,
                              fontSize: 10,
                            ),
                          )),
                          pw.SizedBox(height: 10),
                        ])
                            .toList(),
                      ),

                    // Languages
                    if (resume.languages != null && resume.languages!.isNotEmpty)
                      _buildSidebarSection(
                        title: 'LANGUAGES',
                        titleColor: PdfColors.white,
                        items: resume.languages!
                            .map((lang) => pw.Text(
                          '${lang.name ?? ''}${lang.name != null && lang.proficiency != null ? ' - ' : ''}${lang.proficiency ?? ''}',
                          style:  pw.TextStyle( font: ttfFont,
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ))
                            .toList(),
                      ),
                  ],
                ),
              ),

              // Main content - 70% width
              pw.Container(
                width: context.page.pageFormat.availableWidth * 0.7,
                padding:  pw.EdgeInsets.all(30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Profile Summary
                    if (resume.summary != null && resume.summary!.isNotEmpty)
                      _buildMainSection(
                        title: 'PROFILE',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Text(
                          resume.summary!,
                          style:  pw.TextStyle( font: ttfFont,
                            fontSize: 11,
                            lineSpacing: 1.5,
                          ),
                        ),
                      ),

                    // Work Experience
                    if (resume.experience != null && resume.experience!.isNotEmpty)
                      _buildMainSection(
                        title: 'WORK EXPERIENCE',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.experience!
                              .where((exp) => exp.position != null || exp.company != null)
                              .map((exp) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (exp.position != null)
                                    pw.Text(
                                      exp.position!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.blue.shade(900),
                                      ),
                                    ),
                                  if (exp.duration != null)
                                    pw.Text(
                                      exp.duration!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                        fontStyle: pw.FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),

                              if (exp.company != null || exp.location != null)
                                pw.Text(
                                  '${exp.company ?? ''}${exp.company != null && exp.location != null ? ', ' : ''}${exp.location ?? ''}',
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 11,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.SizedBox(height: 8),
                                    ...exp.responsibilities!
                                        .map((resp) => pw.Text(
                                      '• $resp',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        lineSpacing: 1.5,
                                      ),
                                    ))
                                  ],
                                ),
                              pw.SizedBox(height: 7),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Education
                    if (resume.education != null && resume.education!.isNotEmpty)
                      _buildMainSection(
                        title: 'EDUCATION',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.education!
                              .where((edu) => edu.institution != null || edu.degree != null)
                              .map((edu) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (edu.degree != null)
                                    pw.Text(
                                      edu.degree!,
                                      style: pw.TextStyle( font: ttfFont,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.blue.shade(900),
                                      ),
                                    ),
                                  if (edu.year != null)
                                    pw.Text(
                                      edu.year!,
                                      style:  pw.TextStyle( font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                      ),
                                    ),
                                ],
                              ),

                              if (edu.institution != null)
                                pw.Text(
                                  edu.institution!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 11,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              pw.SizedBox(height: 7),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Projects
                    if (resume.projects != null && resume.projects!.isNotEmpty)
                      _buildMainSection(
                        title: 'PROJECTS',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.projects!
                              .where((proj) => proj.name != null || proj.description != null)
                              .map((proj) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (proj.name != null)
                                pw.Text(
                                  proj.name!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue.shade(900),
                                  ),
                                ),

                              if (proj.technologies != null && proj.technologies!.isNotEmpty)
                                pw.Text(
                                  'Technologies: ${proj.technologies!.join(', ')}',
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 10,
                                    color: PdfColors.grey,
                                    fontStyle: pw.FontStyle.italic,
                                  ),
                                ),

                              if (proj.description != null)
                                pw.Text(
                                  proj.description!,
                                  style:  pw.TextStyle( font: ttfFont,
                                    fontSize: 10,
                                    lineSpacing: 1.5,
                                  ),
                                ),

                              pw.SizedBox(height: 5),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Certifications
                    if (resume.certifications != null && resume.certifications!.isNotEmpty)
                      _buildMainSection(
                        title: 'CERTIFICATIONS',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.certifications!
                              .where((cert) => cert.name != null || cert.year != null)
                              .map((cert) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (cert.name != null)
                                    pw.Text(
                                      cert.name!,
                                      style: pw.TextStyle( font: ttfFont,
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  if (cert.year != null)
                                    pw.Text(
                                      cert.year!,
                                      style:  pw.TextStyle( font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              pw.SizedBox(height: 5),
                            ],
                          )).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 2: Modern Green
  // ====================
  static void _buildModernGreen(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Background decoration
              pw.Positioned(
                top: 0,
                right: 0,
                child: pw.Container(
                  width: 200,
                  height: 200,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius:  pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(100),
                    ),
                  ),
                ),
              ),

              pw.Padding(
                padding:  pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header with avatar and name
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (avatarImage != null)
                          pw.Container(
                            width: 100,
                            height: 100,
                            margin:  pw.EdgeInsets.only(right: 25),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              image: pw.DecorationImage(
                                image: avatarImage,
                                fit: pw.BoxFit.cover,
                              ),
                              border: pw.Border.all(
                                color: PdfColors.green.shade(400),
                                width: 3,
                              ),
                            ),
                          )
                        else if (resume.heading?.name != null)
                          pw.Container(
                            width: 100,
                            height: 100,
                            margin:  pw.EdgeInsets.only(right: 25),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: PdfColors.green.shade(300),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                resume.heading!.name!.substring(0, 1).toUpperCase(),
                                style: pw.TextStyle( font: ttfFont,
                                  color: PdfColors.white,
                                  fontSize: 48,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (resume.heading?.name != null)
                                pw.Text(
                                  resume.heading!.name!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 28,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green.shade(800),
                                  ),
                                ),

                              if (resume.heading?.position != null)
                                pw.Text(
                                  resume.heading!.position!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 16,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              pw.SizedBox(height: 15),

                              // Contact information inline
                              if (resume.contact != null && resume.contact!.isNotEmpty)
                                pw.Wrap(
                                  spacing: 15,
                                  runSpacing: 10,
                                  children: resume.contact!
                                      .where((c) => c.value != null && c.value!.isNotEmpty)
                                      .map((c) => pw.Row(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    children: [
                                      pw.Text(
                                        String.fromCharCode(_getContactIconCode(c.type)),
                                        style: pw.TextStyle(
                                          font: materialIcon,
                                          fontSize: 12,
                                          color: PdfColors.green.shade(600),
                                        ),
                                      ),

                                      pw.SizedBox(width: 5),
                                      pw.Text(
                                        c.value!,
                                        style:  pw.TextStyle( font: ttfFont,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 15),

                    // Profile Summary
                    if (resume.summary != null && resume.summary!.isNotEmpty)
                      _buildModernSection(
                        title: 'PROFILE',
                        accentColor: PdfColors.green.shade(400),
                        content: pw.Text(
                          resume.summary!,
                          style:  pw.TextStyle( font: ttfFont,
                            fontSize: 11,
                            lineSpacing: 1.5,
                          ),
                        ),
                      ),

                    // Work Experience
                    if (resume.experience != null && resume.experience!.isNotEmpty)
                      _buildModernSection(
                        title: 'WORK EXPERIENCE',
                        accentColor: PdfColors.green.shade(400),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.experience!
                              .where((exp) => exp.position != null || exp.company != null)
                              .map((exp) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    width: 12,
                                    height: 12,
                                    margin:  pw.EdgeInsets.only(top: 4, right: 10),
                                    decoration: pw.BoxDecoration(
                                      shape: pw.BoxShape.circle,
                                      color: PdfColors.green.shade(400),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        if (exp.position != null)
                                          pw.Text(
                                            exp.position!,
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),

                                        if (exp.company != null || exp.duration != null)
                                          pw.Text(
                                            '${exp.company ?? ''}${exp.company != null && exp.duration != null ? ' | ' : ''}${exp.duration ?? ''}',
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                              color: PdfColors.grey,
                                            ),
                                          ),

                                        if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                          pw.Column(
                                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.SizedBox(height: 8),
                                              ...exp.responsibilities!
                                                  .map((resp) => pw.Text(
                                                '• $resp',
                                                style:  pw.TextStyle( font: ttfFont,
                                                  fontSize: 10,
                                                  lineSpacing: 1.5,
                                                ),
                                              ))
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 8),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Education
                    if (resume.education != null && resume.education!.isNotEmpty)
                      _buildModernSection(
                        title: 'EDUCATION',
                        accentColor: PdfColors.green.shade(400),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.education!
                              .where((edu) => edu.institution != null || edu.degree != null)
                              .map((edu) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    width: 12,
                                    height: 12,
                                    margin:  pw.EdgeInsets.only(top: 4, right: 10),
                                    decoration: pw.BoxDecoration(
                                      shape: pw.BoxShape.circle,
                                      color: PdfColors.green.shade(400),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        if (edu.degree != null)
                                          pw.Text(
                                            edu.degree!,
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),

                                        if (edu.institution != null || edu.year != null)
                                          pw.Text(
                                            '${edu.institution ?? ''}${edu.institution != null && edu.year != null ? ' | ' : ''}${edu.year ?? ''}',
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                              color: PdfColors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 8),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Skills
                    if (resume.skills != null && resume.skills!.isNotEmpty)
                      _buildModernSection(
                        title: 'SKILLS',
                        accentColor: PdfColors.green.shade(400),
                        content: pw.Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: resume.skills!.expand((skillCat) => [
                            if (skillCat.category != null)
                              pw.Text(
                                '${skillCat.category!.toUpperCase()}:',
                                style: pw.TextStyle( font: ttfFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ...(skillCat.items ?? []).map((skill) => pw.Container(
                              padding:  pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.green.shade(100),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(
                                skill,
                                style:  pw.TextStyle( font: ttfFont,
                                  color: PdfColors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ))
                          ]).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 3: Elegant Purple
  // ====================
  static void _buildElegantPurple(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Header background
              pw.Container(
                height: 120,
                width: double.infinity,
                color: PdfColors.purple.shade(900),
              ),

              pw.Padding(
                padding:  pw.EdgeInsets.all(30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header with avatar
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (avatarImage != null)
                          pw.Container(
                            width: 80,
                            height: 80,
                            margin:  pw.EdgeInsets.only(right: 20),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              image: pw.DecorationImage(
                                image: avatarImage,
                                fit: pw.BoxFit.cover,
                              ),
                              border: pw.Border.all(
                                color: PdfColors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                pw.BoxShadow(
                                  color: PdfColors.grey.shade(400),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                          )
                        else if (resume.heading?.name != null)
                          pw.Container(
                            width: 80,
                            height: 80,
                            margin:  pw.EdgeInsets.only(right: 20),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: PdfColors.purple.shade(700),
                              border: pw.Border.all(
                                color: PdfColors.white,
                                width: 3,
                              ),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                resume.heading!.name!.substring(0, 1).toUpperCase(),
                                style: pw.TextStyle( font: ttfFont,
                                  color: PdfColors.white,
                                  fontSize: 36,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (resume.heading?.name != null)
                                pw.Text(
                                  resume.heading!.name!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                ),

                              if (resume.heading?.position != null)
                                pw.Text(
                                  resume.heading!.position!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 14,
                                    color: PdfColors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 40),

                    // Two column layout
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left column (60%)
                        pw.Expanded(
                          flex: 6,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Profile Summary
                              if (resume.summary != null && resume.summary!.isNotEmpty)
                                _buildElegantSection(
                                  title: 'PROFILE',
                                  accentColor: PdfColors.purple.shade(900),
                                  content: pw.Text(
                                    resume.summary!,
                                    style:  pw.TextStyle( font: ttfFont,
                                      fontSize: 11,
                                      lineSpacing: 1.5,
                                    ),
                                  ),
                                ),

                              // Work Experience
                              if (resume.experience != null && resume.experience!.isNotEmpty)
                                _buildElegantSection(
                                  title: 'EXPERIENCE',
                                  accentColor: PdfColors.purple.shade(900),
                                  content: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: resume.experience!
                                        .where((exp) => exp.position != null || exp.company != null)
                                        .map((exp) => pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        if (exp.position != null)
                                          pw.Text(
                                            exp.position!,
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),

                                        if (exp.company != null || exp.duration != null)
                                          pw.Text(
                                            '${exp.company ?? ''}${exp.company != null && exp.duration != null ? ' | ' : ''}${exp.duration ?? ''}',
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                              color: PdfColors.grey,
                                            ),
                                          ),

                                        if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                          pw.Column(
                                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.SizedBox(height: 8),
                                              ...exp.responsibilities!
                                                  .map((resp) => pw.Text(
                                                '- $resp',
                                                style:  pw.TextStyle( font: ttfFont,
                                                  fontSize: 10,
                                                  lineSpacing: 1.5,
                                                ),
                                              ))
                                            ],
                                          ),
                                        pw.SizedBox(height: 15),
                                      ],
                                    ))
                                        .toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Right column (40%)
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding:  pw.EdgeInsets.only(left: 20),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Contact Information
                                if (resume.contact != null && resume.contact!.isNotEmpty)
                                  _buildElegantSection(
                                    title: 'CONTACT',
                                    accentColor: PdfColors.purple.shade(900),
                                    content: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: resume.contact!
                                          .where((c) => c.value != null && c.value!.isNotEmpty)
                                          .map((c) => pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            c.type?.toUpperCase() ?? '',
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.purple.shade(900),
                                            ),
                                          ),
                                          pw.Text(
                                            c.value!,
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                            ),
                                          ),
                                          pw.SizedBox(height: 8),
                                        ],
                                      ))
                                          .toList(),
                                    ),
                                  ),

                                // Education
                                if (resume.education != null && resume.education!.isNotEmpty)
                                  _buildElegantSection(
                                    title: 'EDUCATION',
                                    accentColor: PdfColors.purple.shade(900),
                                    content: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: resume.education!
                                          .where((edu) => edu.institution != null || edu.degree != null)
                                          .map((edu) => pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          if (edu.degree != null)
                                            pw.Text(
                                              edu.degree!,
                                              style: pw.TextStyle( font: ttfFont,
                                                fontSize: 12,
                                                fontWeight: pw.FontWeight.bold,
                                              ),
                                            ),

                                          if (edu.institution != null)
                                            pw.Text(
                                              edu.institution!,
                                              style:  pw.TextStyle( font: ttfFont,
                                                fontSize: 10,
                                              ),
                                            ),

                                          if (edu.year != null)
                                            pw.Text(
                                              edu.year!,
                                              style:  pw.TextStyle( font: ttfFont,
                                                fontSize: 9,
                                                color: PdfColors.grey,
                                              ),
                                            ),

                                          pw.SizedBox(height: 10),
                                        ],
                                      ))
                                          .toList(),
                                    ),
                                  ),

                                // Skills
                                if (resume.skills != null && resume.skills!.isNotEmpty)
                                  _buildElegantSection(
                                    title: 'SKILLS',
                                    accentColor: PdfColors.purple.shade(900),
                                    content: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: resume.skills!
                                          .where((skillCat) => skillCat.category != null && (skillCat.items?.isNotEmpty ?? false))
                                          .map((skillCat) => pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            skillCat.category!,
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 11,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                          pw.SizedBox(height: 5),
                                          ...(skillCat.items ?? [])
                                              .map((skill) => pw.Text(
                                            '• $skill',
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                            ),
                                          )),
                                          pw.SizedBox(height: 10),
                                        ],
                                      ))
                                          .toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 4: Creative Red
  // ====================
  static void _buildCreativeRed(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Stack(
            children: [

              // Decorative elements
              pw.Positioned(
                top: 0,
                right: 0,
                child: pw.Container(
                  width: 150,
                  height: 150,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius:  pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(75),
                    ),
                  ),
                ),
              ),

              pw.Positioned(
                bottom: 0,
                left: 0,
                child: pw.Container(
                  width: 100,
                  height: 100,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius:  pw.BorderRadius.only(
                      topRight: pw.Radius.circular(50),
                    ),
                  ),
                ),
              ),


              pw.Padding(
                padding:  pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header with avatar
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (avatarImage != null)
                          pw.Container(
                            width: 100,
                            height: 100,
                            margin:  pw.EdgeInsets.only(right: 25),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              image: pw.DecorationImage(
                                image: avatarImage,
                                fit: pw.BoxFit.cover,
                              ),
                              border: pw.Border.all(
                                color: PdfColors.red.shade(400),
                                width: 3,
                              ),
                              boxShadow: [
                                pw.BoxShadow(
                                  color: PdfColors.grey.shade(400),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                          )
                        else if (resume.heading?.name != null)
                          pw.Container(
                            width: 100,
                            height: 100,
                            margin:  pw.EdgeInsets.only(right: 25),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: PdfColors.red.shade(400),
                              border: pw.Border.all(
                                color: PdfColors.red.shade(600),
                                width: 3,
                              ),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                resume.heading!.name!.substring(0, 1).toUpperCase(),
                                style: pw.TextStyle( font: ttfFont,
                                  color: PdfColors.white,
                                  fontSize: 36,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (resume.heading?.name != null)
                                pw.Text(
                                  resume.heading!.name!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 28,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.red.shade(800),
                                  ),
                                ),

                              if (resume.heading?.position != null)
                                pw.Text(
                                  resume.heading!.position!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 16,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              pw.SizedBox(height: 15),

                              // Contact information
                              if (resume.contact != null && resume.contact!.isNotEmpty)
                                pw.Wrap(
                                  spacing: 15,
                                  runSpacing: 10,
                                  children: resume.contact!
                                      .where((c) => c.value != null && c.value!.isNotEmpty)
                                      .map((c) => pw.Row(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    children: [

                                      pw.Text(
                                        String.fromCharCode(_getContactIconCode(c.type)),
                                        style: pw.TextStyle(
                                          font: materialIcon,
                                          fontSize: 12,
                                          color: PdfColors.red.shade(600),
                                        ),
                                      ),

                                      pw.SizedBox(width: 5),
                                      pw.Text(
                                        c.value!,
                                        style:  pw.TextStyle( font: ttfFont,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 15),

                    // Profile Summary
                    if (resume.summary != null && resume.summary!.isNotEmpty)
                      _buildCreativeSection(
                        title: 'PROFILE',
                        accentColor: PdfColors.red.shade(400),
                        content: pw.Text(
                          resume.summary!,
                          style:  pw.TextStyle( font: ttfFont,
                            fontSize: 11,
                            lineSpacing: 1.5,
                          ),
                        ),
                      ),

                    // Work Experience
                    if (resume.experience != null && resume.experience!.isNotEmpty)
                      _buildCreativeSection(
                        title: 'WORK EXPERIENCE',
                        accentColor: PdfColors.red.shade(400),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.experience!
                              .where((exp) => exp.position != null || exp.company != null)
                              .map((exp) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (exp.position != null)
                                    pw.Text(
                                      exp.position!,
                                      style: pw.TextStyle( font: ttfFont,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  if (exp.duration != null)
                                    pw.Text(
                                      exp.duration!,
                                      style:  pw.TextStyle( font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                      ),
                                    ),
                                ],
                              ),

                              if (exp.company != null)
                                pw.Text(
                                  exp.company!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 11,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.SizedBox(height: 8),
                                    ...exp.responsibilities!
                                        .map((resp) => pw.Text(
                                      '• $resp',
                                      style:  pw.TextStyle( font: ttfFont,
                                        fontSize: 10,
                                        lineSpacing: 1.5,
                                      ),
                                    ))
                                  ],
                                ),
                              pw.SizedBox(height: 10),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Two column layout for bottom sections
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left column (education, skills)
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Education
                              if (resume.education != null && resume.education!.isNotEmpty)
                                _buildCreativeSection(
                                  title: 'EDUCATION',
                                  accentColor: PdfColors.red.shade(400),
                                  content: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: resume.education!
                                        .where((edu) => edu.institution != null || edu.degree != null)
                                        .map((edu) => pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        if (edu.degree != null)
                                          pw.Text(
                                            edu.degree!,
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),

                                        if (edu.institution != null)
                                          pw.Text(
                                            edu.institution!,
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                            ),
                                          ),

                                        if (edu.year != null)
                                          pw.Text(
                                            edu.year!,
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 9,
                                              color: PdfColors.grey,
                                            ),
                                          ),

                                        pw.SizedBox(height: 8),
                                      ],
                                    ))
                                        .toList(),
                                  ),
                                ),

                              // Skills
                              if (resume.skills != null && resume.skills!.isNotEmpty)
                                _buildCreativeSection(
                                  title: 'SKILLS',
                                  accentColor: PdfColors.red.shade(400),
                                  content: pw.Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: resume.skills!.expand((skillCat) => [
                                      if (skillCat.category != null)
                                        pw.Text(
                                          '${skillCat.category!.toUpperCase()}:',
                                          style: pw.TextStyle( font: ttfFont,
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ...(skillCat.items ?? []).map((skill) => pw.Container(
                                        padding:  pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: pw.BoxDecoration(
                                          color: PdfColors.red.shade(100),
                                          borderRadius: pw.BorderRadius.circular(4),
                                        ),
                                        child: pw.Text(
                                          skill,
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 9,
                                            color: PdfColors.white
                                          ),
                                        ),
                                      ))
                                    ])
                                        .toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Right column (projects, certifications)
                        pw.Expanded(
                          child: pw.Padding(
                            padding:  pw.EdgeInsets.only(left: 15),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Projects
                                if (resume.projects != null && resume.projects!.isNotEmpty)
                                  _buildCreativeSection(
                                    title: 'PROJECTS',
                                    accentColor: PdfColors.red.shade(400),
                                    content: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: resume.projects!
                                          .where((proj) => proj.name != null || proj.description != null)
                                          .map((proj) => pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          if (proj.name != null)
                                            pw.Text(
                                              proj.name!,
                                              style: pw.TextStyle( font: ttfFont,
                                                fontSize: 12,
                                                fontWeight: pw.FontWeight.bold,
                                              ),
                                            ),

                                          if (proj.technologies != null && proj.technologies!.isNotEmpty)
                                            pw.Text(
                                              'Technologies: ${proj.technologies!.join(', ')}',
                                              style:  pw.TextStyle( font: ttfFont,
                                                fontSize: 9,
                                                color: PdfColors.grey,
                                              ),
                                            ),

                                          if (proj.description != null)
                                            pw.Text(
                                              proj.description!,
                                              style:  pw.TextStyle( font: ttfFont,
                                                fontSize: 10,
                                                lineSpacing: 1.5,
                                              ),
                                            ),

                                          pw.SizedBox(height: 7),
                                        ],
                                      ))
                                          .toList(),
                                    ),
                                  ),

                                // Certifications
                                if (resume.certifications != null && resume.certifications!.isNotEmpty)
                                  _buildCreativeSection(
                                    title: 'CERTIFICATIONS',
                                    accentColor: PdfColors.red.shade(400),
                                    content: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: resume.certifications!
                                          .where((cert) => cert.name != null || cert.year != null)
                                          .map((cert) => pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (cert.name != null)
                                                pw.Text(
                                                  cert.name!,
                                                  style: pw.TextStyle( font: ttfFont,
                                                    fontSize: 10,
                                                    fontWeight: pw.FontWeight.bold,
                                                  ),
                                                ),
                                              if (cert.year != null)
                                                pw.Text(
                                                  cert.year!,
                                                  style:  pw.TextStyle( font: ttfFont,
                                                    fontSize: 9,
                                                    color: PdfColors.grey,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          pw.SizedBox(height: 10),
                                        ],
                                      ))
                                          .toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),





            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 5: Minimalist Black
  // ====================
  static void _buildMinimalistBlack(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with name and position
              if (resume.heading?.name != null)
                pw.Text(
                  resume.heading!.name!,
                  style: pw.TextStyle( font: ttfFont,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

              if (resume.heading?.position != null)
                pw.Text(
                  resume.heading!.position!,
                  style: pw.TextStyle( font: ttfFont,
                    fontSize: 14,
                    color: PdfColors.grey.shade(600),
                    letterSpacing: 1.5,
                  ),
                ),

              pw.SizedBox(height: 15),

              // Contact information
              if (resume.contact != null && resume.contact!.isNotEmpty)
                pw.Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: resume.contact!
                      .where((c) => c.value != null && c.value!.isNotEmpty)
                      .map((c) => pw.Text(
                    '${c.type?.toUpperCase() ?? ''}: ${c.value}',
                    style:  pw.TextStyle( font: ttfFont,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ))
                      .toList(),
                ),

              pw.SizedBox(height: 5),

              // Divider
              pw.Divider(
                thickness: 1,
                color: PdfColors.black,
              ),

              pw.SizedBox(height: 5),

              // Profile Summary
              if (resume.summary != null && resume.summary!.isNotEmpty)
                _buildMinimalistSection(
                  title: 'PROFILE',
                  content: pw.Text(
                    resume.summary!,
                    style:  pw.TextStyle( font: ttfFont,
                      fontSize: 11,
                      lineSpacing: 1.5,
                    ),
                  ),
                ),

              // Work Experience
              if (resume.experience != null && resume.experience!.isNotEmpty)
                _buildMinimalistSection(
                  title: 'EXPERIENCE',
                  content: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: resume.experience!
                        .where((exp) => exp.position != null || exp.company != null)
                        .map((exp) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (exp.position != null || exp.company != null)
                          pw.Text(
                            '${exp.position ?? ''}${exp.position != null && exp.company != null ? ' at ' : ''}${exp.company ?? ''}',
                            style: pw.TextStyle( font: ttfFont,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),

                        if (exp.duration != null || exp.location != null)
                          pw.Text(
                            '${exp.duration ?? ''}${exp.duration != null && exp.location != null ? ' | ' : ''}${exp.location ?? ''}',
                            style:  pw.TextStyle( font: ttfFont,
                              fontSize: 10,
                              color: PdfColors.grey,
                            ),
                          ),

                        if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: 8),
                              ...exp.responsibilities!
                                  .map((resp) => pw.Text(
                                '• $resp',
                                style:  pw.TextStyle( font: ttfFont,
                                  fontSize: 10,
                                  lineSpacing: 1.5,
                                ),
                              ))
                            ],
                          ),
                        pw.SizedBox(height: 10),
                      ],
                    ))
                        .toList(),
                  ),
                ),

              // Education
              if (resume.education != null && resume.education!.isNotEmpty)
                _buildMinimalistSection(
                  title: 'EDUCATION',
                  content: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: resume.education!
                        .where((edu) => edu.institution != null || edu.degree != null)
                        .map((edu) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (edu.degree != null || edu.institution != null)
                          pw.Text(
                            '${edu.degree ?? ''}${edu.degree != null && edu.institution != null ? ', ' : ''}${edu.institution ?? ''}',
                            style: pw.TextStyle( font: ttfFont,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),

                        if (edu.year != null)
                          pw.Text(
                            edu.year!,
                            style:  pw.TextStyle( font: ttfFont,
                              fontSize: 10,
                              color: PdfColors.grey,
                            ),
                          ),

                        pw.SizedBox(height: 7),
                      ],
                    ))
                        .toList(),
                  ),
                ),

              // Skills
              if (resume.skills != null && resume.skills!.isNotEmpty)
                _buildMinimalistSection(
                  title: 'SKILLS',
                  content: pw.Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: resume.skills!
                        .expand((skillCat) => [
                      if (skillCat.category != null)
                        pw.Text(
                          '${skillCat.category!.toUpperCase()}:',
                          style: pw.TextStyle( font: ttfFont,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ...(skillCat.items ?? [])
                          .map((skill) => pw.Text(
                        '• $skill',
                        style:  pw.TextStyle( font: ttfFont,
                          fontSize: 10,
                        ),
                      ))
                    ])
                        .toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 6: Modern Blue
  // ====================
  static void _buildTemplate06(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Row(
            children: [
              // Left sidebar - 30% width
              pw.Container(
                width: context.page.pageFormat.availableWidth * 0.3,
                color: PdfColors.deepOrangeAccent100,
                padding:  pw.EdgeInsets.all(25),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    if (avatarImage != null)
                      pw.Center(
                        child: pw.Container(
                          width: 120,
                          height: 120,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            image: pw.DecorationImage(
                              image: avatarImage,
                              fit: pw.BoxFit.cover,
                            ),
                            border: pw.Border.all(
                              color: PdfColors.white,
                              width: 3,
                            ),
                          ),
                        ),
                      )
                    else if (resume.heading?.name != null)
                      pw.Center(
                        child: pw.Container(
                          width: 120,
                          height: 120,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColors.blue.shade(700),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              resume.heading!.name!.substring(0, 1).toUpperCase(),
                              style: pw.TextStyle( font: ttfFont,
                                color: PdfColors.white,
                                fontSize: 48,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                    pw.SizedBox(height: 15),

                    // Name and Title
                    if (resume.heading?.name != null)
                      pw.Text(
                        resume.heading!.name!,
                        style: pw.TextStyle( font: ttfFont,
                          color: PdfColors.white,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                    if (resume.heading?.position != null)
                      pw.Text(
                        resume.heading!.position!,
                        style: pw.TextStyle( font: ttfFont,
                          color: PdfColors.white,
                          fontSize: 14,
                        ),
                      ),

                    pw.SizedBox(height: 10),

                    // Contact Information
                    if (resume.contact != null && resume.contact!.isNotEmpty)
                      _buildSidebarSection(
                        title: 'CONTACT',
                        titleColor: PdfColors.white,
                        items: resume.contact!
                            .where((c) => c.value != null && c.value!.isNotEmpty)
                            .map((c) => pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              c.type?.toUpperCase() ?? '',
                              style: pw.TextStyle(
                                font: ttfFont,
                                color: PdfColors.white,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              c.value!,
                              style:  pw.TextStyle( font: ttfFont,
                                color: PdfColors.white,
                                fontSize: 10,
                              ),
                            ),
                            pw.SizedBox(height: 3),
                          ],
                        ))
                            .toList(),
                      ),


                    // Skills
                    if (resume.skills != null && resume.skills!.isNotEmpty)
                      _buildSidebarSection(
                        title: 'SKILLS',
                        titleColor: PdfColors.white,
                        items: resume.skills!.expand((skillCat) => [
                          pw.Text(
                            skillCat.category?.toUpperCase() ?? '',
                            style: pw.TextStyle( font: ttfFont,
                              color: PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          ...(skillCat.items ?? [])
                              .map((skill) => pw.Text(
                            '• $skill',
                            style: pw.TextStyle( font: ttfFont,
                              color: PdfColors.white,
                              fontSize: 10,
                            ),
                          )),
                          pw.SizedBox(height: 10),
                        ])
                            .toList(),
                      ),

                    // Languages
                    if (resume.languages != null && resume.languages!.isNotEmpty)
                      _buildSidebarSection(
                        title: 'LANGUAGES',
                        titleColor: PdfColors.white,
                        items: resume.languages!
                            .map((lang) => pw.Text(
                          '${lang.name ?? ''}${lang.name != null && lang.proficiency != null ? ' - ' : ''}${lang.proficiency ?? ''}',
                          style:  pw.TextStyle( font: ttfFont,
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ))
                            .toList(),
                      ),
                  ],
                ),
              ),

              // Main content - 70% width
              pw.Container(
                width: context.page.pageFormat.availableWidth * 0.7,
                padding:  pw.EdgeInsets.all(30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Profile Summary
                    if (resume.summary != null && resume.summary!.isNotEmpty)
                      _buildMainSection(
                        title: 'PROFILE',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Text(
                          resume.summary!,
                          style:  pw.TextStyle( font: ttfFont,
                            fontSize: 11,
                            lineSpacing: 1.5,
                          ),
                        ),
                      ),

                    // Work Experience
                    if (resume.experience != null && resume.experience!.isNotEmpty)
                      _buildMainSection(
                        title: 'WORK EXPERIENCE',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.experience!
                              .where((exp) => exp.position != null || exp.company != null)
                              .map((exp) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (exp.position != null)
                                    pw.Text(
                                      exp.position!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.blue.shade(900),
                                      ),
                                    ),
                                  if (exp.duration != null)
                                    pw.Text(
                                      exp.duration!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                        fontStyle: pw.FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),

                              if (exp.company != null || exp.location != null)
                                pw.Text(
                                  '${exp.company ?? ''}${exp.company != null && exp.location != null ? ', ' : ''}${exp.location ?? ''}',
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 11,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.SizedBox(height: 8),
                                    ...exp.responsibilities!
                                        .map((resp) => pw.Text(
                                      '• $resp',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        lineSpacing: 1.5,
                                      ),
                                    ))
                                  ],
                                ),
                              pw.SizedBox(height: 7),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Education
                    if (resume.education != null && resume.education!.isNotEmpty)
                      _buildMainSection(
                        title: 'EDUCATION',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.education!
                              .where((edu) => edu.institution != null || edu.degree != null)
                              .map((edu) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (edu.degree != null)
                                    pw.Text(
                                      edu.degree!,
                                      style: pw.TextStyle( font: ttfFont,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.blue.shade(900),
                                      ),
                                    ),
                                  if (edu.year != null)
                                    pw.Text(
                                      edu.year!,
                                      style:  pw.TextStyle( font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                      ),
                                    ),
                                ],
                              ),

                              if (edu.institution != null)
                                pw.Text(
                                  edu.institution!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 11,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              pw.SizedBox(height: 7),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Projects
                    if (resume.projects != null && resume.projects!.isNotEmpty)
                      _buildMainSection(
                        title: 'PROJECTS',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.projects!
                              .where((proj) => proj.name != null || proj.description != null)
                              .map((proj) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (proj.name != null)
                                pw.Text(
                                  proj.name!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue.shade(900),
                                  ),
                                ),

                              if (proj.technologies != null && proj.technologies!.isNotEmpty)
                                pw.Text(
                                  'Technologies: ${proj.technologies!.join(', ')}',
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 10,
                                    color: PdfColors.grey,
                                    fontStyle: pw.FontStyle.italic,
                                  ),
                                ),

                              if (proj.description != null)
                                pw.Text(
                                  proj.description!,
                                  style:  pw.TextStyle( font: ttfFont,
                                    fontSize: 10,
                                    lineSpacing: 1.5,
                                  ),
                                ),

                              pw.SizedBox(height: 5),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Certifications
                    if (resume.certifications != null && resume.certifications!.isNotEmpty)
                      _buildMainSection(
                        title: 'CERTIFICATIONS',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.certifications!
                              .where((cert) => cert.name != null || cert.year != null)
                              .map((cert) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (cert.name != null)
                                    pw.Text(
                                      cert.name!,
                                      style: pw.TextStyle( font: ttfFont,
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  if (cert.year != null)
                                    pw.Text(
                                      cert.year!,
                                      style:  pw.TextStyle( font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              pw.SizedBox(height: 5),
                            ],
                          )).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 7: Modern Blue
  // ====================
  static void _buildTemplate07(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Row(
            children: [
              // Left sidebar - 30% width
              pw.Container(
                width: context.page.pageFormat.availableWidth * 0.3,
                color: PdfColor.fromInt(0xFF077A7D), // Custom color (Deep Orange with full opacity)
                padding:  pw.EdgeInsets.all(25),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    if (avatarImage != null)
                      pw.Center(
                        child: pw.Container(
                          width: 120,
                          height: 120,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            image: pw.DecorationImage(
                              image: avatarImage,
                              fit: pw.BoxFit.cover,
                            ),
                            border: pw.Border.all(
                              color: PdfColors.white,
                              width: 3,
                            ),
                          ),
                        ),
                      )
                    else if (resume.heading?.name != null)
                      pw.Center(
                        child: pw.Container(
                          width: 120,
                          height: 120,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColors.blue.shade(700),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              resume.heading!.name!.substring(0, 1).toUpperCase(),
                              style: pw.TextStyle( font: ttfFont,
                                color: PdfColors.white,
                                fontSize: 48,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                    pw.SizedBox(height: 15),

                    // Name and Title
                    if (resume.heading?.name != null)
                      pw.Text(
                        resume.heading!.name!,
                        style: pw.TextStyle( font: ttfFont,
                          color: PdfColors.white,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                    if (resume.heading?.position != null)
                      pw.Text(
                        resume.heading!.position!,
                        style: pw.TextStyle( font: ttfFont,
                          color: PdfColors.white,
                          fontSize: 14,
                        ),
                      ),

                    pw.SizedBox(height: 10),

                    // Contact Information
                    if (resume.contact != null && resume.contact!.isNotEmpty)
                      _buildSidebarSection(
                        title: 'CONTACT',
                        titleColor: PdfColors.white,
                        items: resume.contact!
                            .where((c) => c.value != null && c.value!.isNotEmpty)
                            .map((c) => pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              c.type?.toUpperCase() ?? '',
                              style: pw.TextStyle(
                                font: ttfFont,
                                color: PdfColors.white,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              c.value!,
                              style:  pw.TextStyle( font: ttfFont,
                                color: PdfColors.white,
                                fontSize: 10,
                              ),
                            ),
                            pw.SizedBox(height: 3),
                          ],
                        ))
                            .toList(),
                      ),


                    // Skills
                    if (resume.skills != null && resume.skills!.isNotEmpty)
                      _buildSidebarSection(
                        title: 'SKILLS',
                        titleColor: PdfColors.white,
                        items: resume.skills!.expand((skillCat) => [
                          pw.Text(
                            skillCat.category?.toUpperCase() ?? '',
                            style: pw.TextStyle( font: ttfFont,
                              color: PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          ...(skillCat.items ?? [])
                              .map((skill) => pw.Text(
                            '• $skill',
                            style: pw.TextStyle( font: ttfFont,
                              color: PdfColors.white,
                              fontSize: 10,
                            ),
                          )),
                          pw.SizedBox(height: 10),
                        ])
                            .toList(),
                      ),

                    // Languages
                    if (resume.languages != null && resume.languages!.isNotEmpty)
                      _buildSidebarSection(
                        title: 'LANGUAGES',
                        titleColor: PdfColors.white,
                        items: resume.languages!
                            .map((lang) => pw.Text(
                          '${lang.name ?? ''}${lang.name != null && lang.proficiency != null ? ' - ' : ''}${lang.proficiency ?? ''}',
                          style:  pw.TextStyle( font: ttfFont,
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ))
                            .toList(),
                      ),
                  ],
                ),
              ),

              // Main content - 70% width
              pw.Container(
                width: context.page.pageFormat.availableWidth * 0.7,
                padding:  pw.EdgeInsets.all(30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Profile Summary
                    if (resume.summary != null && resume.summary!.isNotEmpty)
                      _buildMainSection(
                        title: 'PROFILE',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Text(
                          resume.summary!,
                          style:  pw.TextStyle( font: ttfFont,
                            fontSize: 11,
                            lineSpacing: 1.5,
                          ),
                        ),
                      ),

                    // Work Experience
                    if (resume.experience != null && resume.experience!.isNotEmpty)
                      _buildMainSection(
                        title: 'WORK EXPERIENCE',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.experience!
                              .where((exp) => exp.position != null || exp.company != null)
                              .map((exp) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (exp.position != null)
                                    pw.Text(
                                      exp.position!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.blue.shade(900),
                                      ),
                                    ),
                                  if (exp.duration != null)
                                    pw.Text(
                                      exp.duration!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                        fontStyle: pw.FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),

                              if (exp.company != null || exp.location != null)
                                pw.Text(
                                  '${exp.company ?? ''}${exp.company != null && exp.location != null ? ', ' : ''}${exp.location ?? ''}',
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 11,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.SizedBox(height: 8),
                                    ...exp.responsibilities!
                                        .map((resp) => pw.Text(
                                      '• $resp',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        lineSpacing: 1.5,
                                      ),
                                    ))
                                  ],
                                ),
                              pw.SizedBox(height: 7),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Education
                    if (resume.education != null && resume.education!.isNotEmpty)
                      _buildMainSection(
                        title: 'EDUCATION',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.education!
                              .where((edu) => edu.institution != null || edu.degree != null)
                              .map((edu) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (edu.degree != null)
                                    pw.Text(
                                      edu.degree!,
                                      style: pw.TextStyle( font: ttfFont,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.blue.shade(900),
                                      ),
                                    ),
                                  if (edu.year != null)
                                    pw.Text(
                                      edu.year!,
                                      style:  pw.TextStyle( font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                      ),
                                    ),
                                ],
                              ),

                              if (edu.institution != null)
                                pw.Text(
                                  edu.institution!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 11,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              pw.SizedBox(height: 7),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Projects
                    if (resume.projects != null && resume.projects!.isNotEmpty)
                      _buildMainSection(
                        title: 'PROJECTS',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.projects!
                              .where((proj) => proj.name != null || proj.description != null)
                              .map((proj) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (proj.name != null)
                                pw.Text(
                                  proj.name!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue.shade(900),
                                  ),
                                ),

                              if (proj.technologies != null && proj.technologies!.isNotEmpty)
                                pw.Text(
                                  'Technologies: ${proj.technologies!.join(', ')}',
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 10,
                                    color: PdfColors.grey,
                                    fontStyle: pw.FontStyle.italic,
                                  ),
                                ),

                              if (proj.description != null)
                                pw.Text(
                                  proj.description!,
                                  style:  pw.TextStyle( font: ttfFont,
                                    fontSize: 10,
                                    lineSpacing: 1.5,
                                  ),
                                ),

                              pw.SizedBox(height: 5),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Certifications
                    if (resume.certifications != null && resume.certifications!.isNotEmpty)
                      _buildMainSection(
                        title: 'CERTIFICATIONS',
                        titleColor: PdfColors.blue.shade(900),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.certifications!
                              .where((cert) => cert.name != null || cert.year != null)
                              .map((cert) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (cert.name != null)
                                    pw.Text(
                                      cert.name!,
                                      style: pw.TextStyle( font: ttfFont,
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  if (cert.year != null)
                                    pw.Text(
                                      cert.year!,
                                      style:  pw.TextStyle( font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              pw.SizedBox(height: 5),
                            ],
                          )).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 8: Modern Green
  // ====================
  static void _buildTemplate08(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Background decoration
              pw.Positioned(
                top: 0,
                right: 0,
                child: pw.Container(
                  width: 120,
                  height: 120,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFD4C9BE),
                    borderRadius:  pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(100),
                    ),
                  ),
                ),
              ),




              pw.Positioned(
                bottom: 0,
                right: 0,
                child: pw.Transform.rotate(
                  angle: 4.72, // 180 degrees in radians
                  child: pw.Container(
                    width: 120,
                    height: 120,
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFD4C9BE),
                      borderRadius: pw.BorderRadius.only(
                        bottomLeft: pw.Radius.circular(100),
                      ),
                    ),
                  ),
                ),
              ),






              pw.Padding(
                padding:  pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header with avatar and name
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (avatarImage != null)
                          pw.Container(
                            width: 100,
                            height: 100,
                            margin:  pw.EdgeInsets.only(right: 25),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              image: pw.DecorationImage(
                                image: avatarImage,
                                fit: pw.BoxFit.cover,
                              ),
                              border: pw.Border.all(
                                color: PdfColors.green.shade(400),
                                width: 3,
                              ),
                            ),
                          )
                        else if (resume.heading?.name != null)
                          pw.Container(
                            width: 100,
                            height: 100,
                            margin:  pw.EdgeInsets.only(right: 25),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: PdfColors.green.shade(300),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                resume.heading!.name!.substring(0, 1).toUpperCase(),
                                style: pw.TextStyle( font: ttfFont,
                                  color: PdfColors.white,
                                  fontSize: 48,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (resume.heading?.name != null)
                                pw.Text(
                                  resume.heading!.name!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 28,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green.shade(800),
                                  ),
                                ),

                              if (resume.heading?.position != null)
                                pw.Text(
                                  resume.heading!.position!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 16,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              pw.SizedBox(height: 15),

                              // Contact information inline
                              if (resume.contact != null && resume.contact!.isNotEmpty)
                                pw.Wrap(
                                  spacing: 15,
                                  runSpacing: 10,
                                  children: resume.contact!
                                      .where((c) => c.value != null && c.value!.isNotEmpty)
                                      .map((c) => pw.Row(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    children: [
                                      pw.Text(
                                        String.fromCharCode(_getContactIconCode(c.type)),
                                        style: pw.TextStyle(
                                          font: materialIcon,
                                          fontSize: 12,
                                          color: PdfColors.green.shade(600),
                                        ),
                                      ),

                                      pw.SizedBox(width: 5),
                                      pw.Text(
                                        c.value!,
                                        style:  pw.TextStyle( font: ttfFont,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 15),

                    // Profile Summary
                    if (resume.summary != null && resume.summary!.isNotEmpty)
                      _buildModernSection(
                        title: 'PROFILE',
                        accentColor: PdfColors.green.shade(400),
                        content: pw.Text(
                          resume.summary!,
                          style:  pw.TextStyle( font: ttfFont,
                            fontSize: 11,
                            lineSpacing: 1.5,
                          ),
                        ),
                      ),

                    // Work Experience
                    if (resume.experience != null && resume.experience!.isNotEmpty)
                      _buildModernSection(
                        title: 'WORK EXPERIENCE',
                        accentColor: PdfColors.green.shade(400),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.experience!
                              .where((exp) => exp.position != null || exp.company != null)
                              .map((exp) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    width: 12,
                                    height: 12,
                                    margin:  pw.EdgeInsets.only(top: 4, right: 10),
                                    decoration: pw.BoxDecoration(
                                      shape: pw.BoxShape.circle,
                                      color: PdfColors.green.shade(400),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        if (exp.position != null)
                                          pw.Text(
                                            exp.position!,
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),

                                        if (exp.company != null || exp.duration != null)
                                          pw.Text(
                                            '${exp.company ?? ''}${exp.company != null && exp.duration != null ? ' | ' : ''}${exp.duration ?? ''}',
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                              color: PdfColors.grey,
                                            ),
                                          ),

                                        if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                          pw.Column(
                                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.SizedBox(height: 8),
                                              ...exp.responsibilities!
                                                  .map((resp) => pw.Text(
                                                '• $resp',
                                                style:  pw.TextStyle( font: ttfFont,
                                                  fontSize: 10,
                                                  lineSpacing: 1.5,
                                                ),
                                              ))
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 8),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Education
                    if (resume.education != null && resume.education!.isNotEmpty)
                      _buildModernSection(
                        title: 'EDUCATION',
                        accentColor: PdfColors.green.shade(400),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.education!
                              .where((edu) => edu.institution != null || edu.degree != null)
                              .map((edu) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    width: 12,
                                    height: 12,
                                    margin:  pw.EdgeInsets.only(top: 4, right: 10),
                                    decoration: pw.BoxDecoration(
                                      shape: pw.BoxShape.circle,
                                      color: PdfColors.green.shade(400),
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        if (edu.degree != null)
                                          pw.Text(
                                            edu.degree!,
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),

                                        if (edu.institution != null || edu.year != null)
                                          pw.Text(
                                            '${edu.institution ?? ''}${edu.institution != null && edu.year != null ? ' | ' : ''}${edu.year ?? ''}',
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                              color: PdfColors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 8),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Skills
                    if (resume.skills != null && resume.skills!.isNotEmpty)
                      _buildModernSection(
                        title: 'SKILLS',
                        accentColor: PdfColors.green.shade(400),
                        content: pw.Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: resume.skills!.expand((skillCat) => [
                            if (skillCat.category != null)
                              pw.Text(
                                '${skillCat.category!.toUpperCase()}:',
                                style: pw.TextStyle( font: ttfFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ...(skillCat.items ?? []).map((skill) => pw.Container(
                              padding:  pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFFD4C9BE),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(
                                skill,
                                style:  pw.TextStyle( font: ttfFont,
                                  color: PdfColors.black,
                                  fontSize: 10,
                                ),
                              ),
                            ))
                          ]).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  // ====================
  // TEMPLATE 9: Elegant Purple
  // ====================
  static void _buildTemplate09(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Header background
              pw.Container(
                height: 120,
                width: double.infinity,
                color: PdfColor.fromInt(0xFF5F8B4C)
              ),

              pw.Padding(
                padding:  pw.EdgeInsets.all(30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    // Header with avatar
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (avatarImage != null)
                          pw.Container(
                            width: 80,
                            height: 80,
                            margin:  pw.EdgeInsets.only(right: 20),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              image: pw.DecorationImage(
                                image: avatarImage,
                                fit: pw.BoxFit.cover,
                              ),
                              border: pw.Border.all(
                                color: PdfColors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                pw.BoxShadow(
                                  color: PdfColors.grey.shade(400),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                          )
                        else if (resume.heading?.name != null)
                          pw.Container(
                            width: 80,
                            height: 80,
                            margin:  pw.EdgeInsets.only(right: 20),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: PdfColors.purple.shade(700),
                              border: pw.Border.all(
                                color: PdfColors.white,
                                width: 3,
                              ),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                resume.heading!.name!.substring(0, 1).toUpperCase(),
                                style: pw.TextStyle( font: ttfFont,
                                  color: PdfColors.white,
                                  fontSize: 36,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              if (resume.heading?.name != null)
                                pw.Text(
                                  resume.heading!.name!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                ),

                              if (resume.heading?.position != null)
                                pw.Text(
                                  resume.heading!.position!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 14,
                                    color: PdfColors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 20),

                    // Two column layout
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left column (60%)
                        pw.Expanded(
                          flex: 6,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              // Profile Summary
                              if (resume.summary != null && (resume.summary?.isNotEmpty ?? false))
                                _buildElegantSection(
                                  title: 'PROFILE',
                                  accentColor: PdfColor.fromInt(0xFF5F8B4C),
                                  content: pw.Text(
                                    resume.summary!,
                                    style:  pw.TextStyle( font: ttfFont,
                                      fontSize: 11,
                                      lineSpacing: 1.5,
                                    ),
                                  ),
                                ),

                              // Work Experience
                              if (resume.experience != null && (resume.experience?.isNotEmpty ?? false))
                                _buildElegantSection(
                                  title: 'EXPERIENCE',
                                  accentColor: PdfColor.fromInt(0xFF5F8B4C),
                                  content: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: resume.experience!
                                        .where((exp) => exp.position != null || exp.company != null)
                                        .map((exp) => pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        if (exp.position != null)
                                          pw.Text(
                                            exp.position!,
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),

                                        if (exp.company != null || exp.duration != null)
                                          pw.Text(
                                            '${exp.company ?? ''}${exp.company != null && exp.duration != null ? ' | ' : ''}${exp.duration ?? ''}',
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                              color: PdfColors.grey,
                                            ),
                                          ),

                                        if (exp.responsibilities != null && (exp.responsibilities?.isNotEmpty ?? false))
                                          pw.Column(
                                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.SizedBox(height: 8),
                                              ...exp.responsibilities!
                                                  .map((resp) => pw.Text(
                                                '- $resp',
                                                style:  pw.TextStyle( font: ttfFont,
                                                  fontSize: 10,
                                                  lineSpacing: 1.5,
                                                ),
                                              ))
                                            ],
                                          ),
                                        pw.SizedBox(height: 15),
                                      ],
                                    ))
                                        .toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Right column (40%)
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding:  pw.EdgeInsets.only(left: 20),
                            child: pw.Column(
                              mainAxisSize: pw.MainAxisSize.min,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Contact Information
                                if (resume.contact != null && (resume.contact?.isNotEmpty ?? false))
                                  _buildElegantSection(
                                    title: 'CONTACT',
                                    accentColor: PdfColor.fromInt(0xFF5F8B4C),
                                    content: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: resume.contact!
                                          .where((c) => c.value != null && c.value!.isNotEmpty)
                                          .map((c) => pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            c.type?.toUpperCase() ?? '',
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.purple.shade(900),
                                            ),
                                          ),
                                          pw.Text(
                                            c.value!,
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                            ),
                                          ),
                                          pw.SizedBox(height: 8),
                                        ],
                                      ))
                                          .toList(),
                                    ),
                                  ),

                                // Education
                                if (resume.education != null && (resume.education?.isNotEmpty ?? false))
                                  _buildElegantSection(
                                    title: 'EDUCATION',
                                    accentColor: PdfColor.fromInt(0xFF5F8B4C),
                                    content: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: resume.education!
                                          .where((edu) => edu.institution != null || edu.degree != null)
                                          .map((edu) => pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          if (edu.degree != null)
                                            pw.Text(
                                              edu.degree!,
                                              style: pw.TextStyle( font: ttfFont,
                                                fontSize: 12,
                                                fontWeight: pw.FontWeight.bold,
                                              ),
                                            ),

                                          if (edu.institution != null)
                                            pw.Text(
                                              edu.institution!,
                                              style:  pw.TextStyle( font: ttfFont,
                                                fontSize: 10,
                                              ),
                                            ),

                                          if (edu.year != null)
                                            pw.Text(
                                              edu.year!,
                                              style:  pw.TextStyle( font: ttfFont,
                                                fontSize: 9,
                                                color: PdfColors.grey,
                                              ),
                                            ),

                                          pw.SizedBox(height: 10),
                                        ],
                                      ))
                                          .toList(),
                                    ),
                                  ),

                                // Skills
                                if (resume.skills != null && (resume.skills?.isNotEmpty ?? false))
                                  _buildElegantSection(
                                    title: 'SKILLS',
                                    accentColor: PdfColor.fromInt(0xFF5F8B4C),
                                    content: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: resume.skills!
                                          .where((skillCat) => skillCat.category != null && (skillCat.items?.isNotEmpty ?? false))
                                          .map((skillCat) => pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            skillCat.category!,
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 11,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                          pw.SizedBox(height: 5),
                                          ...(skillCat.items ?? [])
                                              .map((skill) => pw.Text(
                                            '• $skill',
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                            ),
                                          )),
                                          pw.SizedBox(height: 10),
                                        ],
                                      ))
                                          .toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 10: Creative Red
  // ====================
  static void _buildTemplate10(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Stack(
            children: [

              // Decorative elements
              pw.Positioned(
                top: 0,
                right: 0,
                child: pw.Container(
                  width: 110,
                  height: 110,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF183B4E),
                    borderRadius:  pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(75),
                    ),
                  ),
                ),
              ),

              pw.Positioned(
                bottom: 0,
                left: 0,
                child: pw.Container(
                  width: 80,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF183B4E),
                    borderRadius:  pw.BorderRadius.only(
                      topRight: pw.Radius.circular(50),
                    ),
                  ),
                ),
              ),


              pw.Padding(
                padding:  pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header with avatar
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (avatarImage != null)
                          pw.Container(
                            width: 100,
                            height: 100,
                            margin:  pw.EdgeInsets.only(right: 25),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              image: pw.DecorationImage(
                                image: avatarImage,
                                fit: pw.BoxFit.cover,
                              ),
                              border: pw.Border.all(
                                color: PdfColors.red.shade(400),
                                width: 3,
                              ),
                              boxShadow: [
                                pw.BoxShadow(
                                  color: PdfColors.grey.shade(400),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                          )
                        else if (resume.heading?.name != null)
                          pw.Container(
                            width: 100,
                            height: 100,
                            margin:  pw.EdgeInsets.only(right: 25),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: PdfColors.red.shade(400),
                              border: pw.Border.all(
                                color: PdfColors.red.shade(600),
                                width: 3,
                              ),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                resume.heading!.name!.substring(0, 1).toUpperCase(),
                                style: pw.TextStyle( font: ttfFont,
                                  color: PdfColors.white,
                                  fontSize: 36,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (resume.heading?.name != null)
                                pw.Text(
                                  resume.heading!.name!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 28,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.red.shade(800),
                                  ),
                                ),

                              if (resume.heading?.position != null)
                                pw.Text(
                                  resume.heading!.position!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 16,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              pw.SizedBox(height: 15),

                              // Contact information
                              if (resume.contact != null && resume.contact!.isNotEmpty)
                                pw.Wrap(
                                  spacing: 15,
                                  runSpacing: 10,
                                  children: resume.contact!
                                      .where((c) => c.value != null && c.value!.isNotEmpty)
                                      .map((c) => pw.Row(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    children: [

                                      pw.Text(
                                        String.fromCharCode(_getContactIconCode(c.type)),
                                        style: pw.TextStyle(
                                          font: materialIcon,
                                          fontSize: 12,
                                          color: PdfColors.red.shade(600),
                                        ),
                                      ),

                                      pw.SizedBox(width: 5),
                                      pw.Text(
                                        c.value!,
                                        style:  pw.TextStyle( font: ttfFont,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 15),

                    // Profile Summary
                    if (resume.summary != null && resume.summary!.isNotEmpty)
                      _buildCreativeSection(
                        title: 'PROFILE',
                        accentColor: PdfColor.fromInt(0xFF183B4E),
                        content: pw.Text(
                          resume.summary!,
                          style:  pw.TextStyle( font: ttfFont,
                            fontSize: 11,
                            lineSpacing: 1.5,
                          ),
                        ),
                      ),

                    // Work Experience
                    if (resume.experience != null && resume.experience!.isNotEmpty)
                      _buildCreativeSection(
                        title: 'WORK EXPERIENCE',
                        accentColor: PdfColor.fromInt(0xFF183B4E),
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.experience!
                              .where((exp) => exp.position != null || exp.company != null)
                              .map((exp) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  if (exp.position != null)
                                    pw.Text(
                                      exp.position!,
                                      style: pw.TextStyle( font: ttfFont,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  if (exp.duration != null)
                                    pw.Text(
                                      exp.duration!,
                                      style:  pw.TextStyle( font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                      ),
                                    ),
                                ],
                              ),

                              if (exp.company != null)
                                pw.Text(
                                  exp.company!,
                                  style: pw.TextStyle( font: ttfFont,
                                    fontSize: 11,
                                    color: PdfColors.grey.shade(600),
                                  ),
                                ),

                              if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.SizedBox(height: 8),
                                    ...exp.responsibilities!
                                        .map((resp) => pw.Text(
                                      '• $resp',
                                      style:  pw.TextStyle( font: ttfFont,
                                        fontSize: 10,
                                        lineSpacing: 1.5,
                                      ),
                                    ))
                                  ],
                                ),
                              pw.SizedBox(height: 10),
                            ],
                          )).toList(),
                        ),
                      ),

                    // Two column layout for bottom sections
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left column (education, skills)
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Education
                              if (resume.education != null && resume.education!.isNotEmpty)
                                _buildCreativeSection(
                                  title: 'EDUCATION',
                                  accentColor: PdfColor.fromInt(0xFF183B4E),
                                  content: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: resume.education!
                                        .where((edu) => edu.institution != null || edu.degree != null)
                                        .map((edu) => pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        if (edu.degree != null)
                                          pw.Text(
                                            edu.degree!,
                                            style: pw.TextStyle( font: ttfFont,
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),

                                        if (edu.institution != null)
                                          pw.Text(
                                            edu.institution!,
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 10,
                                            ),
                                          ),

                                        if (edu.year != null)
                                          pw.Text(
                                            edu.year!,
                                            style:  pw.TextStyle( font: ttfFont,
                                              fontSize: 9,
                                              color: PdfColors.grey,
                                            ),
                                          ),

                                        pw.SizedBox(height: 8),
                                      ],
                                    ))
                                        .toList(),
                                  ),
                                ),

                              // Skills
                              if (resume.skills != null && resume.skills!.isNotEmpty)
                                _buildCreativeSection(
                                  title: 'SKILLS',
                                  accentColor: PdfColor.fromInt(0xFF183B4E),
                                  content: pw.Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: resume.skills!.expand((skillCat) => [
                                      if (skillCat.category != null)
                                        pw.Text(
                                          '${skillCat.category!.toUpperCase()}:',
                                          style: pw.TextStyle( font: ttfFont,
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ...(skillCat.items ?? []).map((skill) => pw.Container(
                                        padding:  pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: pw.BoxDecoration(
                                          color: PdfColor.fromInt(0xFF183B4E),
                                          borderRadius: pw.BorderRadius.circular(4),
                                        ),
                                        child: pw.Text(
                                          skill,
                                          style: pw.TextStyle(
                                              font: ttfFont,
                                              fontSize: 9,
                                              color: PdfColors.white
                                          ),
                                        ),
                                      ))
                                    ])
                                        .toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Right column (projects, certifications)
                        pw.Expanded(
                          child: pw.Padding(
                            padding:  pw.EdgeInsets.only(left: 15),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Projects
                                if (resume.projects != null && resume.projects!.isNotEmpty)
                                  _buildCreativeSection(
                                    title: 'PROJECTS',
                                    accentColor: PdfColor.fromInt(0xFF183B4E),
                                    content: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: resume.projects!
                                          .where((proj) => proj.name != null || proj.description != null)
                                          .map((proj) => pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          if (proj.name != null)
                                            pw.Text(
                                              proj.name!,
                                              style: pw.TextStyle( font: ttfFont,
                                                fontSize: 12,
                                                fontWeight: pw.FontWeight.bold,
                                              ),
                                            ),

                                          if (proj.technologies != null && proj.technologies!.isNotEmpty)
                                            pw.Text(
                                              'Technologies: ${proj.technologies!.join(', ')}',
                                              style:  pw.TextStyle( font: ttfFont,
                                                fontSize: 9,
                                                color: PdfColors.grey,
                                              ),
                                            ),

                                          if (proj.description != null)
                                            pw.Text(
                                              proj.description!,
                                              style:  pw.TextStyle( font: ttfFont,
                                                fontSize: 10,
                                                lineSpacing: 1.5,
                                              ),
                                            ),

                                          pw.SizedBox(height: 7),
                                        ],
                                      ))
                                          .toList(),
                                    ),
                                  ),

                                // Certifications
                                if (resume.certifications != null && resume.certifications!.isNotEmpty)
                                  _buildCreativeSection(
                                    title: 'CERTIFICATIONS',
                                    accentColor: PdfColor.fromInt(0xFF183B4E),
                                    content: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: resume.certifications!
                                          .where((cert) => cert.name != null || cert.year != null)
                                          .map((cert) => pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (cert.name != null)
                                                pw.Text(
                                                  cert.name!,
                                                  style: pw.TextStyle( font: ttfFont,
                                                    fontSize: 10,
                                                    fontWeight: pw.FontWeight.bold,
                                                  ),
                                                ),
                                              if (cert.year != null)
                                                pw.Text(
                                                  cert.year!,
                                                  style:  pw.TextStyle( font: ttfFont,
                                                    fontSize: 9,
                                                    color: PdfColors.grey,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          pw.SizedBox(height: 10),
                                        ],
                                      ))
                                          .toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),





            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 11: Minimalist
  // ====================

  static void _buildTemplate11(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with avatar, name and position
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (avatarImage != null)
                    pw.Container(
                      width: 60,
                      height: 60,
                      margin: pw.EdgeInsets.only(right: 15),
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(
                          image: avatarImage,
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (resume.heading?.name != null)
                          pw.Text(
                            resume.heading!.name!,
                            style: pw.TextStyle(
                              font: ttfFont,
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        if (resume.heading?.position != null)
                          pw.Text(
                            resume.heading!.position!,
                            style: pw.TextStyle(
                              font: ttfFont,
                              fontSize: 14,
                              color: PdfColors.grey600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 15),

              // Two column layout
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left column (40%)
                  pw.Container(
                    width: context.page.pageFormat.availableWidth * 0.4,
                    padding: pw.EdgeInsets.only(right: 20),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Contact information
                        if (resume.contact != null && resume.contact!.isNotEmpty)
                          _buildModernSection02(
                            title: 'CONTACT',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.contact!
                                  .where((c) => c.value != null && c.value!.isNotEmpty)
                                  .map((c) => pw.Padding(
                                padding: pw.EdgeInsets.only(bottom: 5),
                                child: pw.Text(
                                  c.value!,
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 10,
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),
                          ),

                        // Skills
                        if (resume.skills != null && resume.skills!.isNotEmpty)
                          _buildModernSection02(
                            title: 'SKILLS',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.skills!
                                  .where((skillCat) => skillCat.items != null && skillCat.items!.isNotEmpty)
                                  .map((skillCat) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  if (skillCat.category != null)
                                    pw.Text(
                                      skillCat.category!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  pw.SizedBox(height: 3),
                                  pw.Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: (skillCat.items ?? [])
                                        .map((skill) => pw.Text(
                                      '• $skill',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                      ),
                                    ))
                                        .toList(),
                                  ),
                                  pw.SizedBox(height: 8),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),

                        // Languages
                        if (resume.languages != null && resume.languages!.isNotEmpty)
                          _buildModernSection02(
                            title: 'LANGUAGES',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.languages!
                                  .map((lang) => pw.Text(
                                '${lang.name ?? ''}${lang.name != null && lang.proficiency != null ? ' - ' : ''}${lang.proficiency ?? ''}',
                                style: pw.TextStyle(
                                  font: ttfFont,
                                  fontSize: 10,
                                ),
                              ))
                                  .toList(),
                            ),
                          ),

                        // Certifications
                        if (resume.certifications != null && resume.certifications!.isNotEmpty)
                          _buildModernSection02(
                            title: 'CERTIFICATIONS',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.certifications!
                                  .map((cert) => pw.Padding(
                                padding: pw.EdgeInsets.only(bottom: 5),
                                child: pw.Text(
                                  '${cert.name ?? ''}${cert.name != null && cert.year != null ? ' (${cert.year})' : ''}',
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 10,
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Right column (60%)
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Profile Summary
                        if (resume.summary != null && resume.summary!.isNotEmpty)
                          _buildModernSection02(
                            title: 'PROFILE',
                            content: pw.Text(
                              resume.summary!,
                              style: pw.TextStyle(
                                font: ttfFont,
                                fontSize: 11,
                                lineSpacing: 1.5,
                              ),
                            ),
                          ),

                        // Work Experience
                        if (resume.experience != null && resume.experience!.isNotEmpty)
                          _buildModernSection02(
                            title: 'EXPERIENCE',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.experience!
                                  .where((exp) => exp.position != null || exp.company != null)
                                  .map((exp) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Text(
                                          exp.position ?? '',
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (exp.duration != null)
                                        pw.Text(
                                          exp.duration!,
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                            color: PdfColors.grey600,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (exp.company != null)
                                    pw.Text(
                                      exp.company!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 11,
                                        color: PdfColors.grey600,
                                      ),
                                    ),
                                  if (exp.location != null)
                                    pw.Text(
                                      exp.location!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey600,
                                      ),
                                    ),
                                  if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                    pw.Padding(
                                      padding: pw.EdgeInsets.only(top: 5),
                                      child: pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: exp.responsibilities!
                                            .map((resp) => pw.Text(
                                          '• $resp',
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                            lineSpacing: 1.5,
                                          ),
                                        ))
                                            .toList(),
                                      ),
                                    ),
                                  pw.SizedBox(height: 10),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),

                        // Education
                        if (resume.education != null && resume.education!.isNotEmpty)
                          _buildModernSection02(
                            title: 'EDUCATION',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.education!
                                  .where((edu) => edu.institution != null || edu.degree != null)
                                  .map((edu) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Text(
                                          edu.degree ?? '',
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (edu.year != null)
                                        pw.Text(
                                          edu.year!,
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                            color: PdfColors.grey600,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (edu.institution != null)
                                    pw.Text(
                                      edu.institution!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 11,
                                      ),
                                    ),
                                  pw.SizedBox(height: 8),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),

                        // Projects
                        if (resume.projects != null && resume.projects!.isNotEmpty)
                          _buildModernSection02(
                            title: 'PROJECTS',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.projects!
                                  .map((project) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  if (project.name != null)
                                    pw.Text(
                                      project.name!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  if (project.description != null)
                                    pw.Text(
                                      project.description!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        lineSpacing: 1.5,
                                      ),
                                    ),
                                  if (project.technologies != null && project.technologies!.isNotEmpty)
                                    pw.Wrap(
                                      spacing: 5,
                                      runSpacing: 5,
                                      children: [
                                        pw.Text(
                                          'Technologies: ',
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        ...project.technologies!
                                            .map((tech) => pw.Text(
                                          '$tech, ',
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                          ),
                                        ))
                                            .toList(),
                                      ],
                                    ),
                                  pw.SizedBox(height: 8),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 12: Elegant
  // ====================

  static void _buildTemplate12(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(25),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (resume.heading?.name != null)
                    pw.Text(
                      resume.heading!.name!.toUpperCase(),
                      style: pw.TextStyle(
                        font: ttfFont,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  if (resume.heading?.position != null)
                    pw.Text(
                      resume.heading!.position!,
                      style: pw.TextStyle(
                        font: ttfFont,
                        fontSize: 14,
                        color: PdfColors.grey600,
                      ),
                    ),
                  pw.SizedBox(height: 10),
                  pw.Divider(
                    thickness: 1,
                    color: PdfColors.grey400,
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Contact information in a single line
              if (resume.contact != null && resume.contact!.isNotEmpty)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: resume.contact!
                      .where((c) => c.value != null && c.value!.isNotEmpty)
                      .map((c) => pw.Text(
                    '${c.type ?? ''}: ${c.value}',
                    style: pw.TextStyle(
                      font: ttfFont,
                      fontSize: 10,
                    ),
                  ))
                      .toList(),
                ),

              pw.SizedBox(height: 15),

              // Profile Summary
              if (resume.summary != null && resume.summary!.isNotEmpty)
                _buildClassicSection(
                  title: 'PROFESSIONAL SUMMARY',
                  content: pw.Text(
                    resume.summary!,
                    style: pw.TextStyle(
                      font: ttfFont,
                      fontSize: 11,
                      lineSpacing: 1.5,
                    ),
                  ),
                ),

              // Work Experience
              if (resume.experience != null && resume.experience!.isNotEmpty)
                _buildClassicSection(
                  title: 'PROFESSIONAL EXPERIENCE',
                  content: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: resume.experience!
                        .where((exp) => exp.position != null || exp.company != null)
                        .map((exp) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                exp.position ?? '',
                                style: pw.TextStyle(
                                  font: ttfFont,
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            if (exp.duration != null)
                              pw.Text(
                                exp.duration!,
                                style: pw.TextStyle(
                                  font: ttfFont,
                                  fontSize: 11,
                                  color: PdfColors.grey600,
                                ),
                              ),
                          ],
                        ),
                        if (exp.company != null)
                          pw.Text(
                            exp.company!,
                            style: pw.TextStyle(
                              font: ttfFont,
                              fontSize: 12,
                              color: PdfColors.grey600,
                            ),
                          ),
                        if (exp.location != null)
                          pw.Text(
                            exp.location!,
                            style: pw.TextStyle(
                              font: ttfFont,
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                          pw.Padding(
                            padding: pw.EdgeInsets.only(top: 5, left: 10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: exp.responsibilities!
                                  .map((resp) => pw.Text(
                                '• $resp',
                                style: pw.TextStyle(
                                  font: ttfFont,
                                  fontSize: 10,
                                  lineSpacing: 1.5,
                                ),
                              ))
                                  .toList(),
                            ),
                          ),
                        pw.SizedBox(height: 10),
                      ],
                    ))
                        .toList(),
                  ),
                ),

              // Two column layout for bottom sections
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left column (50%)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Education
                        if (resume.education != null && resume.education!.isNotEmpty)
                          _buildClassicSection(
                            title: 'EDUCATION',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.education!
                                  .where((edu) => edu.institution != null || edu.degree != null)
                                  .map((edu) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  if (edu.degree != null)
                                    pw.Text(
                                      edu.degree!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  if (edu.institution != null)
                                    pw.Text(
                                      edu.institution!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 11,
                                      ),
                                    ),
                                  if (edu.year != null)
                                    pw.Text(
                                      edu.year!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey600,
                                      ),
                                    ),
                                  pw.SizedBox(height: 8),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),

                        // Skills
                        if (resume.skills != null && resume.skills!.isNotEmpty)
                          _buildClassicSection(
                            title: 'SKILLS',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.skills!
                                  .where((skillCat) => skillCat.items != null && skillCat.items!.isNotEmpty)
                                  .map((skillCat) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  if (skillCat.category != null)
                                    pw.Text(
                                      skillCat.category!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  pw.SizedBox(height: 3),
                                  pw.Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: (skillCat.items ?? [])
                                        .map((skill) => pw.Text(
                                      '• $skill',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                      ),
                                    ))
                                        .toList(),
                                  ),
                                  pw.SizedBox(height: 8),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Right column (50%)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Certifications
                        if (resume.certifications != null && resume.certifications!.isNotEmpty)
                          _buildClassicSection(
                            title: 'CERTIFICATIONS',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.certifications!
                                  .map((cert) => pw.Padding(
                                padding: pw.EdgeInsets.only(bottom: 5),
                                child: pw.Text(
                                  '${cert.name ?? ''}${cert.name != null && cert.year != null ? ' (${cert.year})' : ''}',
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 10,
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),
                          ),

                        // Projects
                        if (resume.projects != null && resume.projects!.isNotEmpty)
                          _buildClassicSection(
                            title: 'PROJECTS',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.projects!
                                  .map((project) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  if (project.name != null)
                                    pw.Text(
                                      project.name!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  if (project.description != null)
                                    pw.Text(
                                      project.description!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        lineSpacing: 1.5,
                                      ),
                                    ),
                                  pw.SizedBox(height: 8),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),

                        // Languages
                        if (resume.languages != null && resume.languages!.isNotEmpty)
                          _buildClassicSection(
                            title: 'LANGUAGES',
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.languages!
                                  .map((lang) => pw.Text(
                                '${lang.name ?? ''}${lang.name != null && lang.proficiency != null ? ' - ' : ''}${lang.proficiency ?? ''}',
                                style: pw.TextStyle(
                                  font: ttfFont,
                                  fontSize: 10,
                                ),
                              ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 13: Creative
  // ====================

  static void _buildTemplate13(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with colored bar
              pw.Container(
                color: PdfColors.blue800,
                padding: pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: pw.Row(
                  children: [
                    if (avatarImage != null)
                      pw.Container(
                        width: 50,
                        height: 50,
                        margin: pw.EdgeInsets.only(right: 15),
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: PdfColors.white,
                          image: pw.DecorationImage(
                            image: avatarImage,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (resume.heading?.name != null)
                            pw.Text(
                              resume.heading!.name!.toUpperCase(),
                              style: pw.TextStyle(
                                font: ttfFont,
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          if (resume.heading?.position != null)
                            pw.Text(
                              resume.heading!.position!,
                              style: pw.TextStyle(
                                font: ttfFont,
                                fontSize: 12,
                                color: PdfColors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 15),

              // Two column layout
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left column (35%)
                  pw.Container(
                    width: context.page.pageFormat.availableWidth * 0.35,
                    padding: pw.EdgeInsets.only(right: 15),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Contact information
                        if (resume.contact != null && resume.contact!.isNotEmpty)
                          _buildCreativeSection02(
                            title: 'CONTACT',
                            accentColor: PdfColors.blue800,
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.contact!
                                  .where((c) => c.value != null && c.value!.isNotEmpty)
                                  .map((c) => pw.Padding(
                                padding: pw.EdgeInsets.only(bottom: 8),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      c.type?.toUpperCase() ?? '',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.grey600,
                                      ),
                                    ),
                                    pw.Text(
                                      c.value!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                                  .toList(),
                            ),
                          ),

                        // Skills
                        if (resume.skills != null && resume.skills!.isNotEmpty)
                          _buildCreativeSection02(
                            title: 'SKILLS',
                            accentColor: PdfColors.blue800,
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.skills!
                                  .where((skillCat) => skillCat.items != null && skillCat.items!.isNotEmpty)
                                  .map((skillCat) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  if (skillCat.category != null)
                                    pw.Text(
                                      skillCat.category!.toUpperCase(),
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.blue800,
                                      ),
                                    ),
                                  pw.SizedBox(height: 5),
                                  pw.Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: (skillCat.items ?? [])
                                        .map((skill) => pw.Container(
                                      padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: pw.BoxDecoration(
                                        color: PdfColors.blue50,
                                        borderRadius: pw.BorderRadius.circular(10),
                                      ),
                                      child: pw.Text(
                                        skill,
                                        style: pw.TextStyle(
                                          font: ttfFont,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ))
                                        .toList(),
                                  ),
                                  pw.SizedBox(height: 10),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),

                        // Languages
                        if (resume.languages != null && resume.languages!.isNotEmpty)
                          _buildCreativeSection02(
                            title: 'LANGUAGES',
                            accentColor: PdfColors.blue800,
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.languages!
                                  .map((lang) => pw.Row(
                                children: [
                                  pw.Container(
                                    width: 8,
                                    height: 8,
                                    margin: pw.EdgeInsets.only(right: 5),
                                    decoration: pw.BoxDecoration(
                                      shape: pw.BoxShape.circle,
                                      color: PdfColors.blue800,
                                    ),
                                  ),
                                  pw.Text(
                                    '${lang.name ?? ''}${lang.name != null && lang.proficiency != null ? ' - ' : ''}${lang.proficiency ?? ''}',
                                    style: pw.TextStyle(
                                      font: ttfFont,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),

                        // Certifications
                        if (resume.certifications != null && resume.certifications!.isNotEmpty)
                          _buildCreativeSection02(
                            title: 'CERTIFICATIONS',
                            accentColor: PdfColors.blue800,
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.certifications!
                                  .map((cert) => pw.Padding(
                                padding: pw.EdgeInsets.only(bottom: 8),
                                child: pw.Text(
                                  '• ${cert.name ?? ''}${cert.name != null && cert.year != null ? ' (${cert.year})' : ''}',
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 10,
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Right column (65%)
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Profile Summary
                        if (resume.summary != null && resume.summary!.isNotEmpty)
                          _buildCreativeSection02(
                            title: 'PROFILE',
                            accentColor: PdfColors.blue800,
                            content: pw.Text(
                              resume.summary!,
                              style: pw.TextStyle(
                                font: ttfFont,
                                fontSize: 11,
                                lineSpacing: 1.5,
                              ),
                            ),
                          ),

                        // Work Experience
                        if (resume.experience != null && resume.experience!.isNotEmpty)
                          _buildCreativeSection02(
                            title: 'EXPERIENCE',
                            accentColor: PdfColors.blue800,
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.experience!
                                  .where((exp) => exp.position != null || exp.company != null)
                                  .map((exp) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Text(
                                          exp.position ?? '',
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (exp.duration != null)
                                        pw.Text(
                                          exp.duration!,
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                            color: PdfColors.grey600,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (exp.company != null)
                                    pw.Text(
                                      exp.company!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 11,
                                        color: PdfColors.blue800,
                                      ),
                                    ),
                                  if (exp.location != null)
                                    pw.Text(
                                      exp.location!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 9,
                                        color: PdfColors.grey600,
                                      ),
                                    ),
                                  if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                    pw.Padding(
                                      padding: pw.EdgeInsets.only(top: 5, left: 10),
                                      child: pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: exp.responsibilities!
                                            .map((resp) => pw.Text(
                                          '• $resp',
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                            lineSpacing: 1.5,
                                          ),
                                        ))
                                            .toList(),
                                      ),
                                    ),
                                  pw.SizedBox(height: 10),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),

                        // Education
                        if (resume.education != null && resume.education!.isNotEmpty)
                          _buildCreativeSection02(
                            title: 'EDUCATION',
                            accentColor: PdfColors.blue800,
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.education!
                                  .where((edu) => edu.institution != null || edu.degree != null)
                                  .map((edu) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  if (edu.degree != null)
                                    pw.Text(
                                      edu.degree!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  if (edu.institution != null)
                                    pw.Text(
                                      edu.institution!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 11,
                                      ),
                                    ),
                                  if (edu.year != null)
                                    pw.Text(
                                      edu.year!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey600,
                                      ),
                                    ),
                                  pw.SizedBox(height: 8),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),

                        // Projects
                        if (resume.projects != null && resume.projects!.isNotEmpty)
                          _buildCreativeSection02(
                            title: 'PROJECTS',
                            accentColor: PdfColors.blue800,
                            content: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: resume.projects!
                                  .map((project) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  if (project.name != null)
                                    pw.Text(
                                      project.name!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  if (project.description != null)
                                    pw.Text(
                                      project.description!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        lineSpacing: 1.5,
                                      ),
                                    ),
                                  if (project.technologies != null && project.technologies!.isNotEmpty)
                                    pw.Wrap(
                                      spacing: 5,
                                      runSpacing: 5,
                                      children: [
                                        pw.Text(
                                          'Tech: ',
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        ...project.technologies!
                                            .map((tech) => pw.Text(
                                          '$tech, ',
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                          ),
                                        ))
                                            .toList(),
                                      ],
                                    ),
                                  pw.SizedBox(height: 8),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 14: Modern
  // ===================

  static void _buildTemplate14(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Row(
            children: [
              // Sidebar (30%)
              pw.Container(
                width: context.page.pageFormat.availableWidth * 0.3,
                color: PdfColors.grey900,
                padding: pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    if (avatarImage != null)
                      pw.Container(
                        width: 100,
                        height: 100,
                        margin: pw.EdgeInsets.only(bottom: 20),
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: PdfColors.white,
                          image: pw.DecorationImage(
                            image: avatarImage,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      ),

                    // Name
                    if (resume.heading?.name != null)
                      pw.Text(
                        resume.heading!.name!,
                        style: pw.TextStyle(
                          font: ttfFont,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),

                    // Position
                    if (resume.heading?.position != null)
                      pw.Text(
                        resume.heading!.position!,
                        style: pw.TextStyle(
                          font: ttfFont,
                          fontSize: 12,
                          color: PdfColors.grey300,
                        ),
                      ),

                    pw.SizedBox(height: 30),

                    // Contact
                    if (resume.contact != null && resume.contact!.isNotEmpty)
                      _buildElegantSidebarSection(
                        title: 'CONTACT',
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.contact!
                              .where((c) => c.value != null && c.value!.isNotEmpty)
                              .map((c) => pw.Padding(
                            padding: pw.EdgeInsets.only(bottom: 4),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  c.type?.toUpperCase() ?? '',
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 8,
                                    color: PdfColors.grey400,
                                  ),
                                ),
                                pw.Text(
                                  c.value!,
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 10,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ))
                              .toList(),
                        ),
                      ),

                    // Skills
                    if (resume.skills != null && resume.skills!.isNotEmpty)
                      _buildElegantSidebarSection(
                        title: 'SKILLS',
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.skills!
                              .where((skillCat) => skillCat.items != null && skillCat.items!.isNotEmpty)
                              .map((skillCat) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (skillCat.category != null)
                                pw.Text(
                                  skillCat.category!.toUpperCase(),
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 10,
                                    color: PdfColors.grey400,
                                  ),
                                ),
                              pw.SizedBox(height: 5),
                              pw.Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: (skillCat.items ?? [])
                                    .map((skill) => pw.Text(
                                  '• $skill',
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 10,
                                    color: PdfColors.white,
                                  ),
                                ))
                                    .toList(),
                              ),
                              pw.SizedBox(height: 5),
                            ],
                          ))
                              .toList(),
                        ),
                      ),

                    // Languages
                    if (resume.languages != null && resume.languages!.isNotEmpty)
                      _buildElegantSidebarSection(
                        title: 'LANGUAGES',
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.languages!
                              .map((lang) => pw.Text(
                            '${lang.name ?? ''}${lang.name != null && lang.proficiency != null ? ' - ' : ''}${lang.proficiency ?? ''}',
                            style: pw.TextStyle(
                              font: ttfFont,
                              fontSize: 10,
                              color: PdfColors.white,
                            ),
                          ))
                              .toList(),
                        ),
                      ),

                    // Certifications
                    if (resume.certifications != null && resume.certifications!.isNotEmpty)
                      _buildElegantSidebarSection(
                        title: 'CERTIFICATIONS',
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.certifications!
                              .map((cert) => pw.Padding(
                            padding: pw.EdgeInsets.only(bottom: 5),
                            child: pw.Text(
                              '• ${cert.name ?? ''}${cert.name != null && cert.year != null ? ' (${cert.year})' : ''}',
                              style: pw.TextStyle(
                                font: ttfFont,
                                fontSize: 10,
                                color: PdfColors.white,
                              ),
                            ),
                          ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),

              // Main content (70%)
              pw.Container(
                width: context.page.pageFormat.availableWidth * 0.7,
                padding: pw.EdgeInsets.all(25),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Profile Summary
                    if (resume.summary != null && resume.summary!.isNotEmpty)
                      _buildElegantMainSection(
                        title: 'PROFILE',
                        content: pw.Text(
                          resume.summary!,
                          style: pw.TextStyle(
                            font: ttfFont,
                            fontSize: 11,
                            lineSpacing: 1.5,
                          ),
                        ),
                      ),

                    // Work Experience
                    if (resume.experience != null && resume.experience!.isNotEmpty)
                      _buildElegantMainSection(
                        title: 'EXPERIENCE',
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.experience!
                              .where((exp) => exp.position != null || exp.company != null)
                              .map((exp) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(
                                    child: pw.Text(
                                      exp.position ?? '',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (exp.duration != null)
                                    pw.Text(
                                      exp.duration!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey600,
                                      ),
                                    ),
                                ],
                              ),
                              if (exp.company != null)
                                pw.Text(
                                  exp.company!,
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 12,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              if (exp.location != null)
                                pw.Text(
                                  exp.location!,
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 10,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(top: 5, left: 10),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: exp.responsibilities!
                                        .map((resp) => pw.Text(
                                      '• $resp',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        lineSpacing: 1.5,
                                      ),
                                    ))
                                        .toList(),
                                  ),
                                ),
                              pw.SizedBox(height: 6),
                            ],
                          ))
                              .toList(),
                        ),
                      ),

                    // Education
                    if (resume.education != null && resume.education!.isNotEmpty)
                      _buildElegantMainSection(
                        title: 'EDUCATION',
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.education!
                              .where((edu) => edu.institution != null || edu.degree != null)
                              .map((edu) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(
                                    child: pw.Text(
                                      edu.degree ?? '',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (edu.year != null)
                                    pw.Text(
                                      edu.year!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        color: PdfColors.grey600,
                                      ),
                                    ),
                                ],
                              ),
                              if (edu.institution != null)
                                pw.Text(
                                  edu.institution!,
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 12,
                                  ),
                                ),
                              pw.SizedBox(height: 6),
                            ],
                          ))
                              .toList(),
                        ),
                      ),

                    // Projects
                    if (resume.projects != null && resume.projects!.isNotEmpty)
                      _buildElegantMainSection(
                        title: 'PROJECTS',
                        content: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: resume.projects!
                              .map((project) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (project.name != null)
                                pw.Text(
                                  project.name!,
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              if (project.description != null)
                                pw.Text(
                                  project.description!,
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 10,
                                    lineSpacing: 1.5,
                                  ),
                                ),
                              if (project.technologies != null && project.technologies!.isNotEmpty)
                                pw.Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: [
                                    pw.Text(
                                      'Technologies: ',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    ...project.technologies!
                                        .map((tech) => pw.Text(
                                      '$tech, ',
                                      style: pw.TextStyle(
                                        font: ttfFont,
                                        fontSize: 10,
                                      ),
                                    ))
                                        .toList(),
                                  ],
                                ),
                              pw.SizedBox(height: 6),
                            ],
                          ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 15: Modern
  // ===================


  static void _buildTemplate15(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    // ===== DESIGN VARIABLES =====
    final primaryColor = PdfColors.indigo800;  // Deep Indigo (Professional & Trustworthy)
    final secondaryColor = PdfColors.teal600;  // Teal (Modern & Fresh)
    final lightAccent = PdfColors.indigo50;    // Soft Indigo (Backgrounds)
    final textDark = PdfColors.grey900;       // Primary Text (Almost Black)
    final textLight = PdfColors.grey600;      // Secondary Text (Soft Grey)

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ===== HEADER (Name, Position, Contact) =====
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Avatar (Circular with Border)
                  if (avatarImage != null)
                    pw.Container(
                      width: 75,
                      height: 75,
                      margin: pw.EdgeInsets.only(right: 20),
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(width: 2.5, color: primaryColor),
                        image: pw.DecorationImage(
                          image: avatarImage,
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                  // Name & Position
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (resume.heading?.name != null)
                          pw.Text(
                            resume.heading!.name!.toUpperCase(),
                            style: pw.TextStyle(
                              font: ttfFont,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 26,
                              color: textDark,
                              letterSpacing: 1.5,
                            ),
                          ),
                        if (resume.heading?.position != null)
                          pw.Text(
                            resume.heading!.position!,
                            style: pw.TextStyle(
                              font: ttfFont,
                              fontSize: 15,
                              color: secondaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Contact (Right-Aligned, Minimalist)
                  if (resume.contact != null && resume.contact!.isNotEmpty)
                    pw.Container(
                      alignment: pw.Alignment.topRight,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: resume.contact!
                            .where((c) => c.value != null && c.value!.isNotEmpty)
                            .map((c) => pw.Text(
                          c.value!,
                          style: pw.TextStyle(
                            font: ttfFont,
                            fontSize: 10,
                            color: textLight,
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                ],
              ),

              pw.SizedBox(height: 25),

              // ===== PROFILE SUMMARY (Highlighted Background) =====
              if (resume.summary != null && resume.summary!.isNotEmpty)
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: lightAccent,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(width: 0.5, color: PdfColors.grey300),
                  ),
                  child: pw.Text(
                    resume.summary!,
                    style: pw.TextStyle(
                      font: ttfFont,
                      fontSize: 11,
                      lineSpacing: 1.8,
                      color: textDark,
                    ),
                  ),
                ),

              pw.SizedBox(height: 25),

              // ===== MAIN CONTENT (Two Columns) =====
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // ===== LEFT COLUMN (Experience & Education) =====
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // === WORK EXPERIENCE (Timeline Style) ===
                        if (resume.experience != null && resume.experience!.isNotEmpty)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('EXPERIENCE', primaryColor),
                              pw.SizedBox(height: 12),
                              ...resume.experience!
                                  .where((exp) => exp.position != null || exp.company != null)
                                  .map((exp) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  // Position, Company & Duration
                                  pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      // Timeline Bullet (Elegant Dot)
                                      pw.Container(
                                        width: 14,
                                        height: 14,
                                        margin: pw.EdgeInsets.only(right: 12, top: 3),
                                        decoration: pw.BoxDecoration(
                                          shape: pw.BoxShape.circle,
                                          color: primaryColor,
                                        ),
                                      ),
                                      // Job Details
                                      pw.Expanded(
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            // Position (Bold & Prominent)
                                            pw.Text(
                                              exp.position ?? '',
                                              style: pw.TextStyle(
                                                font: ttfFont,
                              fontWeight: pw.FontWeight.bold,
                                                fontSize: 14,
                                                color: textDark,
                                              ),
                                            ),
                                            // Company (Secondary Text)
                                            if (exp.company != null)
                                              pw.Text(
                                                exp.company!,
                                                style: pw.TextStyle(
                                                  font: ttfFont,
                                                  fontSize: 12,
                                                  color: secondaryColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Duration (Right-Aligned)
                                      if (exp.duration != null)
                                        pw.Text(
                                          exp.duration!,
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                            color: textLight,
                                          ),
                                        ),
                                    ],
                                  ),
                                  // Location (Small & Italic)
                                  if (exp.location != null)
                                    pw.Padding(
                                      padding: pw.EdgeInsets.only(left: 26, top: 2),
                                      child: pw.Text(
                                        exp.location!,
                                        style: pw.TextStyle(
                                          font: ttfFont,
                                          fontSize: 10,
                                          color: textLight,
                                          fontStyle: pw.FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  // Responsibilities (Bullet Points)
                                  if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                    pw.Padding(
                                      padding: pw.EdgeInsets.only(left: 26, top: 6),
                                      child: pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: exp.responsibilities!
                                            .map((resp) => pw.Text(
                                          '• $resp',
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                            lineSpacing: 1.8,
                                            color: textDark,
                                          ),
                                        ))
                                            .toList(),
                                      ),
                                    ),
                                  pw.SizedBox(height: 16),
                                ],
                              ))
                                  .toList(),
                            ],
                          ),

                        // === EDUCATION (Timeline Style) ===
                        if (resume.education != null && resume.education!.isNotEmpty)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('EDUCATION', primaryColor),
                              pw.SizedBox(height: 12),
                              ...resume.education!
                                  .where((edu) => edu.institution != null || edu.degree != null)
                                  .map((edu) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  // Degree & Institution
                                  pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      // Timeline Bullet (Teal for Education)
                                      pw.Container(
                                        width: 14,
                                        height: 14,
                                        margin: pw.EdgeInsets.only(right: 12, top: 3),
                                        decoration: pw.BoxDecoration(
                                          shape: pw.BoxShape.circle,
                                          color: secondaryColor,
                                        ),
                                      ),
                                      // Education Details
                                      pw.Expanded(
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            // Degree (Bold)
                                            pw.Text(
                                              edu.degree ?? '',
                                              style: pw.TextStyle(
                                                font: ttfFont,
                              fontWeight: pw.FontWeight.bold,
                                                fontSize: 14,
                                                color: textDark,
                                              ),
                                            ),
                                            // Institution (Secondary)
                                            if (edu.institution != null)
                                              pw.Text(
                                                edu.institution!,
                                                style: pw.TextStyle(
                                                  font: ttfFont,
                                                  fontSize: 12,
                                                  color: secondaryColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Year (Right-Aligned)
                                      if (edu.year != null)
                                        pw.Text(
                                          edu.year!,
                                          style: pw.TextStyle(
                                            font: ttfFont,
                                            fontSize: 10,
                                            color: textLight,
                                          ),
                                        ),
                                    ],
                                  ),
                                  pw.SizedBox(height: 16),
                                ],
                              ))
                                  .toList(),
                            ],
                          ),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 20), // Spacer between columns

                  // ===== RIGHT COLUMN (Skills, Projects, Certifications, Languages) =====
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // === SKILLS (Categorized & Tagged) ===
                        if (resume.skills != null && resume.skills!.isNotEmpty)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('SKILLS', primaryColor),
                              pw.SizedBox(height: 10),
                              ...resume.skills!
                                  .where((skillCat) => skillCat.items != null && skillCat.items!.isNotEmpty)
                                  .map((skillCat) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  // Skill Category (Bold)
                                  if (skillCat.category != null)
                                    pw.Text(
                                      skillCat.category!.toUpperCase(),
                                      style: pw.TextStyle(
                                        font: ttfFont,
                              fontWeight: pw.FontWeight.bold,
                                        fontSize: 11,
                                        color: primaryColor,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  pw.SizedBox(height: 6),
                                  // Skill Tags (Pill-Shaped)
                                  pw.Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: (skillCat.items ?? [])
                                        .map((skill) => pw.Container(
                                      padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: pw.BoxDecoration(
                                        color: lightAccent,
                                        borderRadius: pw.BorderRadius.circular(12),
                                        border: pw.Border.all(width: 0.5, color: PdfColors.grey300),
                                      ),
                                      child: pw.Text(
                                        skill,
                                        style: pw.TextStyle(
                                          font: ttfFont,
                                          fontSize: 9,
                                          color: textDark,
                                        ),
                                      ),
                                    ))
                                        .toList(),
                                  ),
                                  pw.SizedBox(height: 12),
                                ],
                              ))
                                  .toList(),
                            ],
                          ),

                        // === PROJECTS (Compact & Readable) ===
                        if (resume.projects != null && resume.projects!.isNotEmpty)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('PROJECTS', primaryColor),
                              pw.SizedBox(height: 10),
                              ...resume.projects!
                                  .map((project) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  // Project Name (Bold)
                                  if (project.name != null)
                                    pw.Text(
                                      project.name!,
                                      style: pw.TextStyle(
                                        font: ttfFont,
                              fontWeight: pw.FontWeight.bold,
                                        fontSize: 12,
                                        color: textDark,
                                      ),
                                    ),
                                  // Description (Compact)
                                  if (project.description != null)
                                    pw.Padding(
                                      padding: pw.EdgeInsets.only(top: 4),
                                      child: pw.Text(
                                        project.description!,
                                        style: pw.TextStyle(
                                          font: ttfFont,
                                          fontSize: 10,
                                          lineSpacing: 1.5,
                                          color: textLight,
                                        ),
                                      ),
                                    ),
                                  // Technologies (Tagged)
                                  if (project.technologies != null && project.technologies!.isNotEmpty)
                                    pw.Padding(
                                      padding: pw.EdgeInsets.only(top: 6),
                                      child: pw.Wrap(
                                        spacing: 5,
                                        runSpacing: 5,
                                        children: [
                                          pw.Text(
                                            'Tech: ',
                                            style: pw.TextStyle(
                                              font: ttfFont,
                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 9,
                                              color: textLight,
                                            ),
                                          ),
                                          ...project.technologies!
                                              .map((tech) => pw.Text(
                                            '$tech, ',
                                            style: pw.TextStyle(
                                              font: ttfFont,
                                              fontSize: 9,
                                              color: textLight,
                                            ),
                                          ))
                                              .toList(),
                                        ],
                                      ),
                                    ),
                                  pw.SizedBox(height: 12),
                                ],
                              ))
                                  .toList(),
                            ],
                          ),

                        // === CERTIFICATIONS (Clean List) ===
                        if (resume.certifications != null && resume.certifications!.isNotEmpty)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('CERTIFICATIONS', primaryColor),
                              pw.SizedBox(height: 10),
                              ...resume.certifications!
                                  .map((cert) => pw.Padding(
                                padding: pw.EdgeInsets.only(bottom: 8),
                                child: pw.Text(
                                  '• ${cert.name ?? ''}${cert.name != null && cert.year != null ? ' (${cert.year})' : ''}',
                                  style: pw.TextStyle(
                                    font: ttfFont,
                                    fontSize: 10,
                                    color: textDark,
                                  ),
                                ),
                              ))
                                  .toList(),
                            ],
                          ),

                        // === LANGUAGES (Simple & Elegant) ===
                        if (resume.languages != null && resume.languages!.isNotEmpty)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('LANGUAGES', primaryColor),
                              pw.SizedBox(height: 10),
                              ...resume.languages!
                                  .map((lang) => pw.Text(
                                '• ${lang.name ?? ''}${lang.name != null && lang.proficiency != null ? ' - ${lang.proficiency}' : ''}',
                                style: pw.TextStyle(
                                  font: ttfFont,
                                  fontSize: 10,
                                  color: textDark,
                                ),
                              ))
                                  .toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }



  // ====================
  // HELPER METHODS
  // ====================

  static pw.Widget _buildSectionHeader(String title, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: ttfFont,
            fontWeight: pw.FontWeight.bold,
            fontSize: 16,
            color: color,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: 40,
          height: 2,
          color: color,
        ),
      ],
    );
  }


  static pw.Widget _buildElegantSidebarSection({
    required String title,
    required pw.Widget content,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: ttfFont,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey400,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Divider(
          height: 1,
          thickness: 1,
          color: PdfColors.grey700,
        ),
        pw.SizedBox(height: 5),
        content,
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildElegantMainSection({
    required String title,
    required pw.Widget content,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: ttfFont,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Divider(
          height: 1,
          thickness: 1,
          color: PdfColors.grey300,
        ),
        pw.SizedBox(height: 5),
        content,
      ],
    );
  }


  static pw.Widget _buildCreativeSection02({
    required String title,
    required PdfColor accentColor,
    required pw.Widget content,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 15,
              height: 2,
              margin: pw.EdgeInsets.only(right: 5),
              color: accentColor,
            ),
            pw.Text(
              title,
              style: pw.TextStyle(
                font: ttfFont,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: accentColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        content,
        pw.SizedBox(height: 15),
      ],
    );
  }


  static pw.Widget _buildClassicSection({
    required String title,
    required pw.Widget content,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: ttfFont,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
            decoration: pw.TextDecoration.underline,
          ),
        ),
        pw.SizedBox(height: 5),
        content,
        pw.SizedBox(height: 12),
      ],
    );
  }


  static pw.Widget _buildModernSection02({
    required String title,
    required pw.Widget content,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: ttfFont,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 5),
        content,
        pw.SizedBox(height: 12),
      ],
    );
  }



  static pw.Widget _buildSidebarSection({
    required String title,
    List<pw.Widget>? items,
    required PdfColor titleColor,
  }) {
    if (items == null || items.isEmpty) return pw.SizedBox.shrink();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle( font: ttfFont,
            color: titleColor,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        // divider
        pw.Divider(
          color: PdfColors.white,
          thickness: 1,
          height: 4,
        ),
        pw.SizedBox(height: 6),
        ...items,
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildMainSection({
    required String title,
    required pw.Widget content,
    required PdfColor titleColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle( font: ttfFont,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: titleColor,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(
          width: 50,
          height: 2,
          color: titleColor,
          margin:  pw.EdgeInsets.only(bottom: 7),
        ),
        content,
        pw.SizedBox(height: 6),
      ],
    );
  }

  static pw.Widget _buildModernSection({
    required String title,
    required pw.Widget content,
    required PdfColor accentColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle( font: ttfFont,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: 50,
          height: 2,
          color: accentColor,
          margin:  pw.EdgeInsets.only(bottom: 15),
        ),
        content,
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildElegantSection({
    required String title,
    required pw.Widget content,
    required PdfColor accentColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle( font: ttfFont,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: 50,
          height: 2,
          color: accentColor,
          margin:  pw.EdgeInsets.only(bottom: 15),
        ),
        content,
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildCreativeSection({
    required String title,
    required pw.Widget content,
    required PdfColor accentColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 15,
              height: 15,
              margin:  pw.EdgeInsets.only(right: 10),
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: accentColor,
              ),
            ),
            pw.Text(
              title,
              style: pw.TextStyle( font: ttfFont,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 7),
        content,
        pw.SizedBox(height: 15),
      ],
    );
  }

  static pw.Widget _buildMinimalistSection({
    required String title,
    required pw.Widget content,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle( font: ttfFont,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Divider(
          height: 2,
          thickness: 1,
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 4),
        content,
        pw.SizedBox(height: 10),
      ],
    );
  }

  static int _getContactIconCode(String? type) {
    switch (type?.toLowerCase()) {
      case 'email':
        return 0xe0be;
      case 'phone':
        return 0xe0cd;
      case 'linkedin':
        return 0xe252;
      case 'github':
        return 0xe30a;
      case 'website':
        return 0xe157;
      default:
        return 0xe0c8; // info icon
    }
  }

  static Future<void> openFile(File file) async {
    if (await file.exists()) {
      await OpenFile.open(file.path);
    } else {
      print('File does not exist');
    }
  }
}