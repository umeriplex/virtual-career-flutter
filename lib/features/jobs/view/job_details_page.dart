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
import 'package:virtual_career/config/routes/route_name.dart';

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



  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details',),
        actions: isMyJob ?
        [
          IconButton(
            onPressed: () {
              Get.toNamed(RouteNames.editJob, arguments: job);
            },
            icon: const Icon(Icons.edit),
          ),
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
                onPressed: () {
                  Get.toNamed(RouteNames.jobApplicationsList, arguments: job.id);
                },
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
            onPressed: _hasApplied || !job.isActive ? null : () async {
              final result = await Get.toNamed(RouteNames.jobApplication, arguments: job.id);
              if (result == true) {
                setState(() {
                  _hasApplied = true;
                });
              }
            },
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