
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/features/jobs/controller/job_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicationsListView extends StatefulWidget {
  const JobApplicationsListView({super.key});

  @override
  State<JobApplicationsListView> createState() => _JobApplicationsListViewState();
}

class _JobApplicationsListViewState extends State<JobApplicationsListView> {
  final _controller = Get.find<JobController>();
  late String jobId;

  @override
  void initState() {
    super.initState();
    jobId = Get.arguments as String;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchApplications();
    });
  }

  Future<void> _fetchApplications() async {
    await _controller.fetchJobApplications(jobId);
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
        title: Text('Applications'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.jobApplications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.jobApplications.isEmpty) {
          return Center(
            child: Text(
              'No applications yet',
              style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: responsive.responsivePadding(16, 16, 16, 16),
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
                          'New Application',
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
                    if (application.resumeUrl != null && application.resumeUrl!.isNotEmpty) ...[
                      12.verticalSpace,
                      OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(application.resumeUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
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
      }),
    );
  }
}
