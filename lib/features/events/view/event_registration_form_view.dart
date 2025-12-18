
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/features/events/controller/event_controller.dart';
import 'package:virtual_career/features/events/model/event_model.dart';
import 'package:virtual_career/features/auth/controller/auth_controller.dart';
import 'package:virtual_career/core/components/custom_button.dart';
import 'package:virtual_career/core/components/custom_text_field.dart';

class EventRegistrationFormView extends StatefulWidget {
  const EventRegistrationFormView({super.key});

  @override
  State<EventRegistrationFormView> createState() => _EventRegistrationFormViewState();
}

class _EventRegistrationFormViewState extends State<EventRegistrationFormView> {
  final _controller = Get.find<EventController>();
  final _authController = Get.find<AuthController>();
  final _notesController = TextEditingController();
  late EventModel event;

  @override
  void initState() {
    super.initState();
    event = Get.arguments as EventModel;
  }

  Future<void> _submitRegistration() async {
    if (_authController.user == null) return;

    await _controller.registerForEvent(
      eventId: event.id,
      userId: _authController.user!.id,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    Get.back(result: true);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Register for Event'),
      ),
      body: SingleChildScrollView(
        padding: responsive.responsivePadding(16, 16, 16, 16),
        child: Column(
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
                fontSize: 20.sp,
              ),
            ),
            8.verticalSpace,
             Text(
              'Date: ${event.eventDate.toString().split(' ')[0]}', // Simple formatting
               style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
            ),
            24.verticalSpace,

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
            
            32.verticalSpace,

             Obx(() => CustomButton(
              title: "Register",
              onPressed: _controller.isLoading.value ? (){} : _submitRegistration,
              isLoading: _controller.isLoading.value,
            )),
          ],
        ),
      ),
    );
  }
}
