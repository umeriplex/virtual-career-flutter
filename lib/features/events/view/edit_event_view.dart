
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:virtual_career/core/components/custom_button.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import '../../../core/components/custom_text_field.dart';
import '../controller/event_controller.dart';
import '../model/event_model.dart';

class EditEventView extends StatefulWidget {
  const EditEventView({super.key});

  @override
  State<EditEventView> createState() => _EditEventViewState();
}

class _EditEventViewState extends State<EditEventView> {
  final EventController _controller = Get.find<EventController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _eventTitleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _eventTimeController;
  late TextEditingController _meetingLinkController;
  late TextEditingController _maxAttendeesController;
  
  late bool _isPublic;
  late bool _isActive;
  late String _eventId;

  String? _selectedEventType;
  DateTime? _selectedDate;
  final List<String> _eventTypes = [
    'Workshop', 'Seminar', 'Conference', 'Networking', 
    'Training', 'Webinar', 'Social', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    final EventModel event = Get.arguments as EventModel;
    _eventId = event.id;
    
    _eventTitleController = TextEditingController(text: event.eventTitle);
    _descriptionController = TextEditingController(text: event.description);
    _locationController = TextEditingController(text: event.location);
    _eventTimeController = TextEditingController(text: event.eventTime);
    _meetingLinkController = TextEditingController(text: event.meetingLink);
    _maxAttendeesController = TextEditingController(text: event.maxAttendees == 0 ? '' : event.maxAttendees.toString());
    
    _selectedEventType = event.eventType;
    _selectedDate = event.eventDate;
    _isPublic = event.isPublic;
    _isActive = event.isActive;
  }

  @override
  void dispose() {
    _eventTitleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _eventTimeController.dispose();
    _meetingLinkController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _eventTimeController.text = picked.format(context);
      });
    }
  }

  void _updateEvent() {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedEventType != null) {
      _controller.updateEvent(
        eventId: _eventId,
        eventTitle: _eventTitleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        eventType: _selectedEventType!,
        eventDate: _selectedDate!,
        eventTime: _eventTimeController.text.trim().isEmpty ? null : _eventTimeController.text.trim(),
        meetingLink: _meetingLinkController.text.trim().isEmpty ? null : _meetingLinkController.text.trim(),
        maxAttendees: _maxAttendeesController.text.trim().isEmpty ? 0 : int.parse(_maxAttendeesController.text.trim()),
        isPublic: _isPublic,
        isActive: _isActive,
      );
      
      Get.back(); // Go back to details or list
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event',),
        actions: [
          Obx(() => _controller.isLoading.value
              ? Padding(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : const SizedBox()),
        ],
      ),
      body: SingleChildScrollView(
        padding: responsive.responsivePadding(16, 16, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Title
              Text(
                'Event Title *',
                style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
              ),
              8.verticalSpace,
              CustomTextField(
                controller: _eventTitleController,
                hintText: 'Enter event title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              16.verticalSpace,

              // Description
              Text(
                'Description *',
                style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
              ),
              8.verticalSpace,
              CustomTextField(
                hintText: 'Enter event description',
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                },
              ),
              16.verticalSpace,

              // Event Type
              Text(
                'Event Type *',
                style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
              ),
              8.verticalSpace,
              DropdownButtonFormField<String>(
                value: _selectedEventType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r),borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  hintText: 'Select event type',
                ),
                items: _eventTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEventType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select event type';
                  }
                  return null;
                },
              ),
              16.verticalSpace,

              // Date and Time
              Row(
                children: [
                  // Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Date *',
                          style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
                        ),
                        8.verticalSpace,
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20.sp, color: Colors.grey),
                                8.horizontalSpace,
                                Text(
                                  _selectedDate == null
                                      ? 'Select date'
                                      : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                                  style: AppTextStyles.bodyOpenSans.copyWith(
                                    color: _selectedDate == null ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.horizontalSpace,

                  // Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Time',
                          style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
                        ),
                        8.verticalSpace,
                        TextFormField(
                          controller: _eventTimeController,
                          readOnly: true,
                          onTap: _selectTime,
                          decoration: InputDecoration(
                            hintText: 'Select time',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r),borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            suffixIcon: Icon(Icons.access_time, size: 20.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              16.verticalSpace,

              // Location
              Text(
                'Location *',
                style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
              ),
              8.verticalSpace,
              CustomTextField(
                controller: _locationController,
                hintText: 'Enter event location',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event location';
                  }
                  return null;
                },
              ),
              16.verticalSpace,

              // Meeting Link (Optional)
              Text(
                'Meeting Link',
                style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
              ),
              8.verticalSpace,
              CustomTextField(
                controller: _meetingLinkController,
                hintText: 'Enter meeting link (Zoom, Google Meet, etc.)',
              ),
              16.verticalSpace,

              // Max Attendees (Optional)
              Text(
                'Maximum Attendees',
                style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold),
              ),
              8.verticalSpace,
              CustomTextField(
                controller: _maxAttendeesController,
                keyboardType: TextInputType.number,
                hintText: 'Enter maximum number of attendees (0 for unlimited)',
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Public', style: AppTextStyles.bodyOpenSans),
                      value: true,
                      activeColor: Theme.of(context).primaryColor,
                      groupValue: _isPublic,
                      onChanged: (bool? value) {
                        setState(() {
                          _isPublic = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Private', style: AppTextStyles.bodyOpenSans),
                      value: false,
                      groupValue: _isPublic,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? value) {
                        setState(() {
                          _isPublic = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SwitchListTile(
                title: Text('Active Status', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(_isActive ? 'Event is active' : 'Event is cancelled/closed'),
                value: _isActive,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (bool value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),

              // Create Button
              12.h.verticalSpace,
              CustomButton(
                title: "Update Event",
                onPressed: _controller.isLoading.value ? (){} : _updateEvent,
                isLoading: _controller.isLoading.value,
                isSecondButton: true,
              ),
              MediaQuery.of(context).padding.bottom.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
