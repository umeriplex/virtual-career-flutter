import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:virtual_career/core/components/custom_button.dart';
import 'package:virtual_career/core/components/custom_text_field.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/core/utils/toast_helper.dart';
import 'package:virtual_career/features/resume_builder/controller/resumer_builder_controller.dart';
import 'package:virtual_career/features/resume_builder/model/resumer_model.dart';
import '../../../core/managers/cache_manager.dart';
import '../../../core/managers/pdf_download_manager.dart';
import '../../../core/managers/pdf_share_manager.dart';
import '../../../core/utils/file_utils.dart';

class ResumeViewer extends StatefulWidget {
  final File? file;
  final String? pdfUrl;
  final String? title;
  final bool isNew;
  final Resume? resume;

  const ResumeViewer({
    super.key,
    this.file,
    this.pdfUrl,
    this.isNew = false,
    this.resume, this.title,
  });

  @override
  State<ResumeViewer> createState() => _ResumeViewerState();
}

class _ResumeViewerState extends State<ResumeViewer> {
  TextEditingController _titleController = TextEditingController();
  ScreenshotController _screenshotController = ScreenshotController();
  bool _isDownloading = false;
  bool _isSharing = false;
  String? _downloadedFilePath;

  Future<void> _downloadPDF() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      final filePath = await PDFDownloadManager.save(
        widget.pdfUrl!,
        fileName: widget.title!
      );

      if (filePath != null) {
        _downloadedFilePath = filePath;
        showSuccessMessage("PDF downloaded successfully at $filePath");
      } else {
        showErrorMessage("Failed to download PDF");
      }
    } catch (e) {
      showErrorMessage("Error downloading PDF: ${e.toString()}");
      debugPrint("Download error: $e");
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _sharePDF() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      await PDFShareManager.sharePDF(widget.pdfUrl!, widget.title!);
    } catch (e) {
      showErrorMessage("Error sharing PDF: ${e.toString()}");
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    final ResumeBuilderController controller = Get.find();
    if(widget.isNew){
      if (widget.file != null) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text('Resume Viewer'),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Screenshot(
                  controller: _screenshotController,
                  child: PDFView(
                    backgroundColor: Colors.grey[100],
                    filePath: widget.file!.path,
                  ),
                ),
              ),

              30.verticalSpace,

              Padding(
                padding: responsive.responsivePadding(18.w, 0, 18.w, 0),
                child: CustomTextField(
                  controller: _titleController,
                  hintText: 'Give your resume a title',
                ),
              ),

              10.verticalSpace,

              Obx(() {
                  return Padding(
                    padding: responsive.responsivePadding(18.w, 0, 18.w, 0),
                    child: CustomButton(
                      isLoading: controller.isLoading.value,
                      title: "Save resume in my account",
                      onPressed: () async {



                        if(_titleController.text.isNotEmpty){

                          var thumbnailFile = await getImageFromPdf(loadPdf(widget.file!));

                          await controller.uploadUserResume(
                            userId: SharedPrefs.instance.getUser()!.id,
                            pdfFile: widget.file!,
                            title: _titleController.text,
                            resume: widget.resume!,
                            thumbnailFile: thumbnailFile,
                          );
                          Get.find<ResumeBuilderController>().fetchUserResumes(SharedPrefs.instance.getUser()!.id);
                          Get.back();
                        }
                        else{
                          showErrorMessage("Please give your resume a title");
                        }
                      },
                    ),
                  );
                }
              ),

              20.verticalSpace,


            ],
          ),
        );
      }
      else {
        // Handle case where neither file nor URL is provided
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text('Resume Viewer'),
          ),
          body: const Center(
            child: Text('No resume to display'),
          ),
        );
      }
    }
    else if (widget.file != null) {
      // Display the PDF from a local file
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Resume Viewer'),
        ),
        body: PDFView(
          backgroundColor: Colors.grey[100],
          filePath: widget.file!.path,
        ),
      );
    }
    else if (widget.pdfUrl != null) {
      // Display the PDF from a URL
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Resume Viewer'),
          actions: [
            widget.pdfUrl != null ?
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _isDownloading ? (){} :  () async {
                _downloadPDF();
              },
            ) :
            Container(),

            // share icon
            widget.pdfUrl != null ?
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _isSharing ? (){} : () async {
                _sharePDF();
              },
            ) :
            Container(),
          ],
        ),
        body: PDF(backgroundColor: Colors.grey[100],).fromUrl(
          widget.pdfUrl!,
          placeholder: (progress) => Center(child: Text('$progress%')),
          errorWidget: (error) => const Center(child: Text('Failed to load PDF')),
        ),
      );
    }
    else {
      // Handle case where neither file nor URL is provided
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Resume Viewer'),
        ),
        body: const Center(
          child: Text('No resume to display'),
        ),
      );
    }
  }






  /// Load a local PDF file
  Future<Uint8List> loadPdf(File pdfFile) async {
    Future<Uint8List> documentBytes = pdfFile.readAsBytes();
    return documentBytes;
  }

  /// Pass in document bytes to render image using [Printing]
  /// pages: [0] set to 0 to render first page only.
  Future<File> getImageFromPdf(Future<Uint8List> documentBytes) async {
    late File file;
    try {
      await for (var page in Printing.raster(await documentBytes, pages: [0], dpi: 72)) {
        final image = await page.toPng(); // Convert the page to PNG

        // Save the image as a file
        final directory = (await getTemporaryDirectory()).path;
        final imageFile = File('$directory/${DateTime.now().millisecondsSinceEpoch}.png');
        await imageFile.writeAsBytes(image);
        file = imageFile;
      }
      return file;
    } catch (e) {
      await _screenshotController.capture().then((v) async {
        if (v != null) {
          final directory = (await getTemporaryDirectory()).path;
          final imageFile = File('$directory/${DateTime.now()}.png');
          imageFile.writeAsBytesSync(v);
          file = imageFile;
        }
      }).onError((error, stackTrace) async {
          debugPrint(error.toString());
          file = await generatePlaceholderImage();
        },
      );
      return file;
    }
  }







}