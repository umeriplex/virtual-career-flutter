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
        _buildTemplate01(pdf, resume, avatarImage);
        break;
      case 2:
        _buildTemplate02(pdf, resume, avatarImage);
        break;
      case 3:
        _buildTemplate03(pdf, resume, avatarImage);
        break;
      case 4:
        _buildTemplate04(pdf, resume, avatarImage);
        break;
      case 5:
        _buildTemplate05(pdf, resume, avatarImage);
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
        _buildTemplate01(pdf, resume, avatarImage);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ====================
  // TEMPLATE 1: Corporate Blue
  // ====================
  static void _buildTemplate01Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Row(
            children: [
              // Left sidebar - 30% width
              pw.Container(
                width: context.page.pageFormat.availableWidth * 0.4,
                color: PdfColors.blue.shade(900),
                padding:  pw.EdgeInsets.all(25),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 20),
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

                    pw.SizedBox(height: 5),

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


  // Done!
  static void _buildTemplate01(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final textStyle = pw.TextStyle(fontSize: 10, font: ttfFont);
    final headingStyle = pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: ttfFont);
    final sectionTitleStyle = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: ttfFont);
    final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont);

    pw.Widget sectionDivider() => pw.Divider(thickness: 0.5, color: PdfColors.grey);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        build: (context) => [

          // Header
          if (resume.heading != null) ...[
            pw.Text(resume.heading!.name ?? '', style: headingStyle),
            if (resume.heading!.position != null)
              pw.Text(resume.heading!.position!, style: textStyle),
            pw.SizedBox(height: 10),
          ],

          // Summary
          if (resume.summary != null) ...[
            pw.Text(resume.summary!, style: textStyle),
            pw.SizedBox(height: 10),
          ],
          sectionDivider(),

          // Contact
          if (resume.contact != null && resume.contact!.isNotEmpty) ...[
            pw.Text('Contact', style: sectionTitleStyle),
            pw.SizedBox(height: 5),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: resume.contact!
              .where((c) => c.type != null && c.value != null)
              .map((c) => pw.Text('${c.type}: ${c.value}', style: textStyle))
              .toList(),
            ),
            pw.SizedBox(height: 10),
            sectionDivider(),
          ],

          // Experience
          if (resume.experience != null && resume.experience!.isNotEmpty) ...[
            pw.Text('Experience', style: sectionTitleStyle),
            pw.SizedBox(height: 5),
            pw.ListView.builder(
              itemCount: resume.experience!.length,
              itemBuilder: (context, index) {
                final exp = resume.experience![index];
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(exp.position ?? '', style: boldStyle),
                          pw.Text(exp.duration ?? '', style: textStyle),
                        ],
                      ),
                      if (exp.company != null)
                        pw.Text(exp.company!, style: textStyle),
                      if (exp.location != null)
                        pw.Text(exp.location!, style: textStyle),
                      if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: exp.responsibilities!
                              .map((r) => pw.Bullet(text: r, style: textStyle))
                              .toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
            pw.SizedBox(height: 10),
            sectionDivider(),
          ],

          // Education
          if (resume.education != null && resume.education!.isNotEmpty) ...[
            pw.Text('Education', style: sectionTitleStyle),
            pw.SizedBox(height: 5),
            pw.ListView.builder(
              itemCount: resume.education!.length,
              itemBuilder: (context, index) {
                final edu = resume.education![index];
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(edu.degree ?? '', style: boldStyle),
                          if (edu.institution != null)
                            pw.Text(edu.institution!, style: textStyle),
                        ],
                      ),
                      if (edu.year != null)
                        pw.Text(edu.year!, style: textStyle),
                    ],
                  ),
                );
              },
            ),
            pw.SizedBox(height: 10),
            sectionDivider(),
          ],

          // Skills
          if (resume.skills != null && resume.skills!.isNotEmpty) ...[
            pw.Text('Skills', style: sectionTitleStyle),
            pw.SizedBox(height: 5),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: resume.skills!
                  .map((s) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (s.category != null)
                      pw.Text(s.category!, style: boldStyle),
                    if (s.items != null)
                      pw.Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: s.items!
                            .map((item) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(item, style: textStyle),
                        ))
                            .toList(),
                      ),
                  ],
                ),
              ))
                  .toList(),
            ),
            pw.SizedBox(height: 10),
            sectionDivider(),
          ],

          // Projects
          if (resume.projects != null && resume.projects!.isNotEmpty) ...[
            pw.Text('Projects', style: sectionTitleStyle),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: resume.projects!.map((project) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (project.name != null)
                        pw.Text(
                          project.name!,
                          style: boldStyle.copyWith(fontSize: 12),
                        ),
                      if (project.description != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 4),
                          child: pw.Text(
                            project.description!,
                            style: textStyle.copyWith(fontSize: 10),
                          ),
                        ),
                      if (project.technologies != null && project.technologies!.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 6),
                          child: pw.Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: project.technologies!.map((tech) {
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey200,
                                  borderRadius: pw.BorderRadius.circular(4),
                                ),
                                child: pw.Text(
                                  tech,
                                  style: textStyle.copyWith(fontSize: 9),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
            pw.SizedBox(height: 12),
            sectionDivider(),
          ],

          // Certifications
          if (resume.certifications != null && resume.certifications!.isNotEmpty) ...[
            pw.Text('Certifications', style: sectionTitleStyle),
            pw.SizedBox(height: 5),
            pw.ListView.builder(
              itemCount: resume.certifications!.length,
              itemBuilder: (context, index) {
                final cert = resume.certifications![index];
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(cert.name ?? '', style: textStyle),
                      pw.Text(cert.year ?? '', style: textStyle),
                    ],
                  ),
                );
              },
            ),
            pw.SizedBox(height: 10),
            sectionDivider(),
          ],

          // Languages
          if (resume.languages != null && resume.languages!.isNotEmpty) ...[
            pw.Text('Languages', style: sectionTitleStyle),
            pw.SizedBox(height: 5),
            pw.Wrap(
              spacing: 10,
              runSpacing: 5,
              children: resume.languages!
                  .map((lang) => pw.Text(
                '${lang.name ?? ''}${lang.proficiency != null ? ' (${lang.proficiency})' : ''}',
                style: textStyle,
              ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }


  // ====================
  // TEMPLATE 2: Modern Green
  // ====================

  // Done!
  static pw.Document _buildTemplate02(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {

    // Define styles
    final headerStyle = pw.TextStyle(
      font: ttfFont,
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue800,
    );

    final sectionHeaderStyle = pw.TextStyle(
      font: ttfFont,
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue700,
    );

    final bodyStyle = pw.TextStyle(
      font: ttfFont,
      fontSize: 10,
      color: PdfColors.black,
    );

    final smallBodyStyle = pw.TextStyle(
      font: ttfFont,
      fontSize: 9,
      color: PdfColors.grey800,
    );

    // Helper function to build section with title
    pw.Widget _buildSection(String title, List<pw.Widget> children) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: sectionHeaderStyle),
          pw.SizedBox(height: 4),
          pw.Divider(thickness: 1, color: PdfColors.blue200),
          pw.SizedBox(height: 6),
          ...children,
          pw.SizedBox(height: 12),
        ],
      );
    }

    // Helper function to build item with title and subtitle
    pw.Widget _buildItem(String title, String? subtitle, {String? duration, String? location}) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if (duration != null)
                pw.Text(duration, style: smallBodyStyle),
            ],
          ),
          if (subtitle != null) pw.Text(subtitle, style: smallBodyStyle),
          if (location != null) pw.Text(location, style: smallBodyStyle),
          pw.SizedBox(height: 4),
        ],
      );
    }

    // Build resume content
    final content = [
      // Header section
      if (resume.heading != null)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (resume.heading?.name != null)
              pw.Text(resume.heading!.name!, style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              )),
            if (resume.heading?.position != null)
              pw.Text(resume.heading!.position!, style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.grey600,
              )),
            pw.SizedBox(height: 8),
          ],
        ),

      // Contact information
      if (resume.contact != null && resume.contact!.isNotEmpty)
        pw.Wrap(
          spacing: 12,
          runSpacing: 4,
          children: resume.contact!
              .where((contact) => contact.value != null && contact.value!.isNotEmpty)
              .map((contact) => pw.Text('${contact.type}: ${contact.value}', style: smallBodyStyle))
              .toList(),
        ),

      pw.SizedBox(height: 16),

      // Summary
      if (resume.summary != null && resume.summary!.isNotEmpty)
        _buildSection(
          'SUMMARY',
          [
            pw.Text(resume.summary!, style: bodyStyle, textAlign: pw.TextAlign.justify),
          ],
        ),

      // Experience
      if (resume.experience != null && resume.experience!.isNotEmpty)
        _buildSection(
          'EXPERIENCE',
          resume.experience!
              .where((exp) => exp.company != null || exp.position != null)
              .map((exp) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildItem(
                exp.company ?? '',
                exp.position,
                duration: exp.duration,
                location: exp.location,
              ),
              if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: exp.responsibilities!
                      .map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                    child: pw.Text('• $item', style: bodyStyle),
                  ))
                      .toList(),
                ),
              pw.SizedBox(height: 8),
            ],
          ))
              .toList(),
        ),

      // Education
      if (resume.education != null && resume.education!.isNotEmpty)
        _buildSection(
          'EDUCATION',
          resume.education!
              .where((edu) => edu.institution != null || edu.degree != null)
              .map((edu) => _buildItem(
            edu.institution ?? '',
            edu.degree,
            duration: edu.year,
          ))
              .toList(),
        ),

      // Skills
      if (resume.skills != null && resume.skills!.isNotEmpty)
        _buildSection(
          'SKILLS',
          [
            pw.Wrap(
              spacing: 8,
              runSpacing: 4,
              children: resume.skills!
                  .where((skill) => skill.category != null && skill.items != null && skill.items!.isNotEmpty)
                  .expand((skill) => [
                pw.Text('${skill.category}:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ...skill.items!.map((item) => pw.Text(item, style: bodyStyle)),
              ])
                  .toList(),
            ),
          ],
        ),

      // Projects
      if (resume.projects != null && resume.projects!.isNotEmpty)
        _buildSection(
          'PROJECTS',
          resume.projects!
              .where((project) => project.name != null || project.description != null)
              .map((project) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (project.name != null)
                pw.Text(project.name!, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont,)),
              if (project.description != null)
                pw.Text(project.description!, style: bodyStyle),
              if (project.technologies != null && project.technologies!.isNotEmpty)
                pw.Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    pw.Text('Technologies:', style: smallBodyStyle),
                    ...project.technologies!
                        .map((tech) => pw.Text(tech, style: smallBodyStyle))
                        .toList(),
                  ],
                ),
              pw.SizedBox(height: 8),
            ],
          ))
              .toList(),
        ),

      // Certifications
      if (resume.certifications != null && resume.certifications!.isNotEmpty)
        _buildSection(
          'CERTIFICATIONS',
          resume.certifications!
              .where((cert) => cert.name != null)
              .map((cert) => _buildItem(
            cert.name ?? '',
            cert.year,
          ))
              .toList(),
        ),

      // Languages
      if (resume.languages != null && resume.languages!.isNotEmpty)
        _buildSection(
          'LANGUAGES',
          [
            pw.Wrap(
              spacing: 12,
              runSpacing: 4,
              children: resume.languages!
                  .where((lang) => lang.name != null)
                  .map((lang) => pw.Text(
                '${lang.name}${lang.proficiency != null ? ' (${lang.proficiency})' : ''}',
                style: bodyStyle,
              ))
                  .toList(),
            ),
          ],
        ),
    ];

    // Build pages
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          // Split content into pages as needed
          return content;
        },
      ),
    );

    return pdf;
  }


  static void _buildTemplate02Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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


  static pw.Document _buildTemplate03a(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {

    // Define styles
    final headerStyle = pw.TextStyle(
      font: ttfFont,
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    final sectionHeaderStyle = pw.TextStyle(
      font: ttfFont,
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.teal800,
    );

    final bodyStyle = pw.TextStyle(
      font: ttfFont,
      fontSize: 10,
      color: PdfColors.grey800,
    );

    final smallBodyStyle = pw.TextStyle(
      font: ttfFont,
      fontSize: 9,
      color: PdfColors.grey600,
    );

    final accentColor = PdfColors.teal800;
    final headerBgColor = PdfColors.teal700;

    // Helper function to build section with title
    pw.Widget _buildSection(String title, List<pw.Widget> children) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
            child: pw.Text(title, style: sectionHeaderStyle),
          ),
          pw.SizedBox(height: 8),
          ...children,
          pw.SizedBox(height: 12),
        ],
      );
    }

    // Helper function to build item with title and subtitle
    pw.Widget _buildItem(String title, String? subtitle, {String? duration, String? location}) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(title, style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: accentColor,
                    )),
                    if (subtitle != null) pw.Text(subtitle, style: smallBodyStyle),
                  ],
                ),
              ),
              if (duration != null)
                pw.Text(duration, style: smallBodyStyle.copyWith(
                  fontStyle: pw.FontStyle.italic,
                )),
            ],
          ),
          if (location != null) pw.Text(location, style: smallBodyStyle),
          pw.SizedBox(height: 4),
        ],
      );
    }

    // Build resume content
    final content = [
    // Header section with colored background
    pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: headerBgColor,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (resume.heading?.name != null)
                pw.Text(resume.heading!.name!, style: headerStyle),
              if (resume.heading?.position != null)
                pw.Text(resume.heading!.position!, style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.white,
                )),
              pw.SizedBox(height: 8),
              if (resume.contact != null && resume.contact!.isNotEmpty)
                pw.Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: resume.contact!
                      .where((contact) => contact.value != null && contact.value!.isNotEmpty)
                      .map((contact) => pw.Text('${contact.type}: ${contact.value}',
                      style: smallBodyStyle.copyWith(color: PdfColors.white)))
                      .toList(),
                ),
            ],
          ),
        ),

        pw.SizedBox(height: 16),

        // Two column layout for the rest
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
          // Left column (60%)
          pw.Expanded(
          flex: 6,
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
          // Summary
          if (resume.summary != null && resume.summary!.isNotEmpty)
          _buildSection(
          'PROFILE',
          [
            pw.Text(resume.summary!, style: bodyStyle, textAlign: pw.TextAlign.justify),
          ],
        ),

        // Experience
        if (resume.experience != null && resume.experience!.isNotEmpty)
    _buildSection(
      'EXPERIENCE',
      resume.experience!
          .where((exp) => exp.company != null || exp.position != null)
          .map((exp) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildItem(
            exp.company ?? '',
            exp.position,
            duration: exp.duration,
            location: exp.location,
          ),
          if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: exp.responsibilities!
                  .map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                child: pw.Text('• $item', style: bodyStyle),
              ))
                  .toList(),
            ),
          pw.SizedBox(height: 8),
        ],
      ))
          .toList(),
    ),

    // Projects
    if (resume.projects != null && resume.projects!.isNotEmpty)
    _buildSection(
    'PROJECTS',
    resume.projects!
        .where((project) => project.name != null || project.description != null)
        .map((project) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    pw.Text(project.name ?? '', style: pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    color: accentColor,
    )),
    if (project.description != null)
    pw.Text(project.description!, style: bodyStyle),
    if (project.technologies != null && project.technologies!.isNotEmpty)
    pw.Wrap(
    spacing: 4,
    runSpacing: 2,
    children: [
    pw.Text('Technologies:', style: smallBodyStyle),
    ...project.technologies!
        .map((tech) => pw.Container(
    margin: const pw.EdgeInsets.only(left: 4),
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    decoration: pw.BoxDecoration(
    color: PdfColors.teal50,
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
    ),
    child: pw.Text(tech, style: smallBodyStyle),
    ))
        .toList(),
    ],
    ),
    pw.SizedBox(height: 8),
    ],
    ))
        .toList(),
    ),
    ],
    ),
    ),

    // Right column (40%)
    pw.Expanded(
    flex: 4,
    child: pw.Padding(
    padding: const pw.EdgeInsets.only(left: 16),
    child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    // Education
    if (resume.education != null && resume.education!.isNotEmpty)
    _buildSection(
    'EDUCATION',
    resume.education!
        .where((edu) => edu.institution != null || edu.degree != null)
        .map((edu) => _buildItem(
    edu.institution ?? '',
    edu.degree,
    duration: edu.year,
    ))
        .toList(),
    ),

    // Skills
    if (resume.skills != null && resume.skills!.isNotEmpty)
    _buildSection(
    'SKILLS',
    resume.skills!
        .where((skill) => skill.category != null && skill.items != null && skill.items!.isNotEmpty)
        .map((skill) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    pw.Text(skill.category!, style: pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    color: accentColor,
    )),
    pw.Wrap(
    spacing: 4,
    runSpacing: 2,
    children: skill.items!
        .map((item) => pw.Container(
    margin: const pw.EdgeInsets.only(right: 4, bottom: 4),
    child: pw.Text(item, style: bodyStyle),
    ))
        .toList(),
    ),
    pw.SizedBox(height: 6),
    ],
    ))
        .toList(),
    ),

    // Certifications
    if (resume.certifications != null && resume.certifications!.isNotEmpty)
    _buildSection(
    'CERTIFICATIONS',
    resume.certifications!
        .where((cert) => cert.name != null)
        .map((cert) => _buildItem(
    cert.name ?? '',
    cert.year,
    ))
        .toList(),
    ),

    // Languages
    if (resume.languages != null && resume.languages!.isNotEmpty)
    _buildSection(
    'LANGUAGES',
    [
    pw.Wrap(
    spacing: 12,
    runSpacing: 4,
    children: resume.languages!
        .where((lang) => lang.name != null)
        .map((lang) => pw.Text(
    '${lang.name}${lang.proficiency != null ? ' (${lang.proficiency})' : ''}',
    style: bodyStyle,
    ))
        .toList(),
    ),
    ],
    ),
    ],
    ),
    ),
    ),
    ],
    ),
    ];

    pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(32),
      pageFormat: PdfPageFormat.a4,
      build: (context) => content,
    ),
    );

    return pdf;
  }

  // Done!
  static void _buildTemplate03(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final textStyle = pw.TextStyle(fontSize: 10, font: ttfFont, color: PdfColors.grey800);
    final headingStyle = pw.TextStyle(
      fontSize: 22,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.blue800,
    );
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.blue700,
    );
    final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont, color: PdfColors.blue700);
    final accentColor = PdfColors.blue700;
    final lightAccent = PdfColors.blue50;

    pw.Widget sectionDivider() => pw.Container(
      height: 1,
      color: PdfColors.blue200,
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
    );

    pdf.addPage(
        pw.MultiPage(
            margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            build: (context) => [
            // Header
            if (resume.heading != null) ...[
    pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 10),
    decoration: pw.BoxDecoration(
    border: pw.Border(bottom: pw.BorderSide(color: accentColor, width: 2))
    ),
    child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    pw.Text(resume.heading!.name ?? '', style: headingStyle),
    if (resume.heading!.position != null)
    pw.Text(resume.heading!.position!,
    style: textStyle.copyWith(color: PdfColors.grey600)),
    ],
    ),
    ),
    pw.SizedBox(height: 10),
    ],

    // Contact
    if (resume.contact != null && resume.contact!.isNotEmpty) ...[
    pw.Wrap(
    spacing: 16,
    runSpacing: 8,
    children: resume.contact!
        .where((c) => c.type != null && c.value != null)
        .map((c) => pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Text(
        String.fromCharCode(_getContactIconCode(c.type)),
        style: pw.TextStyle(
          font: materialIcon,
          fontSize: 10,
          color: accentColor,
        ),
      ),

    pw.SizedBox(width: 4),
    pw.Text(c.value!, style: textStyle),
    ],
    ))
        .toList(),
    ),
    sectionDivider(),
    ],

    // Summary
    if (resume.summary != null) ...[
    pw.Text('PROFILE SUMMARY', style: sectionTitleStyle),
    pw.SizedBox(height: 6),
    pw.Text(resume.summary!, style: textStyle),
    sectionDivider(),
    ],

    // Experience
    if (resume.experience != null && resume.experience!.isNotEmpty) ...[
    pw.Text('PROFESSIONAL EXPERIENCE', style: sectionTitleStyle),
    pw.SizedBox(height: 8),
    pw.Column(
    children: resume.experience!.map((exp) {
    return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12),
    child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
    pw.Text(exp.position ?? '', style: boldStyle),
    pw.Text(exp.duration ?? '',
    style: textStyle.copyWith(color: accentColor)),
    ],
    ),
    if (exp.company != null)
    pw.Text(exp.company!,
    style: textStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    if (exp.location != null)
    pw.Text(exp.location!, style: textStyle),
    if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
    pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    pw.SizedBox(height: 6),
    ...exp.responsibilities!.map((r) =>
    pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    pw.Text('• ', style: textStyle),
    pw.Expanded(child: pw.Text(r, style: textStyle)),
    ],
    ),
    )
    ).toList(),
    ],
    ),
    ],
    ),
    );
    }).toList(),
    ),
    sectionDivider(),
    ],

    // Education
    if (resume.education != null && resume.education!.isNotEmpty) ...[
    pw.Text('EDUCATION', style: sectionTitleStyle),
    pw.SizedBox(height: 8),
    pw.Column(
    children: resume.education!.map((edu) {
    return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    pw.Text(edu.degree ?? '', style: boldStyle),
    if (edu.institution != null)
    pw.Text(edu.institution!, style: textStyle),
    ],
    ),
    if (edu.year != null)
    pw.Text(edu.year!,
    style: textStyle.copyWith(color: accentColor)),
    ],
    ),
    );
    }).toList(),
    ),
    sectionDivider(),
    ],

    // Skills
    if (resume.skills != null && resume.skills!.isNotEmpty) ...[
    pw.Text('SKILLS', style: sectionTitleStyle),
    pw.SizedBox(height: 8),
    pw.Wrap(
    spacing: 8,
    runSpacing: 8,
    children: resume.skills!.expand((skill) => [
    if (skill.category != null)
    pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: pw.BoxDecoration(
    color: lightAccent,
    borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Text(skill.category!,
    style: boldStyle.copyWith(color: accentColor)),
    ),
    if (skill.items != null)
    ...skill.items!.map((item) =>
    pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: pw.BoxDecoration(
    color: PdfColors.grey100,
    borderRadius: pw.BorderRadius.circular(4),),
    child: pw.Text(item, style: textStyle),
    )
    ),
    ]).toList(),
    ),
    sectionDivider(),
    ],

    // Projects
    if (resume.projects != null && resume.projects!.isNotEmpty) ...[
                pw.Text('PROJECTS', style: sectionTitleStyle),
                pw.SizedBox(height: 8),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: resume.projects!.map((project) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 12),
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.blue200),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (project.name != null)
                            pw.Text(
                              project.name!,
                              style: boldStyle.copyWith(fontSize: 14),
                            ),
                          if (project.description != null)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 6),
                              child: pw.Text(
                                project.description!,
                                style: textStyle.copyWith(fontSize: 10),
                              ),
                            ),
                          if (project.technologies != null && project.technologies!.isNotEmpty)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 8),
                              child: pw.Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: project.technologies!.map((tech) {
                                  return pw.Container(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: pw.BoxDecoration(
                                      color: PdfColors.blue100,
                                      borderRadius: pw.BorderRadius.circular(4),
                                    ),
                                    child: pw.Text(
                                      tech,
                                      style: textStyle.copyWith(color: accentColor, fontSize: 9),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                sectionDivider(),
              ],


    // Certifications
    if (resume.certifications != null && resume.certifications!.isNotEmpty) ...[
    pw.Text('CERTIFICATIONS', style: sectionTitleStyle),
    pw.SizedBox(height: 8),
    pw.Column(
    children: resume.certifications!.map((cert) {
    return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
    pw.Text(cert.name ?? '', style: textStyle),
    pw.Text(cert.year ?? '',
    style: textStyle.copyWith(color: accentColor)),
    ],
    ),
    );
    }).toList(),
    ),
    sectionDivider(),
    ],

    // Languages
    if (resume.languages != null && resume.languages!.isNotEmpty) ...[
    pw.Text('LANGUAGES', style: sectionTitleStyle),
    pw.SizedBox(height: 8),
    pw.Wrap(
    spacing: 12,
    runSpacing: 8,
    children: resume.languages!
        .map((lang) => pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
    pw.Text(lang.name ?? '', style: boldStyle),
    if (lang.proficiency != null)
    pw.Text(' (${lang.proficiency})',
    style: textStyle.copyWith(color: PdfColors.grey600)),
    ],
    ))
        .toList(),
    ),
    ],
    ],
    ),
    );
  }

  // ====================
  // TEMPLATE 4: Creative Red
  // ====================
  static void _buildTemplate04Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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

  // Done!
  static void _buildTemplate04(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final textStyle = pw.TextStyle(fontSize: 10, font: ttfFont, color: PdfColors.grey800);
    final headingStyle = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.deepPurple800,
    );
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.deepPurple600,
      letterSpacing: 1.2,
    );
    final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont);
    final accentColor = PdfColors.deepPurple600;
    final lightAccent = PdfColors.deepPurple50;

    pw.Widget sectionDivider() => pw.Container(
      height: 1,
      width: 40,
      color: accentColor,
      margin: const pw.EdgeInsets.only(bottom: 12, top: 4),
    );

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          List<pw.Widget> content = [];

          // Header
          if (resume.heading != null) {
            content.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(resume.heading!.name ?? '', style: headingStyle),
                  if (resume.heading!.position != null)
                    pw.Text(resume.heading!.position!,
                        style: textStyle.copyWith(color: PdfColors.grey600)),
                  pw.SizedBox(height: 12),
                ],
              ),
            );
          }

          // Contact
          if (resume.contact != null && resume.contact!.isNotEmpty) {
            content.add(
              pw.Wrap(
                spacing: 16,
                runSpacing: 8,
                children: resume.contact!
                    .where((c) => c.type != null && c.value != null)
                    .map((c) => pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      width: 20,
                      height: 20,
                      decoration: pw.BoxDecoration(
                        color: lightAccent,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          String.fromCharCode(_getContactIconCode(c.type)),
                          style: pw.TextStyle(
                            font: materialIcon,
                            fontSize: 10,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(c.value!, style: textStyle),
                  ],
                ))
                    .toList(),
              ),
            );
            content.add(pw.SizedBox(height: 16));
          }

          // Summary
          if (resume.summary != null) {
            content.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PROFILE', style: sectionTitleStyle),
                  sectionDivider(),
                  pw.Text(resume.summary!, style: textStyle),
                  pw.SizedBox(height: 16),
                ],
              ),
            );
          }

          // Experience
          if (resume.experience != null && resume.experience!.isNotEmpty) {
            content.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('EXPERIENCE', style: sectionTitleStyle),
                  sectionDivider(),
                  ...resume.experience!.map((exp) {
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(exp.position ?? '', style: boldStyle),
                            pw.Text(exp.duration ?? '',
                                style: textStyle.copyWith(color: accentColor)),
                          ],
                        ),
                        if (exp.company != null)
                          pw.Text(exp.company!,
                              style: textStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                        if (exp.location != null)
                          pw.Text(exp.location!, style: textStyle),
                        if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: 6),
                              ...exp.responsibilities!.map((r) =>
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 4),
                                    child: pw.Row(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text('• ', style: textStyle),
                                        pw.Expanded(child: pw.Text(r, style: textStyle)),
                                      ],
                                    ),
                                  )
                              ).toList(),
                            ],
                          ),
                        pw.SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                ],
              ),
            );
          }

          // Projects
          if (resume.projects != null && resume.projects!.isNotEmpty) {
            content.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PROJECTS', style: sectionTitleStyle),
                  sectionDivider(),
                  ...resume.projects!.map((project) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 12),
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (project.name != null)
                            pw.Text(
                              project.name!,
                              style: boldStyle.copyWith(fontSize: 14),
                            ),
                          if (project.description != null)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 4),
                              child: pw.Text(
                                project.description!,
                                style: textStyle.copyWith(fontSize: 10),
                              ),
                            ),
                          if (project.technologies != null && project.technologies!.isNotEmpty)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 6),
                              child: pw.Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: project.technologies!.map((tech) {
                                  return pw.Container(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: pw.BoxDecoration(
                                      color: PdfColors.blue100,
                                      borderRadius: pw.BorderRadius.circular(4),
                                    ),
                                    child: pw.Text(
                                      tech,
                                      style: textStyle.copyWith(
                                        color: accentColor,
                                        fontSize: 9,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }

          // Education
          if (resume.education != null && resume.education!.isNotEmpty) {
            content.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('EDUCATION', style: sectionTitleStyle),
                  sectionDivider(),
                  ...resume.education!.map((edu) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(edu.degree ?? '', style: boldStyle),
                        if (edu.institution != null)
                          pw.Text(edu.institution!, style: textStyle),
                        if (edu.year != null)
                          pw.Text(edu.year!,
                              style: textStyle.copyWith(color: accentColor)),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            );
          }

          // Skills
          if (resume.skills != null && resume.skills!.isNotEmpty) {
            content.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SKILLS', style: sectionTitleStyle),
                  sectionDivider(),
                  ...resume.skills!.map((skill) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (skill.category != null)
                          pw.Text(skill.category!, style: boldStyle),
                        if (skill.items != null)
                          pw.Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: skill.items!.map((item) =>
                                pw.Text(item, style: textStyle)
                            ).toList(),
                          ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            );
          }

          // Certifications
          if (resume.certifications != null && resume.certifications!.isNotEmpty) {
            content.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('CERTIFICATIONS', style: sectionTitleStyle),
                  sectionDivider(),
                  ...resume.certifications!.map((cert) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(cert.name ?? '', style: textStyle),
                        if (cert.year != null)
                          pw.Text(cert.year!,
                              style: textStyle.copyWith(color: accentColor)),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            );
          }

          // Languages
          if (resume.languages != null && resume.languages!.isNotEmpty) {
            content.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('LANGUAGES', style: sectionTitleStyle),
                  sectionDivider(),
                  ...resume.languages!.map((lang) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      children: [
                        pw.Text(lang.name ?? '', style: textStyle),
                        pw.Spacer(),
                        if (lang.proficiency != null)
                          pw.Text(lang.proficiency!,
                              style: textStyle.copyWith(color: accentColor)),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            );
          }

          return content;
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 5: Minimalist Black
  // ====================
  static void _buildTemplate05Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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

  //Done
  static void _buildTemplate05(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final baseTextStyle = pw.TextStyle(fontSize: 10, font: ttfFont);
    final sectionTitleStyle = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700, font: ttfFont);

    pw.Widget buildSectionTitle(String title) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 10, bottom: 4),
      child: pw.Text(title, style: sectionTitleStyle),
    );

    pw.Widget buildBulletList(List<String> items) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((e) => pw.Bullet(text: e, style: baseTextStyle)).toList(),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          if (resume.heading != null)
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              if (resume.heading!.name != null)
                pw.Text(resume.heading!.name!, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: ttfFont)),
              if (resume.heading!.position != null)
                pw.Text(resume.heading!.position!, style: pw.TextStyle(fontSize: 12, color: PdfColors.blueGrey, font: ttfFont)),
            ]),
          if (resume.contact != null) ...[
            pw.Divider(thickness: 1, color: PdfColors.blue100),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: resume.contact!.map((e) => pw.Padding(
                padding: const pw.EdgeInsets.only(right: 12),
                child: pw.Text('${e.type}: ${e.value}', style: baseTextStyle),
              )).toList(),
            ),
          ],
          if (resume.summary != null) ...[
            buildSectionTitle('Summary'),
            pw.Text(resume.summary!, style: baseTextStyle),
          ],
          if (resume.experience != null && resume.experience!.isNotEmpty) ...[
            buildSectionTitle('Experience'),
            ...resume.experience!.map((e) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (e.position != null || e.company != null)
                    pw.Text('${e.position ?? ''} at ${e.company ?? ''}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont)),
                  if (e.duration != null || e.location != null)
                    pw.Text('${e.duration ?? ''} | ${e.location ?? ''}', style: baseTextStyle),
                  if (e.responsibilities != null) buildBulletList(e.responsibilities!),
                ],
              ),
            )),
          ],
          if (resume.education != null && resume.education!.isNotEmpty) ...[
            buildSectionTitle('Education'),
            ...resume.education!.map((e) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text('${e.degree ?? ''} - ${e.institution ?? ''} (${e.year ?? ''})', style: baseTextStyle),
            )),
          ],
          if (resume.skills != null && resume.skills!.isNotEmpty) ...[
            buildSectionTitle('Skills'),
            ...resume.skills!.map((cat) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text('${cat.category}: ${cat.items?.join(', ') ?? ''}', style: baseTextStyle),
            )),
          ],
          if (resume.projects != null && resume.projects!.isNotEmpty) ...[
            buildSectionTitle('Projects'),
            ...resume.projects!.map((e) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (e.name != null) pw.Text(e.name!, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont)),
                  if (e.description != null) pw.Text(e.description!, style: baseTextStyle),
                  if (e.technologies != null)
                    pw.Text('Technologies: ${e.technologies!.join(', ')}', style: baseTextStyle),
                ],
              ),
            )),
          ],
          if (resume.certifications != null && resume.certifications!.isNotEmpty) ...[
            buildSectionTitle('Certifications'),
            ...resume.certifications!.map((e) => pw.Text('${e.name ?? ''} (${e.year ?? ''})', style: baseTextStyle)),
          ],
          if (resume.languages != null && resume.languages!.isNotEmpty) ...[
            buildSectionTitle('Languages'),
            ...resume.languages!.map((e) => pw.Text('${e.name ?? ''} - ${e.proficiency ?? ''}', style: baseTextStyle)),
          ],
        ],
      ),
    );
  }


  // ====================
  // TEMPLATE 6: Modern Blue
  // ====================
  static void _buildTemplate06Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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
  // Done!
  static void _buildTemplate06(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final baseTextStyle = pw.TextStyle(fontSize: 10, font: ttfFont);
    final sectionBgColor = PdfColors.grey200;
    final sectionTitleStyle = pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange800, font: ttfFont);

    pw.Widget buildSection(String title, pw.Widget child) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: sectionBgColor,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: sectionTitleStyle),
          pw.SizedBox(height: 4),
          child,
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          if (resume.heading != null)
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              if (resume.heading!.name != null)
                pw.Text(resume.heading!.name!, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, font: ttfFont)),
              if (resume.heading!.position != null)
                pw.Text(resume.heading!.position!, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700, font: ttfFont)),
            ]),
          if (resume.contact != null)
            buildSection(
              'Contact',
              pw.Wrap(
                spacing: 10,
                children: resume.contact!
                    .map((e) => pw.Text('${e.type}: ${e.value}', style: baseTextStyle))
                    .toList(),
              ),
            ),
          if (resume.summary != null)
            buildSection('Summary', pw.Text(resume.summary!, style: baseTextStyle)),
          if (resume.experience != null && resume.experience!.isNotEmpty)
            buildSection(
              'Experience',
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: resume.experience!
                    .map((e) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (e.position != null || e.company != null)
                        pw.Text('${e.position ?? ''} at ${e.company ?? ''}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont)),
                      if (e.duration != null || e.location != null)
                        pw.Text('${e.duration ?? ''} | ${e.location ?? ''}', style: baseTextStyle),
                      if (e.responsibilities != null)
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: e.responsibilities!
                                .map((r) => pw.Bullet(text: r, style: baseTextStyle))
                                .toList()),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),
          if (resume.education != null && resume.education!.isNotEmpty)
            buildSection(
              'Education',
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: resume.education!
                    .map((e) => pw.Text('${e.degree ?? ''}, ${e.institution ?? ''} (${e.year ?? ''})',
                    style: baseTextStyle))
                    .toList(),
              ),
            ),
          if (resume.skills != null && resume.skills!.isNotEmpty)
            buildSection(
              'Skills',
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: resume.skills!
                    .map((cat) => pw.Text('${cat.category}: ${cat.items?.join(', ') ?? ''}', style: baseTextStyle))
                    .toList(),
              ),
            ),
          if (resume.projects != null && resume.projects!.isNotEmpty)
            buildSection(
              'Projects',
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: resume.projects!
                    .map((e) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (e.name != null)
                        pw.Text(e.name!, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont)),
                      if (e.description != null) pw.Text(e.description!, style: baseTextStyle),
                      if (e.technologies != null)
                        pw.Text('Technologies: ${e.technologies!.join(', ')}', style: baseTextStyle),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),
          if (resume.certifications != null && resume.certifications!.isNotEmpty)
            buildSection(
              'Certifications',
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: resume.certifications!
                    .map((e) => pw.Text('${e.name ?? ''} (${e.year ?? ''})', style: baseTextStyle))
                    .toList(),
              ),
            ),
          if (resume.languages != null && resume.languages!.isNotEmpty)
            buildSection(
              'Languages',
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: resume.languages!
                    .map((e) => pw.Text('${e.name ?? ''} - ${e.proficiency ?? ''}', style: baseTextStyle))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }


  // ====================
  // TEMPLATE 7: Modern Blue
  // ====================
  static void _buildTemplate07Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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

  // Done!
  static void _buildTemplate07(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final baseColor = PdfColor.fromInt(0xFF800000); // Maroon
    final sectionTitleStyle = pw.TextStyle(font: ttfFont, fontSize: 14, fontWeight: pw.FontWeight.bold, color: baseColor);
    final normalStyle = pw.TextStyle(font: ttfFont, fontSize: 10);
    final boldStyle = pw.TextStyle(font: ttfFont, fontSize: 10, fontWeight: pw.FontWeight.bold);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        build: (context) => [
          if (resume.heading != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (resume.heading!.name != null)
                  pw.Text(resume.heading!.name!, style: pw.TextStyle(font: ttfFont, fontSize: 24, fontWeight: pw.FontWeight.bold, color: baseColor)),
                if (resume.heading!.position != null)
                  pw.Text(resume.heading!.position!, style: pw.TextStyle(font: ttfFont, fontSize: 12)),
                pw.SizedBox(height: 8),
              ],
            ),

          if (resume.contact != null && resume.contact!.isNotEmpty)
            pw.Wrap(
              spacing: 10,
              runSpacing: 5,
              children: resume.contact!.map((c) {
                return pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      String.fromCharCode(_getContactIconCode(c.type)),
                      style: pw.TextStyle(font: materialIcon, fontSize: 12, color: baseColor),
                    ),
                    pw.SizedBox(width: 4),
                    pw.Text(c.value ?? '', style: normalStyle),
                  ],
                );
              }).toList(),
            ),

          if (resume.summary != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text('Summary', style: sectionTitleStyle),
                pw.Text(resume.summary!, style: normalStyle),
              ],
            ),

          if (resume.experience != null && resume.experience!.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text('Experience', style: sectionTitleStyle),
                ...resume.experience!.map((exp) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${exp.position ?? ''} at ${exp.company ?? ''}', style: boldStyle),
                      pw.Text('${exp.duration ?? ''} • ${exp.location ?? ''}', style: normalStyle),
                      if (exp.responsibilities != null)
                        ...exp.responsibilities!.map((r) => pw.Bullet(text: r, style: normalStyle)),
                    ],
                  ),
                )),
              ],
            ),

          if (resume.education != null && resume.education!.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text('Education', style: sectionTitleStyle),
                ...resume.education!.map((e) => pw.Text('${e.degree ?? ''}, ${e.institution ?? ''} (${e.year ?? ''})', style: normalStyle)),
              ],
            ),

          if (resume.skills != null && resume.skills!.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text('Skills', style: sectionTitleStyle),
                ...resume.skills!.map((s) => pw.Text('${s.category ?? ''}: ${s.items?.join(', ') ?? ''}', style: normalStyle)),
              ],
            ),

          if (resume.projects != null && resume.projects!.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text('Projects', style: sectionTitleStyle),
                ...resume.projects!.map((p) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(p.name ?? '', style: boldStyle),
                      if (p.description != null)
                        pw.Text(p.description!, style: normalStyle),
                      if (p.technologies != null)
                        pw.Text('Tech: ${p.technologies!.join(', ')}', style: normalStyle),
                    ],
                  ),
                )),
              ],
            ),
        ],
      ),
    );
  }

  // ====================
  // TEMPLATE 8: Modern Green
  // ====================
  static void _buildTemplate08Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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

  // Done!
  static void _buildTemplate08(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final baseColor = PdfColors.green.shade(0.6);
    final sectionTitleStyle = pw.TextStyle(font: ttfFont, fontSize: 14, fontWeight: pw.FontWeight.bold, color: baseColor);
    final normalStyle = pw.TextStyle(font: ttfFont, fontSize: 10);
    final boldStyle = pw.TextStyle(font: ttfFont, fontSize: 10, fontWeight: pw.FontWeight.bold);

    pw.Widget sectionTitle(String title) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        pw.Text(title, style: sectionTitleStyle),
        pw.Container(
          width: double.infinity,
          height: 1,
          color: baseColor,
          margin: const pw.EdgeInsets.only(top: 2, bottom: 6),
        ),
      ],
    );

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        build: (context) => [
          if (resume.heading != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (resume.heading!.name != null)
                  pw.Text(resume.heading!.name!, style: pw.TextStyle(font: ttfFont, fontSize: 24, fontWeight: pw.FontWeight.bold, color: baseColor)),
                if (resume.heading!.position != null)
                  pw.Text(resume.heading!.position!, style: pw.TextStyle(font: ttfFont, fontSize: 12)),
                pw.SizedBox(height: 8),
              ],
            ),

          if (resume.contact != null && resume.contact!.isNotEmpty)
            pw.Wrap(
              spacing: 10,
              runSpacing: 5,
              children: resume.contact!.map((c) {
                return pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      String.fromCharCode(_getContactIconCode(c.type)),
                      style: pw.TextStyle(font: materialIcon, fontSize: 12, color: baseColor),
                    ),
                    pw.SizedBox(width: 4),
                    pw.Text(c.value ?? '', style: normalStyle),
                  ],
                );
              }).toList(),
            ),

          if (resume.summary != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                sectionTitle('Summary'),
                pw.Text(resume.summary!, style: normalStyle),
              ],
            ),

          if (resume.experience != null && resume.experience!.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                sectionTitle('Experience'),
                ...resume.experience!.map((exp) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${exp.position ?? ''} at ${exp.company ?? ''}', style: boldStyle),
                      pw.Text('${exp.duration ?? ''} • ${exp.location ?? ''}', style: normalStyle),
                      if (exp.responsibilities != null)
                        ...exp.responsibilities!.map((r) => pw.Bullet(text: r, style: normalStyle)),
                    ],
                  ),
                )),
              ],
            ),

          if (resume.education != null && resume.education!.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                sectionTitle('Education'),
                ...resume.education!.map((e) => pw.Text('${e.degree ?? ''}, ${e.institution ?? ''} (${e.year ?? ''})', style: normalStyle)),
              ],
            ),

          if (resume.skills != null && resume.skills!.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                sectionTitle('Skills'),
                ...resume.skills!.map((s) => pw.Text('${s.category ?? ''}: ${s.items?.join(', ') ?? ''}', style: normalStyle)),
              ],
            ),

          if (resume.projects != null && resume.projects!.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                sectionTitle('Projects'),
                ...resume.projects!.map((p) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(p.name ?? '', style: boldStyle),
                      if (p.description != null)
                        pw.Text(p.description!, style: normalStyle),
                      if (p.technologies != null)
                        pw.Text('Tech: ${p.technologies!.join(', ')}', style: normalStyle),
                    ],
                  ),
                )),
              ],
            ),
        ],
      ),
    );
  }


  // ====================
  // TEMPLATE 9: Elegant Purple
  // ====================
  static void _buildTemplate09Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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

  // Done!
  static void _buildTemplate09(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final textStyle = pw.TextStyle(fontSize: 10, font: ttfFont, color: PdfColors.grey800);
    final headingStyle = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.deepPurple800,
    );
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.deepPurple600,
      letterSpacing: 1.2,
    );
    final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont);
    final accentColor = PdfColors.deepPurple600;
    final lightAccent = PdfColors.deepPurple50;

    pw.Widget sectionDivider() => pw.Container(
      height: 1,
      width: 40,
      color: accentColor,
      margin: const pw.EdgeInsets.only(bottom: 12, top: 4),
    );

    List<pw.Widget> _buildExperienceItems() {
      return resume.experience!.map((exp) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(exp.position ?? '', style: boldStyle),
                  pw.Text(exp.duration ?? '', style: textStyle.copyWith(color: accentColor)),
                ],
              ),
              if (exp.company != null) pw.Text(exp.company!, style: boldStyle.copyWith(fontSize: 10)),
              if (exp.location != null) pw.Text(exp.location!, style: textStyle),
              if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: exp.responsibilities!.map((r) =>
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• ', style: textStyle),
                            pw.Expanded(child: pw.Text(r, style: textStyle)),
                          ],
                        ),
                      )
                  ).toList(),
                ),
            ],
          ),
        );
      }).toList();
    }

    List<pw.Widget> _buildProjectItems() {
      return resume.projects!.map((project) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (project.name != null)
                pw.Text(project.name!, style: boldStyle.copyWith(fontSize: 14)),
              if (project.description != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(project.description!, style: textStyle),
                ),
              if (project.technologies != null && project.technologies!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 6),
                  child: pw.Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: project.technologies!.map((tech) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        tech,
                        style: textStyle.copyWith(color: accentColor, fontSize: 9),
                      ),
                    )).toList(),
                  ),
                ),
            ],
          ),
        );
      }).toList();
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          if (resume.heading != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(resume.heading!.name ?? '', style: headingStyle),
                if (resume.heading!.position != null)
                  pw.Text(resume.heading!.position!, style: textStyle.copyWith(color: PdfColors.grey600)),
                pw.SizedBox(height: 12),
              ],
            ),

          if (resume.contact != null && resume.contact!.isNotEmpty)
            pw.Wrap(
              spacing: 16,
              runSpacing: 8,
              children: resume.contact!
                  .where((c) => c.type != null && c.value != null)
                  .map((c) => pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    width: 20,
                    height: 20,
                    decoration: pw.BoxDecoration(
                      color: lightAccent,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        String.fromCharCode(_getContactIconCode(c.type)),
                        style: pw.TextStyle(font: materialIcon, fontSize: 10, color: accentColor),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text(c.value!, style: textStyle),
                ],
              )).toList(),
            ),

          if (resume.summary != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PROFILE', style: sectionTitleStyle),
                sectionDivider(),
                pw.Text(resume.summary!, style: textStyle),
                pw.SizedBox(height: 16),
              ],
            ),

          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 7,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (resume.experience != null && resume.experience!.isNotEmpty)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('EXPERIENCE', style: sectionTitleStyle),
                          sectionDivider(),
                          ..._buildExperienceItems(),
                        ],
                      ),
                    if (resume.projects != null && resume.projects!.isNotEmpty)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('PROJECTS', style: sectionTitleStyle),
                          sectionDivider(),
                          ..._buildProjectItems(),
                        ],
                      ),
                  ],
                ),
              ),

              pw.Expanded(
                flex: 3,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (resume.education != null && resume.education!.isNotEmpty)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('EDUCATION', style: sectionTitleStyle),
                            sectionDivider(),
                            ...resume.education!.map((edu) => pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 12),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(edu.degree ?? '', style: boldStyle),
                                  if (edu.institution != null)
                                    pw.Text(edu.institution!, style: textStyle),
                                  if (edu.year != null)
                                    pw.Text(edu.year!, style: textStyle.copyWith(color: accentColor)),
                                ],
                              ),
                            )).toList(),
                          ],
                        ),

                      if (resume.skills != null && resume.skills!.isNotEmpty)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('SKILLS', style: sectionTitleStyle),
                            sectionDivider(),
                            pw.Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: resume.skills!
                                  .expand((skill) => skill.items ?? [])
                                  .map((item) => pw.Text('$item,', style: textStyle))
                                  .toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ====================
  // TEMPLATE 10: Creative Red
  // ====================
  static void _buildTemplate10Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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

  // Done!
  static void _buildTemplate10(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final textStyle = pw.TextStyle(fontSize: 10, font: ttfFont, color: PdfColors.grey800);
    final whiteTextStyle = textStyle.copyWith(color: PdfColors.white);
    final headingStyle = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.white,
    );
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.blue800,
    );
    final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont);
    final accentColor = PdfColors.blue800;
    final headerBgColor = PdfColors.blue700;

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(0),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          List<pw.Widget> sections = [];

          // Header with solid blue background
          sections.add(
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(30),
              decoration: pw.BoxDecoration(
                color: headerBgColor,
                borderRadius: const pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(10),
                  bottomRight: pw.Radius.circular(10),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (resume.heading != null) ...[
                    pw.Text(resume.heading!.name ?? '', style: headingStyle),
                    if (resume.heading!.position != null)
                      pw.Text(resume.heading!.position!,
                          style: whiteTextStyle.copyWith(fontSize: 14)),
                    pw.SizedBox(height: 12),
                  ],
                  if (resume.contact != null && resume.contact!.isNotEmpty)
                    pw.Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: resume.contact!
                          .where((c) => c.value != null && c.value!.isNotEmpty)
                          .map((c) => pw.Text('${c.type}: ${c.value}',
                          style: whiteTextStyle))
                          .toList(),
                    ),
                ],
              ),
            ),
          );

          // Main content
          sections.add(
              pw.Padding(
                padding: const pw.EdgeInsets.all(30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Summary
                    if (resume.summary != null) ...[
                            pw.Text('PROFILE SUMMARY', style: sectionTitleStyle),
                        pw.Divider(color: accentColor, thickness: 1),
                        pw.SizedBox(height: 8),
                        pw.Text(resume.summary!, style: textStyle),
                        pw.SizedBox(height: 20),
                        ],

                    // Experience
                    if (resume.experience != null && resume.experience!.isNotEmpty) ...[
                    pw.Text('PROFESSIONAL EXPERIENCE', style: sectionTitleStyle),
                    pw.Divider(color: accentColor, thickness: 1),
                    pw.SizedBox(height: 8),
                    ...resume.experience!.take(4).map((exp) {
                    return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                    pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                    pw.Text(exp.position ?? '', style: boldStyle),
                    pw.Text(exp.duration ?? '',
                    style: textStyle.copyWith(color: accentColor)),
                    ],
                    ),
                    if (exp.company != null)
                    pw.Text(exp.company!,
                    style: textStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                    if (exp.location != null)
                    pw.Text(exp.location!, style: textStyle),
                    if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                    pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                    pw.SizedBox(height: 6),
                    ...exp.responsibilities!.take(5).map((r) =>
                    pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                    pw.Text('• ', style: textStyle),
                    pw.Expanded(child: pw.Text(r, style: textStyle)),
                    ],
                    ),
                    )
                    ).toList(),
                    ],
                    ),
                    pw.SizedBox(height: 16),
                    ],
                    );
                    }).toList(),
                    ],

                    // Skills
                    if (resume.skills != null && resume.skills!.isNotEmpty) ...[
                    pw.Text('SKILLS', style: sectionTitleStyle),
                    pw.Divider(color: accentColor, thickness: 1),
                    pw.SizedBox(height: 8),
                      pw.ListView(
                        children: resume.skills!.map((skill) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 12),
                            child: pw.Text(
                              skill.category != null && skill.items != null && skill.items!.isNotEmpty
                                  ? '${skill.category!}: ${skill.items!.join(", ")}'
                                  : skill.category ?? '',
                              style: boldStyle.copyWith(
                                color: accentColor,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
          );

          return sections;
        },
      ),
    );
  }
  // ====================
  // TEMPLATE 11: Minimalist
  // ====================

  static void _buildTemplate11Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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

  // Done
  static void _buildTemplate11(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final textStyle = pw.TextStyle(fontSize: 10, font: ttfFont, color: PdfColors.grey800);
    final whiteTextStyle = textStyle.copyWith(color: PdfColors.white);
    final headingStyle = pw.TextStyle(
      fontSize: 22,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.white,
    );
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.blue800,
    );
    final sidebarTitleStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.white,
    );
    final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfFont);
    final accentColor = PdfColors.blue800;
    final sidebarBgColor = PdfColors.blue700;

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(0),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            // Main layout with sidebar
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Blue sidebar (30%)
                pw.Container(
                  width: 120,
                  decoration: pw.BoxDecoration(
                    color: sidebarBgColor,
                  ),
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Name in sidebar
                      if (resume.heading != null) ...[
                        pw.Text(resume.heading!.name ?? '', style: headingStyle),
                        pw.SizedBox(height: 8),
                        if (resume.heading!.position != null)
                          pw.Text(resume.heading!.position!,
                              style: whiteTextStyle.copyWith(fontSize: 10)),
                        pw.SizedBox(height: 20),
                      ],

                      // Contact in sidebar
                      if (resume.contact != null && resume.contact!.isNotEmpty) ...[
                        pw.Text('CONTACT', style: sidebarTitleStyle),
                        pw.SizedBox(height: 8),
                        ...resume.contact!
                            .where((c) => c.value != null && c.value!.isNotEmpty)
                            .map((c) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 6),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(c.type ?? '',
                                  style: whiteTextStyle.copyWith(fontSize: 8)),
                              pw.Text(c.value!, style: whiteTextStyle),
                            ],
                          ),
                        ))
                            .toList(),
                        pw.SizedBox(height: 20),
                      ],

                      // Skills in sidebar
                      if (resume.skills != null && resume.skills!.isNotEmpty) ...[
                        pw.Text('SKILLS', style: sidebarTitleStyle),
                        pw.SizedBox(height: 8),
                        ...resume.skills!
                            .where((skill) => skill.items != null && skill.items!.isNotEmpty)
                            .map((skill) => pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (skill.category != null)
                              pw.Text(skill.category!,
                                  style: whiteTextStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                            ...skill.items!
                                .map((item) => pw.Text(item, style: whiteTextStyle.copyWith(fontSize: 9)))
                                .toList(),
                            pw.SizedBox(height: 6),
                          ],
                        ))
                            .toList(),
                      ],
                    ],
                  ),
                ),

                // Main content (70%)
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(30),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Summary
                        if (resume.summary != null) ...[
                          pw.Text('PROFILE', style: sectionTitleStyle),
                          pw.Divider(color: accentColor, thickness: 1),
                          pw.SizedBox(height: 8),
                          pw.Text(resume.summary!, style: textStyle),
                          pw.SizedBox(height: 20),
                        ],

                        // Experience
                        if (resume.experience != null && resume.experience!.isNotEmpty) ...[
                          pw.Text('EXPERIENCE', style: sectionTitleStyle),
                          pw.Divider(color: accentColor, thickness: 1),
                          pw.SizedBox(height: 8),
                          ...resume.experience!.take(3).map((exp) {
                            return pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(exp.position ?? '', style: boldStyle),
                                    pw.Text(exp.duration ?? '',
                                        style: textStyle.copyWith(color: accentColor)),
                                  ],
                                ),
                                if (exp.company != null)
                                  pw.Text(exp.company!,
                                      style: textStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                                if (exp.location != null)
                                  pw.Text(exp.location!, style: textStyle),
                                if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                  pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.SizedBox(height: 6),
                                      ...exp.responsibilities!.take(4).map((r) =>
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(bottom: 4),
                                            child: pw.Row(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text('• ', style: textStyle),
                                                pw.Expanded(child: pw.Text(r, style: textStyle)),
                                              ],
                                            ),
                                          )
                                      ).toList(),
                                    ],
                                  ),
                                pw.SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        ],

                        // Projects
                        if (resume.projects != null && resume.projects!.isNotEmpty) ...[
                          pw.Text('KEY PROJECTS', style: sectionTitleStyle),
                          pw.Divider(color: accentColor, thickness: 1),
                          pw.SizedBox(height: 8),
                          ...resume.projects!.take(2).map((project) {
                            return pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                if (project.name != null)
                                  pw.Text(project.name!, style: boldStyle.copyWith(color: accentColor)),
                                if (project.description != null)
                                  pw.Text(project.description!, style: textStyle),
                                pw.SizedBox(height: 8),
                              ],
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );
  }


  // ====================
  // TEMPLATE 12: Elegant
  // ====================

  static void _buildTemplate12Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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

  // Done!
  static void _buildTemplate12(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final textStyle = pw.TextStyle(fontSize: 10, font: ttfFont, color: PdfColors.grey800);
    final accentTextStyle = textStyle.copyWith(color: PdfColors.blue700);
    final headingStyle = pw.TextStyle(
      fontSize: 28,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.blue700,
    );
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.blue700,
      letterSpacing: 1.5,
    );
    final highlightColor = PdfColors.blue700;
    final lightAccent = PdfColors.blue50;

    // Geometric divider
    pw.Widget sectionDivider() => pw.Container(
      height: 3,
      width: 40,
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [highlightColor, PdfColors.blue400],
        ),
        borderRadius: pw.BorderRadius.circular(2),
      ),
      margin: const pw.EdgeInsets.only(bottom: 12, top: 4),
    );

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(0),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            // Full width header with accent strip
            pw.Stack(
              children: [
                pw.Container(
                  height: 80,
                  color: lightAccent,
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (resume.heading != null) ...[
                              pw.Text(resume.heading!.name ?? '', style: headingStyle),
                              if (resume.heading!.position != null)
                                pw.Text(resume.heading!.position!,
                                    style: textStyle.copyWith(fontSize: 12, color: PdfColors.grey600)),
                            ],
                          ],
                        ),
                      ),
                      if (resume.contact != null && resume.contact!.isNotEmpty)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: resume.contact!
                                .where((c) => c.value != null && c.value!.isNotEmpty)
                                .map((c) => pw.Text('${c.type}: ${c.value}',
                                style: accentTextStyle.copyWith(fontSize: 9)))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Main content with two columns
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left column (60%)
                  pw.Expanded(
                    flex: 6,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Experience with timeline effect
                        if (resume.experience != null && resume.experience!.isNotEmpty) ...[
                          pw.Text('WORK HISTORY', style: sectionTitleStyle),
                          sectionDivider(),
                          ...resume.experience!.take(3).map((exp) {
                            return pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 16),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                  left: pw.BorderSide(
                                    color: highlightColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              padding: const pw.EdgeInsets.only(left: 12),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(exp.position ?? '',
                                          style: textStyle.copyWith(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 12,
                                          )),
                                      pw.Container(
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: pw.BoxDecoration(
                                          color: lightAccent,
                                          borderRadius: pw.BorderRadius.circular(4),
                                        ),
                                        child: pw.Text(exp.duration ?? '',
                                            style: accentTextStyle.copyWith(fontSize: 8)),
                                      ),
                                    ],
                                  ),
                                  if (exp.company != null)
                                    pw.Text(exp.company!,
                                        style: textStyle.copyWith(color: PdfColors.grey600)),
                                  if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                                    pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.SizedBox(height: 8),
                                        ...exp.responsibilities!.take(4).map((r) =>
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.only(bottom: 4),
                                              child: pw.Row(
                                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Container(
                                                    margin: const pw.EdgeInsets.only(top: 4, right: 8),
                                                    width: 6,
                                                    height: 6,
                                                    decoration: pw.BoxDecoration(
                                                      color: highlightColor,
                                                      shape: pw.BoxShape.circle,
                                                    ),
                                                  ),
                                                  pw.Expanded(child: pw.Text(r, style: textStyle)),
                                                ],
                                              ),
                                            )
                                        ).toList(),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),

                  // Right column (40%)
                  pw.Expanded(
                    flex: 4,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Summary
                          if (resume.summary != null) ...[
                            pw.Text('PROFILE', style: sectionTitleStyle),
                            sectionDivider(),
                            pw.Text(resume.summary!, style: textStyle),
                            pw.SizedBox(height: 20),
                          ],

                          // Skills with progress bars
                          if (resume.skills != null && resume.skills!.isNotEmpty) ...[
                            pw.Text('SKILLS', style: sectionTitleStyle),
                            sectionDivider(),
                            pw.SizedBox(height: 8),
                            ...resume.skills!
                                .expand((skill) => skill.items ?? [])
                                .take(15)
                                .map((item) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Text(item, style: textStyle),
                            )).toList(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 13: Creative
  // ====================

  static void _buildTemplate13Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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

  // Done!
  static void _buildTemplate13(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    final textStyle = pw.TextStyle(fontSize: 10, font: ttfFont, color: PdfColors.grey800);
    final accentTextStyle = textStyle.copyWith(color: PdfColors.indigo700);
    final headingStyle = pw.TextStyle(
      fontSize: 36,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.indigo700,
    );
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: PdfColors.white,
    );
    final highlightColor = PdfColors.indigo700;
    final lightAccent = PdfColors.indigo50;

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(0),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            // Main content
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with name
                  if (resume.heading != null) ...[
                    pw.Text(resume.heading!.name ?? '', style: headingStyle),
                    if (resume.heading!.position != null)
                      pw.Text(resume.heading!.position!,
                          style: textStyle.copyWith(fontSize: 14, color: PdfColors.grey600)),
                    pw.SizedBox(height: 30),
                  ],

                  // Contact in horizontal layout
                  if (resume.contact != null && resume.contact!.isNotEmpty) ...[
                    pw.Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: resume.contact!
                          .where((c) => c.value != null && c.value!.isNotEmpty)
                          .map((c) => pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text('${c.type}:',
                              style: textStyle.copyWith(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(width: 4),
                          pw.Text(c.value!, style: accentTextStyle),
                        ],
                      ))
                          .toList(),
                    ),
                    pw.SizedBox(height: 30),
                  ],

                  // Summary with colored background
                  if (resume.summary != null) ...[
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: lightAccent,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(resume.summary!, style: textStyle),
                    ),
                    pw.SizedBox(height: 30),
                  ],

                  // Experience with colored section headers
                  if (resume.experience != null && resume.experience!.isNotEmpty) ...[
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: pw.BoxDecoration(
                        color: highlightColor,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text('EXPERIENCE', style: sectionTitleStyle),
                    ),
                    pw.SizedBox(height: 20),
                    ...resume.experience!.take(4).map((exp) {
                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(exp.position ?? '',
                                  style: textStyle.copyWith(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 12,
                                  )),
                              pw.Text(exp.duration ?? '',
                                  style: accentTextStyle.copyWith(fontSize: 8)),
                            ],
                          ),
                          if (exp.company != null)
                            pw.Text(exp.company!,
                                style: textStyle.copyWith(color: PdfColors.grey600)),
                          if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 8, bottom: 20),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  ...exp.responsibilities!.take(4).map((r) =>
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.only(bottom: 6),
                                        child: pw.Row(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Container(
                                              margin: const pw.EdgeInsets.only(top: 4, right: 8),
                                              width: 6,
                                              height: 6,
                                              decoration: pw.BoxDecoration(
                                                color: highlightColor,
                                                shape: pw.BoxShape.circle,
                                              ),
                                            ),
                                            pw.Expanded(child: pw.Text(r, style: textStyle)),
                                          ],
                                        ),
                                      )
                                  ).toList(),
                                ],
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ],

                  // Skills with colored section header
                  if (resume.skills != null && resume.skills!.isNotEmpty) ...[
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: pw.BoxDecoration(
                        color: highlightColor,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text('SKILLS', style: sectionTitleStyle),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: resume.skills!
                          .expand((skill) => [
                        if (skill.category != null)
                          pw.Text(skill.category! + ':',
                              style: textStyle.copyWith(
                                fontWeight: pw.FontWeight.bold,
                                color: highlightColor,
                              )),
                        if (skill.items != null)
                          ...skill.items!.map((item) => pw.Text(item, style: textStyle))
                      ])
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ];
        },
      ),
    );
  }


  // ====================
  // TEMPLATE 14: Modern
  // ===================

  // Done!
  static void _buildTemplate14Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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
  // Done!
  static void _buildTemplate14(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    // Color scheme
    final bgColor = PdfColors.grey900; // Matte black
    final primaryColor = PdfColors.orange600;
    final accentColor = PdfColors.yellow400;
    final textColor = PdfColors.white;
    final secondaryText = PdfColors.grey300;

    // Text styles
    final nameStyle = pw.TextStyle(
      fontSize: 42,
      fontWeight: pw.FontWeight.bold,
      font: ttfFont,
      color: primaryColor,
    );
    final titleStyle = pw.TextStyle(
      fontSize: 16,
      color: accentColor,
      font: ttfFont,
    );
    final sectionStyle = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      color: textColor,
      font: ttfFont,
    );
    final bodyStyle = pw.TextStyle(
      fontSize: 10,
      color: textColor,
      font: ttfFont,
    );
    final highlightStyle = bodyStyle.copyWith(color: accentColor);

    // Custom elements
    pw.Widget _sectionHeader(String text) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 20, bottom: 10),
        child: pw.Row(
          children: [
            pw.Container(
              width: 4,
              height: 24,
              color: primaryColor,
            ),
            pw.SizedBox(width: 10),
            pw.Text(text, style: sectionStyle),
            pw.Expanded(
              child: pw.Container(
                margin: const pw.EdgeInsets.only(left: 10),
                height: 1,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget _experienceItem(ExperienceItem exp) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 15),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(exp.position ?? '',
                    style: bodyStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: primaryColor,
                    )),
                pw.Text(exp.duration ?? '',
                    style: highlightStyle.copyWith(fontSize: 9)),
              ],
            ),
            if (exp.company != null)
              pw.Text(exp.company!,
                  style: bodyStyle.copyWith(color: secondaryText)),
            if (exp.responsibilities != null && exp.responsibilities!.isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 5),
                  ...exp.responsibilities!.map((r) =>
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 3),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              String.fromCharCode(0xe3a5), // Example Material icon (like a checkbox)
                              style: pw.TextStyle(
                                font: materialIcon,
                                fontSize: 12,
                                color: accentColor,
                              ),
                            ),
                            pw.Expanded(child: pw.Text(r, style: bodyStyle.copyWith(height: 1.4))),
                          ],
                        ),
                      )
                  ).toList(),
                ],
              ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Background
            pw.Container(
              color: bgColor,
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  if (resume.heading != null) ...[
                    pw.Text(resume.heading!.name ?? '', style: nameStyle),
                    if (resume.heading!.position != null)
                      pw.Text(resume.heading!.position!, style: titleStyle),
                    pw.SizedBox(height: 5),
                  ],

                  // Contact strip
                  if (resume.contact != null && resume.contact!.isNotEmpty)
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 15, bottom: 25),
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey800,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Wrap(
                        spacing: 20,
                        runSpacing: 10,
                        children: resume.contact!
                            .where((c) => c.value != null && c.value!.isNotEmpty)
                            .map((c) => pw.Row(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Container(
                              width: 6,
                              height: 6,
                              margin: const pw.EdgeInsets.only(right: 6),
                              decoration: pw.BoxDecoration(
                                color: accentColor,
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                            pw.Text('${c.value}',
                                style: bodyStyle.copyWith(color: accentColor)),
                          ],
                        ))
                            .toList(),
                      ),
                    ),

                  // Experience
                  _sectionHeader('EXPERIENCE'),
                  if (resume.experience != null && resume.experience!.isNotEmpty)
                    ...resume.experience!.take(4).map(_experienceItem).toList(),

                  // Skills
                  _sectionHeader('TECHNICAL SKILLS'),
                  if (resume.skills != null && resume.skills!.isNotEmpty)
                    pw.Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: resume.skills!
                          .expand((skill) => [
                        if (skill.items != null)
                          ...skill.items!.map((item) => pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: pw.BoxDecoration(
                              gradient: pw.LinearGradient(
                                colors: [primaryColor, PdfColors.orange400],
                              ),
                              borderRadius: pw.BorderRadius.circular(12),
                              boxShadow: [
                                pw.BoxShadow(
                                  color: primaryColor.shade(0.3),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: pw.Text(item,
                                style: bodyStyle.copyWith(
                                  color: bgColor,
                                  fontWeight: pw.FontWeight.bold,
                                )),
                          ))
                      ])
                          .toList(),
                    ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  // ====================
  // TEMPLATE 15: Modern
  // ===================



  static void _buildTemplate15Old(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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
  static void _buildTemplate154(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
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

  static void _buildTemplate15(pw.Document pdf, Resume resume, pw.ImageProvider? avatarImage) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.all(24),
        build: (context) => [

          // Header with avatar and name
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (resume.heading?.name != null)
                      pw.Text(
                        resume.heading!.name!,
                        style: pw.TextStyle(
                          font: ttfFont,
                          fontSize: 54,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFFDC493A)
                        ),
                      ),

                    if (resume.heading?.position != null)
                      pw.Text(
                        resume.heading!.position!,
                        style: pw.TextStyle( font: ttfFont,
                          fontSize: 20,
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
                                color: PdfColor.fromInt(0xFFDC493A),
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
              accentColor: PdfColor.fromInt(0xFFDC493A),
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
              accentColor: PdfColor.fromInt(0xFFDC493A),
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
                          width: 10,
                          height: 10,
                          margin:  pw.EdgeInsets.only(top: 4, right: 10),
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColor.fromInt(0xFFDC493A).shade(0.7),
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
              accentColor: PdfColor.fromInt(0xFFDC493A),
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
                          width: 10,
                          height: 10,
                          margin:  pw.EdgeInsets.only(top: 4, right: 10),
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColor.fromInt(0xFFDC493A).shade(0.7),
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
              accentColor: PdfColor.fromInt(0xFFDC493A),
              content: pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: resume.skills!
                    .expand((skillCat) => skillCat.items ?? [])
                    .map((skill) => pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFDC493A).shade(0.1),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    skill,
                    style: pw.TextStyle(
                      font: ttfFont,
                      color: PdfColors.black,
                      fontSize: 10,
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),

        ],
      ),
    );
  }


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