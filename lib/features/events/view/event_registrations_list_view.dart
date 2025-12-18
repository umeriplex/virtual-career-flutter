
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/features/events/controller/event_controller.dart';

class EventRegistrationsListView extends StatefulWidget {
  const EventRegistrationsListView({super.key});

  @override
  State<EventRegistrationsListView> createState() => _EventRegistrationsListViewState();
}

class _EventRegistrationsListViewState extends State<EventRegistrationsListView> {
  final _controller = Get.find<EventController>();
  late String eventId;

  @override
  void initState() {
    super.initState();
    eventId = Get.arguments as String;
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrations'),
      ),
      body: FutureBuilder(
        future: _controller.getEventRegistrations(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error fetching registrations"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No registrations yet',
                style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
              ),
            );
          }

          final registrations = snapshot.data!;
          return ListView.builder(
            padding: responsive.responsivePadding(16, 16, 16, 16),
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final registration = registrations[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ID: ${registration.userId.substring(0, 8)}...',
                        style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
                      ),
                      8.verticalSpace,
                      Text(
                        'Registered: ${DateFormat('MMM dd, yyyy').format(registration.registeredDate)}',
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      if (registration.notes != null && registration.notes!.isNotEmpty) ...[
                        12.verticalSpace,
                        Text(
                          'Notes:',
                          style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
                        ),
                        4.verticalSpace,
                        Text(
                          registration.notes!,
                          style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 12.sp),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
