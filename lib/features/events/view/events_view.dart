import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import 'package:intl/intl.dart';
import 'package:virtual_career/generated/assets.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/event_controller.dart';
import '../model/event_model.dart';

class EventsListView extends StatefulWidget {
  const EventsListView({super.key});

  @override
  State<EventsListView> createState() => _EventsListViewState();
}

class _EventsListViewState extends State<EventsListView> with SingleTickerProviderStateMixin {
  final EventController _controller = Get.find<EventController>();
  late TabController _tabController;
  final List<String> _eventTypes = [
    'Workshop',
    'Seminar',
    'Conference',
    'Networking',
    'Training',
    'Webinar',
    'Social',
    'Other'
  ];


  String _getImageForEventType(String eventType) {
    switch (eventType) {
      case 'Workshop':
        return Assets.imagesWorkshop;
      case 'Seminar':
        return Assets.imagesSeminar;
      case 'Conference':
        return Assets.imagesConference;
      case 'Networking':
        return Assets.imagesNetworkingg;
      case 'Training':
        return Assets.imagesTraining;
      case 'Webinar':
        return Assets.imagesWebinar;
      case 'Social':
        return Assets.imagesSociall;
      default:
        return Assets.imagesEventt;
    }
  }


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
        title: Text('Events',),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available Events'),
            Tab(text: 'My Events'),
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
        heroTag: 'createEventFab',
        onPressed: () => Get.toNamed(RouteNames.createEvent),
        child: const Icon(Icons.add, color: Colors.white,),
        backgroundColor: AppColor.buttonColor,
        shape: CircleBorder(
          side: BorderSide(color: AppColor.buttonColor, width: 2.w),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConnectionsEvents(responsive),
          _buildMyEvents(responsive),
        ],
      ),
    );
  }

  Widget _buildConnectionsEvents(Responsive responsive) {
    return Obx(() {
      if (_controller.isLoading.value && _controller.connectionsEvents.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.connectionsEvents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64.sp, color: Colors.grey),
              16.verticalSpace,
              Text(
                'No events available',
                style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
              ),
              8.verticalSpace,
              Text(
                'Connect with people to see their events',
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
        onRefresh: () async => await _controller.fetchConnectionsEvents(),
        child: ListView.builder(
          padding: responsive.responsivePadding(16, 16, 16, 16),
          itemCount: _controller.connectionsEvents.length,
          itemBuilder: (context, index) {
            final event = _controller.connectionsEvents[index];
            return _buildEventCard(event, responsive, isMyEvent: false);
          },
        ),
      );
    });
  }

  Widget _buildMyEvents(Responsive responsive) {
    return Obx(() {
      if (_controller.isLoading.value && _controller.myEvents.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.myEvents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64.sp, color: Colors.grey),
              16.verticalSpace,
              Text(
                'No events created yet',
                style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
              ),
              8.verticalSpace,
              Text(
                'Create events to engage with your connections',
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
        onRefresh: () async => await _controller.fetchMyEvents(),
        child: ListView.builder(
          padding: responsive.responsivePadding(16, 16, 16, 16),
          itemCount: _controller.myEvents.length,
          itemBuilder: (context, index) {
            final event = _controller.myEvents[index];
            return _buildEventCard(event, responsive, isMyEvent: true);
          },
        ),
      );
    });
  }

  Widget _buildEventCard(EventModel event, Responsive responsive, {required bool isMyEvent}) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isPastEvent = event.eventDate.isBefore(DateTime.now());

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.black12)
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          RouteNames.eventDetails,
          arguments: {'event': event, 'isMyEvent': isMyEvent},
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    _getImageForEventType(event.eventType),
                    width: double.infinity,
                    height: 150.h,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: responsive.responsivePadding(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.eventTitle,
                          style: AppTextStyles.bodyOpenSans.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      if (isMyEvent)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: event.isActive ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            event.isActive ? 'Active' : 'Inactive',
                            style: AppTextStyles.bodyOpenSans.copyWith(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                  8.verticalSpace,
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
                      4.horizontalSpace,
                      Text(
                        dateFormat.format(event.eventDate),
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          fontSize: 12.sp,
                          color: isPastEvent ? Colors.red : Colors.grey,
                        ),
                      ),
                      if (event.eventTime != null) ...[
                        8.horizontalSpace,
                        Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
                        4.horizontalSpace,
                        Text(
                          event.eventTime!,
                          style: AppTextStyles.bodyOpenSans.copyWith(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  8.verticalSpace,
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                      4.horizontalSpace,
                      Expanded(
                        child: Text(
                          event.location,
                          style: AppTextStyles.bodyOpenSans.copyWith(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.verticalSpace,
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          event.eventType,
                          style: AppTextStyles.bodyOpenSans.copyWith(
                            fontSize: 11.sp,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.people, size: 16.sp, color: Colors.grey),
                      4.horizontalSpace,
                      Text(
                        '${event.registeredCount} registered',
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (isPastEvent) ...[
                    8.verticalSpace,
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 16.sp, color: Colors.red),
                          8.horizontalSpace,
                          Text(
                            'This event has passed',
                            style: AppTextStyles.bodyOpenSans.copyWith(
                              fontSize: 12.sp,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}