import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/theme/app_colors.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/features/jobs/controller/job_controller.dart';
import 'package:virtual_career/config/routes/route_name.dart';

class JobsListView extends StatefulWidget {
  const JobsListView({super.key});

  @override
  State<JobsListView> createState() => _JobsListViewState();
}

class _JobsListViewState extends State<JobsListView> with SingleTickerProviderStateMixin {
  final _controller = Get.find<JobController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs Management',),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Available Jobs',
            ),
            Tab(text: 'My Jobs'),
          ],
          labelStyle: AppTextStyles.bodyOpenSans.copyWith(
            color: Colors.white,
          ),
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'createJobFab',
        onPressed: () => Get.toNamed(RouteNames.createJob),
        child: const Icon(Icons.add, color: Colors.white,),
        backgroundColor: AppColor.buttonColor,
        shape: CircleBorder(
          side: BorderSide(color: AppColor.buttonColor, width: 2.w),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConnectionsJobs(responsive),
          _buildMyJobs(responsive),
        ],
      ),
    );
  }

  Widget _buildConnectionsJobs(Responsive responsive) {
    return Obx(() {
      if (_controller.isLoading.value && _controller.connectionsJobs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.connectionsJobs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off, size: 64.sp, color: Colors.grey),
              16.verticalSpace,
              Text(
                'No jobs available',
                style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
              ),
              8.verticalSpace,
              Text(
                'Connect with people to see their jobs',
                style: AppTextStyles.bodyOpenSans.copyWith(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await _controller.fetchConnectionsJobs(),
        child: ListView.builder(
          padding: responsive.responsivePadding(16, 16, 16, 16),
          itemCount: _controller.connectionsJobs.length,
          itemBuilder: (context, index) {
            final job = _controller.connectionsJobs[index];
            return _buildJobCard(job, responsive, isMyJob: false);
          },
        ),
      );
    });
  }

  Widget _buildMyJobs(Responsive responsive) {
    return Obx(() {
      if (_controller.isLoading.value && _controller.myJobs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.myJobs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off, size: 64.sp, color: Colors.grey),
              16.verticalSpace,
              Text(
                'No jobs created yet',
                style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
              ),
              8.verticalSpace,
              Text(
                'Create jobs to see them listed here',
                style: AppTextStyles.bodyOpenSans.copyWith(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await _controller.fetchMyJobs(),
        child: ListView.builder(
          padding: responsive.responsivePadding(16, 16, 16, 16),
          itemCount: _controller.myJobs.length,
          itemBuilder: (context, index) {
            final job = _controller.myJobs[index];
            return _buildJobCard(job, responsive, isMyJob: true);
          },
        ),
      );
    });
  }

  Widget _buildJobCard(dynamic job, Responsive responsive, {required bool isMyJob}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.black12)
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          RouteNames.jobDetails,
          arguments: {'job': job, 'isMyJob': isMyJob},
        ),
        child: Padding(
          padding: responsive.responsivePadding(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.jobTitle,
                      style: AppTextStyles.bodyOpenSans.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  if (isMyJob)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: job.isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        job.isActive ? 'Active' : 'Closed',
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
              4.verticalSpace,
              Text(
                job.company,
                style: AppTextStyles.bodyOpenSans.copyWith(
                  fontSize: 14.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              8.verticalSpace,
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                  4.horizontalSpace,
                  Text(
                    job.location,
                    style: AppTextStyles.bodyOpenSans.copyWith(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  16.horizontalSpace,
                  Icon(Icons.work, size: 16.sp, color: Colors.grey),
                  4.horizontalSpace,
                  Text(
                    job.jobType,
                    style: AppTextStyles.bodyOpenSans.copyWith(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              if (isMyJob) ...[
                8.verticalSpace,
                Row(
                  children: [
                    Icon(Icons.people, size: 16.sp, color: Colors.grey),
                    4.horizontalSpace,
                    Text(
                      '${job.applicantsCount} applicants',
                      style: AppTextStyles.bodyOpenSans.copyWith(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                 8.verticalSpace,
                 InkWell(
                   onTap: () {
                     // Navigate to creator profile
                     Get.toNamed(RouteNames.userProfile, arguments: {'userId': job.creatorId});
                   },
                   child: Row(
                     children: [
                       CircleAvatar(
                         radius: 12.r,
                         backgroundImage: job.creatorImage != null && job.creatorImage!.isNotEmpty
                             ? NetworkImage(job.creatorImage!)
                             : null,
                         child: job.creatorImage == null || job.creatorImage!.isEmpty
                             ? Icon(Icons.person, size: 16.sp, color: Colors.white)
                             : null,
                       ),
                       8.horizontalSpace,
                       Text(
                         'Created by: ${job.creatorName ?? "Unknown User"}',
                          style: AppTextStyles.bodyOpenSans.copyWith(
                           fontSize: 12.sp,
                           color: Theme.of(context).primaryColor,
                           decoration: TextDecoration.underline,
                         ),
                       ),
                     ],
                   ),
                 ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}