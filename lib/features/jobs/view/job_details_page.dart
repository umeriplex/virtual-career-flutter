import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:virtual_career/core/theme/app_colors.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import '../controller/job_controller.dart';
import '../model/job_model.dart';
import '../../auth/controller/auth_controller.dart';

class JobDetailsView extends StatefulWidget {
  const JobDetailsView({super.key});

  @override
  State<JobDetailsView> createState() => _JobDetailsViewState();
}

class _JobDetailsViewState extends State<JobDetailsView> {
  final _controller = Get.find<JobController>();
  final _authController = Get.find<AuthController>();
  late JobModel job;
  late bool isMyJob;
  final _coverLetterController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _resumeFile;
  bool _hasApplied = false;
  bool _isCheckingApplication = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    job = args['job'] as JobModel;
    isMyJob = args['isMyJob'] as bool;

    if (!isMyJob) {
      _checkIfApplied();
    }
  }

  Future<void> _checkIfApplied() async {
    final applied = await _controller.hasApplied(job.id);
    setState(() {
      _hasApplied = applied;
      _isCheckingApplication = false;
    });
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
      });
    }
  }

  void _showApplicationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply for Job', style: AppTextStyles.headlineOpenSans),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cover Letter *', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold)),
              8.verticalSpace,
              TextFormField(
                controller: _coverLetterController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write your cover letter...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              16.verticalSpace,
              Text('Phone Number', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold)),
              8.verticalSpace,
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              16.verticalSpace,
              Text('Resume (PDF)', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold)),
              8.verticalSpace,
              OutlinedButton.icon(
                onPressed: _pickResume,
                icon: const Icon(Icons.upload_file),
                label: Text(_resumeFile == null ? 'Upload Resume' : 'Resume Selected'),
              ),
              if (_resumeFile != null) ...[
                8.verticalSpace,
                Text(
                  _resumeFile!.path.split('/').last,
                  style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 12.sp, color: Colors.green),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_coverLetterController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please write a cover letter');
                return;
              }

              Get.back();
              final success = await _controller.applyForJob(
                jobId: job.id,
                coverLetter: _coverLetterController.text.trim(),
                phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                resumeFile: _resumeFile,
              );

              if (success) {
                setState(() {
                  _hasApplied = true;
                });
              }
            },
            child: const Text('Submit Application'),
          ),
        ],
      ),
    );
  }

  void _showApplicationsDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.8,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Applications', style: AppTextStyles.headlineOpenSans),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              16.verticalSpace,
              Expanded(
                child: FutureBuilder(
                  future: _controller.fetchJobApplications(job.id),
                  builder: (context, snapshot) {
                    return Obx(() {
                      if (_controller.jobApplications.isEmpty) {
                        return Center(
                          child: Text(
                            'No applications yet',
                            style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: _controller.jobApplications.length,
                        itemBuilder: (context, index) {
                          final application = _controller.jobApplications[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12.h),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Applicant ID: ${application.applicantId.substring(0, 8)}...',
                                        style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(application.status),
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          application.status,
                                          style: AppTextStyles.bodyOpenSans.copyWith(
                                            color: Colors.white,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  8.verticalSpace,
                                  Text(
                                    'Applied: ${DateFormat('MMM dd, yyyy').format(application.appliedDate)}',
                                    style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 12.sp, color: Colors.grey),
                                  ),
                                  if (application.phone != null) ...[
                                    8.verticalSpace,
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 16.sp, color: Colors.grey),
                                        4.horizontalSpace,
                                        Text(application.phone!, style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 12.sp)),
                                      ],
                                    ),
                                  ],
                                  12.verticalSpace,
                                  Text('Cover Letter:', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold)),
                                  4.verticalSpace,
                                  Text(application.coverLetter, style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 12.sp)),
                                  if (application.resumeUrl != null) ...[
                                    12.verticalSpace,
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        // Open resume URL
                                      },
                                      icon: const Icon(Icons.file_download),
                                      label: const Text('View Resume'),
                                    ),
                                  ],
                                  12.verticalSpace,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            _controller.updateApplicationStatus(
                                              applicationId: application.id,
                                              status: 'Accepted',
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.green,
                                            side: const BorderSide(color: Colors.green),
                                          ),
                                          child: const Text('Accept'),
                                        ),
                                      ),
                                      8.horizontalSpace,
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            _controller.updateApplicationStatus(
                                              applicationId: application.id,
                                              status: 'Rejected',
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(color: Colors.red),
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details',),
        actions: isMyJob ?
        [
          // IconButton(
          //   onPressed: () {
          //     // Navigate to edit job page
          //   },
          //   icon: const Icon(Icons.edit),
          // ),
          IconButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Delete Job'),
                  content: const Text('Are you sure you want to delete this job?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _controller.deleteJob(job.id);
                        Get.back();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete),
          ),
        ] :
        null,
      ),
      body: SingleChildScrollView(
        padding: responsive.responsivePadding(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title and Company
            Text(
              job.jobTitle,
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            8.verticalSpace,
            Text(
              job.company,
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontSize: 18.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
            16.verticalSpace,

            // Job Info Cards
            _buildInfoRow(Icons.location_on, job.location),
            8.verticalSpace,
            _buildInfoRow(Icons.work, job.jobType),
            8.verticalSpace,
            _buildInfoRow(Icons.business_center, job.experienceLevel),
            if (job.salaryRange != null) ...[
              8.verticalSpace,
              _buildInfoRow(Icons.attach_money, job.salaryRange!),
            ],
            8.verticalSpace,
            _buildInfoRow(Icons.calendar_today, DateFormat('MMM dd, yyyy').format(job.dateCreated)),

            if (isMyJob) ...[
              8.verticalSpace,
              _buildInfoRow(Icons.people, '${job.applicantsCount} applicants'),
            ],

            24.verticalSpace,
            Divider(height: 1.h),
            24.verticalSpace,

            // Description
            Text(
              'Job Description',
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            12.verticalSpace,
            Text(
              job.description,
              style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 14.sp),
            ),

            if (job.requirements.isNotEmpty) ...[
              24.verticalSpace,
              Text(
                'Requirements',
                style: AppTextStyles.bodyOpenSans.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              12.verticalSpace,
              ...job.requirements.map((req) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 20.sp, color: Colors.green),
                    8.horizontalSpace,
                    Expanded(
                      child: Text(
                        req,
                        style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              )),
            ],

            32.verticalSpace,
          ],
        ),
      ),
      bottomNavigationBar: isMyJob ?
      Container(
        padding: responsive.responsivePadding(16, 16, 16, MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _showApplicationsDialog,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  backgroundColor: AppColor.buttonColor,
                ),
                child: Text(
                  'View Applications (${job.applicantsCount})',
                  style: AppTextStyles.bodyOpenSans.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            16.horizontalSpace,
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _controller.updateJob(
                    jobId: job.id,
                    isActive: !job.isActive,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  job.isActive ? 'Close Job' : 'Reopen Job',
                  style: AppTextStyles.bodyOpenSans.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ) :
      _isCheckingApplication ?
      const SizedBox.shrink() :
      Container(
        padding: responsive.responsivePadding(16, 16, 16, MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: _hasApplied || !job.isActive ? null : _showApplicationDialog,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              backgroundColor: AppColor.buttonColor,
            ),
            child: Text(
              _hasApplied
                  ? 'Already Applied'
                  : !job.isActive
                  ? 'Job Closed'
                  : 'Apply Now',
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: Colors.grey),
        8.horizontalSpace,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}