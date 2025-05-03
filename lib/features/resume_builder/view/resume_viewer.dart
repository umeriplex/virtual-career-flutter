import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:virtual_career/core/components/custom_button.dart';
import 'package:virtual_career/core/components/custom_text_field.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/core/utils/toast_helper.dart';
import 'package:virtual_career/features/auth/controller/auth_controller.dart';
import 'package:virtual_career/features/resume_builder/controller/resumer_builder_controller.dart';
import 'package:virtual_career/features/resume_builder/model/resumer_model.dart';

import '../../../core/managers/cache_manager.dart';

class ResumeViewer extends StatefulWidget {
  final File? file;
  final String? pdfUrl;
  final bool isNew;
  final Resume? resume;

  const ResumeViewer({
    super.key,
    this.file,
    this.pdfUrl,
    this.isNew = false,
    this.resume,
  });

  @override
  State<ResumeViewer> createState() => _ResumeViewerState();
}

class _ResumeViewerState extends State<ResumeViewer> {
  TextEditingController _titleController = TextEditingController();
  ScreenshotController _screenshotController = ScreenshotController();

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

                          // Fist take screenshot of the pdf, then convert it to File
                          File? thumbnailFile;
                          await _screenshotController.capture().then((v) async {
                            if (v != null) {
                              final directory = (await getTemporaryDirectory()).path;
                              final imageFile = File('$directory/${DateTime.now()}.png');
                              imageFile.writeAsBytesSync(v);
                              thumbnailFile = imageFile;
                            }
                          }).onError(
                            (error, stackTrace) {
                              debugPrint(error.toString());
                            },
                          );

                          if(thumbnailFile == null){
                            showErrorMessage("Failed to create thumbnail, please try again");
                            return;
                          }

                          await controller.uploadUserResume(
                            userId: SharedPrefs.instance.getUser()!.id,
                            pdfFile: widget.file!,
                            title: _titleController.text,
                            resume: widget.resume!,
                            thumbnailFile: thumbnailFile!,
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
}