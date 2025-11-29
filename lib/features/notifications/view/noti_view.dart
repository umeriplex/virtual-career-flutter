import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import '../controller/noti_controller.dart';
import '../model/notification_model.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with SingleTickerProviderStateMixin {
  final _controller = Get.find<NotificationController>();
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
        title: Text('Notifications',),
        actions: [
          // Mark all as read
          IconButton(
            onPressed: () => _controller.markAllAsRead(),
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
          ),
          // Delete all
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete All'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete_all') {
                _controller.deleteAllNotifications();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Obx(() => Tab(
              text: 'Unread (${_controller.unreadCount.value})',
            )),
            const Tab(text: 'All'),
          ],
          labelStyle: AppTextStyles.bodyOpenSans.copyWith(
            color: Colors.white,
          ),
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationsList(_controller.unreadNotifications, responsive),
            _buildNotificationsList(_controller.notifications, responsive),
          ],
        );
      }),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notificationList, Responsive responsive) {
    if (notificationList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64.sp, color: Colors.grey),
            16.verticalSpace,
            Text(
              'No notifications',
              style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => await _controller.fetchNotifications(),
      child: ListView.builder(
        padding: responsive.responsivePadding(8, 8, 8, 8),
        itemCount: notificationList.length,
        itemBuilder: (context, index) {
          final notification = notificationList[index];
          return _buildNotificationCard(notification, responsive);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, Responsive responsive) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
      ),
      onDismissed: (direction) {
        _controller.deleteNotification(notification.id);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        color: notification.isRead ? Colors.white : Colors.blue[50],
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              _controller.markAsRead(notification.id);
            }
            _handleNotificationTap(notification);
          },
          child: Padding(
            padding: responsive.responsivePadding(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24.sp,
                  ),
                ),
                12.horizontalSpace,
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.bodyOpenSans.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      4.verticalSpace,
                      Text(
                        notification.message,
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      8.verticalSpace,
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          fontSize: 11.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'job_application':
        return Icons.work;
      case 'job_status':
        return Icons.business_center;
      case 'connection':
        return Icons.person_add;
      case 'event_registration':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'job_application':
        return Colors.blue;
      case 'job_status':
        return Colors.green;
      case 'connection':
        return Colors.purple;
      case 'event_registration':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    switch (notification.type) {
      case 'job_application':
      case 'job_status':
        if (notification.referenceId != null) {
          // Navigate to job details
          // Get.toNamed(RouteNames.jobDetails, arguments: {'jobId': notification.referenceId});
        }
        break;
      case 'connection':
        if (notification.referenceId != null) {
          Get.toNamed(RouteNames.userProfile, arguments: {'userId': notification.referenceId});
        }
        break;
      case 'event_registration':
        if (notification.referenceId != null) {
          // Navigate to event details
          // Get.toNamed(RouteNames.eventDetails, arguments: {'eventId': notification.referenceId});
        }
        break;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }
}