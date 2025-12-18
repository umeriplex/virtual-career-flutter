
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:virtual_career/core/components/custom_text_field.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/features/jobs/controller/job_controller.dart';
import 'package:virtual_career/core/components/custom_button.dart';
import 'package:virtual_career/core/components/custom_image_view.dart';
import 'package:virtual_career/features/resume_builder/controller/resumer_builder_controller.dart';
import 'package:virtual_career/features/resume_builder/model/user_resume.dart';

class JobApplicationFormView extends StatefulWidget {
  const JobApplicationFormView({super.key});

  @override
  State<JobApplicationFormView> createState() => _JobApplicationFormViewState();
}

class _JobApplicationFormViewState extends State<JobApplicationFormView> {
  final _controller = Get.find<JobController>();
  final _resumeController = Get.find<ResumeBuilderController>();
  final _coverLetterController = TextEditingController();
  final _phoneController = TextEditingController();
  
  File? _resumeFile;
  UserResume? _selectedResume;
  late String jobId;

  @override
  void initState() {
    super.initState();
    jobId = Get.arguments as String;
    // Refresh resumes to ensure we have the latest
    // Assuming auth controller has user, resume controller uses it in onInit but let's be safe
    // Actually controller.fetchUserResumes is public
    // _resumeController.fetchUserResumes... (it's done in its onInit)
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
        _selectedResume = null; // Deselect existing if uploading new
      });
    }
  }

  void _selectResume(UserResume resume) {
    setState(() {
      _selectedResume = resume;
      _resumeFile = null; // Clear manual upload if selecting existing
    });
  }

  Future<void> _submitApplication() async {
    if (_coverLetterController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please write a cover letter');
      return;
    }

    if (_resumeFile == null && _selectedResume == null) {
       Get.snackbar('Error', 'Please select or upload a resume');
      return;
    }

    final success = await _controller.applyForJob(
      jobId: jobId,
      coverLetter: _coverLetterController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      resumeFile: _resumeFile,
      existingResumeUrl: _selectedResume?.pdfUrl,
    );

    if (success) {
      Get.back(result: true);
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for Job'),
      ),
      body: SingleChildScrollView(
        padding: responsive.responsivePadding(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cover Letter *', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold)),
            8.verticalSpace,
            CustomTextField(
              controller: _coverLetterController,
              maxLines: 5,
              hintText: 'Write your cover letter...',
            ),
            16.verticalSpace,

            Text('Phone Number', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold)),
            8.verticalSpace,
            CustomTextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              hintText: 'Enter phone number',
            ),
            16.verticalSpace,

            Text('Resume (PDF)', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold)),
            8.verticalSpace,
            
            // Existing Resumes List
            Obx(() {
              if (_resumeController.resumes.isNotEmpty) {
                 return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select from your resumes:',
                      style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 12.sp, color: Colors.grey),
                    ),
                    8.verticalSpace,
                    SizedBox(
                      height: 180.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _resumeController.resumes.length,
                        itemBuilder: (context, index) {
                          final resume = _resumeController.resumes[index];
                          final isSelected = _selectedResume?.id == resume.id;
                          
                          return GestureDetector(
                            onTap: () => _selectResume(resume),
                            child: Container(
                              width: 120.w,
                              margin: EdgeInsets.only(right: 12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                                      child: UltimateCachedNetworkImage(
                                        imageUrl: resume.thumbnailUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resume.title,
                                          style: AppTextStyles.bodyOpenSans.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (isSelected) ...[
                                          4.verticalSpace,
                                          Icon(Icons.check_circle, size: 16.sp, color: Theme.of(context).primaryColor),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    16.verticalSpace,
                    Center(child: Text('- OR -', style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey))),
                    16.verticalSpace,
                  ],
                 );
              }
              return const SizedBox.shrink();
            }),

            OutlinedButton.icon(
              onPressed: _pickResume,
              icon: const Icon(Icons.upload_file),
              label: Text(_resumeFile == null ? 'Upload New Resume' : 'New Resume Selected'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                side: BorderSide(
                  color: _resumeFile != null ? Theme.of(context).primaryColor : Colors.grey,
                  width: _resumeFile != null ? 2.0 : 1.0
                ),
              ),
            ),
            if (_resumeFile != null) ...[
              8.verticalSpace,
              Text(
                'Selected: ${_resumeFile!.path.split('/').last}',
                style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 12.sp, color: Colors.green),
              ),
            ],
            32.verticalSpace,

            Obx(() => CustomButton(
              title: "Submit Application",
              onPressed: _controller.isLoading.value ? () {} : _submitApplication,
              isLoading: _controller.isLoading.value,
            )),
          ],
        ),
      ),
    );
  }
}
