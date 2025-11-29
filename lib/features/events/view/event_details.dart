import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_career/core/components/custom_text_field.dart';
import 'package:virtual_career/core/theme/app_colors.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import '../controller/event_controller.dart';
import '../model/event_model.dart';
import '../../auth/controller/auth_controller.dart';

class EventDetailsView extends StatefulWidget {
  const EventDetailsView({super.key});

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  final _controller = Get.find<EventController>();
  final _authController = Get.find<AuthController>();
  late EventModel event;
  late bool isMyEvent;
  final _notesController = TextEditingController();
  bool _isRegistered = false;
  bool _isCheckingRegistration = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    event = args['event'] as EventModel;
    isMyEvent = args['isMyEvent'] as bool;


    if (!isMyEvent) {
      _checkIfRegistered();
    }
  }

  Future<void> _checkIfRegistered() async {
    if (_authController.user == null) return;

    final registered = await _controller.isUserRegistered(
      eventId: event.id,
      userId: _authController.user!.id,
    );

    print("ISSSs: ${registered}");

    setState(() {
      _isRegistered = registered;
      _isCheckingRegistration = false;
    });
  }

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register for Event', style: AppTextStyles.headlineOpenSans),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to register for:',
              style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 14.sp),
            ),
            8.verticalSpace,
            Text(
              event.eventTitle,
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            16.verticalSpace,
            Text(
              'Add Notes (Optional)',
              style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
            ),
            8.verticalSpace,
            CustomTextField(
              controller: _notesController,
              maxLines: 3,
              hintText: 'Any special requirements or notes...',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              if (_authController.user == null) return;

              await _controller.registerForEvent(
                eventId: event.id,
                userId: _authController.user!.id,
                notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              );

              setState(() {
                _isRegistered = true;
              });
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  void _showRegistrationsDialog() {
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
                  Text('Registrations', style: AppTextStyles.headlineOpenSans),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              16.verticalSpace,
              Expanded(
                child: FutureBuilder(
                  future: _controller.getEventRegistrations(event.id),
                  builder: (context, snapshot) {
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchMeetingLink() async {
    if (event.meetingLink == null) return;

    final uri = Uri.parse(event.meetingLink!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not open meeting link');
    }
  }

  bool get isEventPast => event.eventDate.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details',),
        actions: isMyEvent
            ? [
          // IconButton(
          //   onPressed: () {
          //     // Navigate to edit event page
          //   },
          //   icon: const Icon(Icons.edit),
          // ),
          IconButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Delete Event'),
                  content: const Text('Are you sure you want to delete this event?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _controller.deleteEvent(event.id);
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
        ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: responsive.responsivePadding(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title
            Text(
              event.eventTitle,
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            16.verticalSpace,

            // Event Type Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                event.eventType,
                style: AppTextStyles.bodyOpenSans.copyWith(
                  fontSize: 12.sp,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            24.verticalSpace,

            // Event Info
            _buildInfoCard(
              Icons.calendar_today,
              'Date',
              DateFormat('EEEE, MMMM dd, yyyy').format(event.eventDate),
            ),
            12.verticalSpace,

            if (event.eventTime != null)
              _buildInfoCard(Icons.access_time, 'Time', event.eventTime!),
            12.verticalSpace,

            _buildInfoCard(Icons.location_on, 'Location', event.location),

            if (event.meetingLink != null) ...[
              12.verticalSpace,
              InkWell(
                onTap: _launchMeetingLink,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.video_call, color: Colors.green, size: 24.sp),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meeting Link',
                              style: AppTextStyles.bodyOpenSans.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            4.verticalSpace,
                            Text(
                              'Click to join',
                              style: AppTextStyles.bodyOpenSans.copyWith(
                                fontSize: 12.sp,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.green, size: 16.sp),
                    ],
                  ),
                ),
              ),
            ],

            if (event.maxAttendees > 0) ...[
              12.verticalSpace,
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people, size: 24.sp, color: Colors.orange),
                    12.horizontalSpace,
                    Text(
                      '${event.registeredCount} / ${event.maxAttendees} registered',
                      style: AppTextStyles.bodyOpenSans.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (isMyEvent) ...[
              12.verticalSpace,
              _buildInfoCard(Icons.people, 'Total Registrations', '${event.registeredCount}'),
            ],

            if (isEventPast) ...[
              16.verticalSpace,
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.red, size: 24.sp),
                    12.horizontalSpace,
                    Expanded(
                      child: Text(
                        'This event has passed',
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            24.verticalSpace,
            Divider(height: 1.h),
            24.verticalSpace,

            // Description
            Text(
              'About This Event',
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            12.verticalSpace,
            Text(
              event.description,
              style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 14.sp),
            ),

            32.verticalSpace,
          ],
        ),
      ),
      bottomNavigationBar: isMyEvent ?
      Container(
        padding: responsive.responsivePadding(16, 16, 16, MediaQuery.of(context).padding.bottom),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _showRegistrationsDialog,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: AppColor.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'View Registrations (${event.registeredCount})',
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
                  _controller.updateEvent(
                    eventId: event.id,
                    isActive: !event.isActive,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  event.isActive ? 'Close Event' : 'Reopen Event',
                  style: AppTextStyles.bodyOpenSans.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ) :
      _isCheckingRegistration ?
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
            onPressed: _isRegistered || isEventPast || !event.isActive ? null : _showRegistrationDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              _isRegistered
                  ? 'Already Registered'
                  : isEventPast
                  ? 'Event Ended'
                  : !event.isActive
                  ? 'Event Closed'
                  : 'Register Now',
              style: AppTextStyles.bodyOpenSans.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: Colors.grey[700]),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyOpenSans.copyWith(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                4.verticalSpace,
                Text(
                  value,
                  style: AppTextStyles.bodyOpenSans.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}