import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import '../../connections/controller/connection_controller.dart';
import '../../auth/model/user_model.dart';
import '../../jobs/controller/job_controller.dart';
import '../../events/controller/event_controller.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> with SingleTickerProviderStateMixin {
  final ConnectionController _connectionController = Get.find<ConnectionController>();
  final JobController _jobController = Get.find<JobController>();
  final EventController _eventController = Get.find<EventController>();

  late String userId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final args = Get.arguments as Map<String, dynamic>;
    userId = args['userId'] as String;

    // Load data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    await _connectionController.getUserById(userId);
    if (_connectionController.selectedUser.value != null) {
      await _connectionController.isConnectedWith(userId);
    }
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
        title: const Text('Profile'),
      ),
      body: Obx(() {
        final user = _connectionController.selectedUser.value;
        final isLoading = _connectionController.isLoading.value;
        final isConnected = _connectionController.isConnected.value;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (user == null) {
          return _buildErrorView(responsive);
        }

        return Column(
          children: [
            // Profile Header
            _buildProfileHeader(responsive, user, isConnected),
            // Content Section
            Expanded(
              child: isConnected
                  ? _buildConnectedContent(responsive)
                  : _buildNotConnectedView(responsive),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProfileHeader(Responsive responsive, UserModel user, bool isConnected) {
    return Container(
      padding: responsive.responsivePadding(16, 16, 16, 16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 50.r,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Text(
              user.fullName[0].toUpperCase(),
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          12.verticalSpace,
          // Name
          Text(
            user.fullName,
            style: AppTextStyles.bodyOpenSans.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          8.verticalSpace,
          // Bio
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          16.verticalSpace,
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Connections', user.connections.length.toString()),
              Container(width: 1, height: 30.h, color: Colors.grey),
              _buildStatItem('Followers', user.followers.length.toString()),
            ],
          ),
          16.verticalSpace,
          // Connect Button
          SizedBox(
            width: double.infinity,
            child: isConnected
                ? OutlinedButton.icon(
              onPressed: () async {
                await _connectionController.disconnectFromUser(userId);
              },
              icon: const Icon(Icons.person_remove),
              label: const Text('Disconnect'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            )
                : ElevatedButton.icon(
              onPressed: () async {
                await _connectionController.connectWithUser(userId);
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Connect'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedContent(Responsive responsive) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Jobs'),
            Tab(text: 'Events'),
          ],
          labelStyle: AppTextStyles.bodyOpenSans,
          indicatorColor: Colors.black26,
          unselectedLabelColor: Colors.black26,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildJobsList(responsive),
              _buildEventsList(responsive),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobsList(Responsive responsive) {
    return Obx(() {
      final userJobs = _jobController.connectionsJobs
          .where((job) => job.creatorId == userId)
          .toList();

      if (userJobs.isEmpty) {
        return _buildEmptyState(
          icon: Icons.work_off,
          message: 'No jobs posted yet',
        );
      }

      return ListView.builder(
        padding: responsive.responsivePadding(16, 16, 16, 16),
        itemCount: userJobs.length,
        itemBuilder: (context, index) {
          final job = userJobs[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            child: InkWell(
              onTap: () => Get.toNamed(
                RouteNames.jobDetails,
                arguments: {'job': job, 'isMyJob': false},
              ),
              child: Padding(
                padding: responsive.responsivePadding(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      style: AppTextStyles.bodyOpenSans.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
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
                        Icon(Icons.location_on, size: 14.sp, color: Colors.grey),
                        4.horizontalSpace,
                        Text(
                          job.location,
                          style: AppTextStyles.bodyOpenSans.copyWith(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildEventsList(Responsive responsive) {
    return Obx(() {
      final userEvents = _eventController.connectionsEvents
          .where((event) => event.creatorId == userId)
          .toList();

      if (userEvents.isEmpty) {
        return _buildEmptyState(
          icon: Icons.event_busy,
          message: 'No events posted yet',
        );
      }

      return ListView.builder(
        padding: responsive.responsivePadding(16, 16, 16, 16),
        itemCount: userEvents.length,
        itemBuilder: (context, index) {
          final event = userEvents[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            child: InkWell(
              onTap: () => Get.toNamed(
                RouteNames.eventDetails,
                arguments: {'event': event, 'isMyEvent': false},
              ),
              child: Padding(
                padding: responsive.responsivePadding(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventTitle,
                      style: AppTextStyles.bodyOpenSans.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    8.verticalSpace,
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
                        4.horizontalSpace,
                        Text(
                          event.eventDate.toString().split(' ')[0],
                          style: AppTextStyles.bodyOpenSans.copyWith(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyOpenSans.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        4.verticalSpace,
        Text(
          label,
          style: AppTextStyles.bodyOpenSans.copyWith(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildNotConnectedView(Responsive responsive) {
    return Center(
      child: Padding(
        padding: responsive.responsivePadding(32, 32, 32, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64.sp, color: Colors.grey),
            16.verticalSpace,
            Text(
              'Connect to view profile',
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            8.verticalSpace,
            Text(
              'You need to connect with this user to see their jobs and events',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(Responsive responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
          16.verticalSpace,
          Text(
            'User not found',
            style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.sp, color: Colors.grey),
          16.verticalSpace,
          Text(
            message,
            style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}