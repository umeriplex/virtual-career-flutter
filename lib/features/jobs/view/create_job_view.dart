import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/components/custom_text_field.dart';
import 'package:virtual_career/core/components/custom_button.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/core/utils/toast_helper.dart';
import 'package:virtual_career/features/jobs/controller/job_controller.dart';

class CreateJobView extends StatefulWidget {
  const CreateJobView({super.key});

  @override
  State<CreateJobView> createState() => _CreateJobViewState();
}

class _CreateJobViewState extends State<CreateJobView> {
  final _controller = Get.find<JobController>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController requirementController = TextEditingController();

  String selectedJobType = 'Full-time';
  String selectedExperience = 'Entry Level';
  List<String> requirements = [];
  bool _isPublic = true;

  final List<String> jobTypes = ['Full-time', 'Part-time', 'Contract', 'Internship', 'Remote'];
  final List<String> experienceLevels = ['Entry Level', 'Mid Level', 'Senior Level', 'Executive'];

  @override
  void dispose() {
    jobTitleController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    salaryController.dispose();
    requirementController.dispose();
    super.dispose();
  }

  void _addRequirement() {
    if (requirementController.text.isNotEmpty) {
      setState(() {
        requirements.add(requirementController.text);
        requirementController.clear();
      });
    }
  }

  void _removeRequirement(int index) {
    setState(() {
      requirements.removeAt(index);
    });
  }

  Future<void> _handleCreateJob() async {
    if (_formKey.currentState!.validate()) {
      if (requirements.isEmpty) {
        showErrorMessage("Please add at least one requirement");
        return;
      }

      await _controller.createJob(
        jobTitle: jobTitleController.text,
        company: companyController.text,
        description: descriptionController.text,
        location: locationController.text,
        jobType: selectedJobType,
        experienceLevel: selectedExperience,
        salaryRange: salaryController.text.isEmpty ? null : salaryController.text,
        requirements: requirements,
        isPublic: _isPublic,
      );

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Job',),
      ),
      body: SingleChildScrollView(
        padding: responsive.responsivePadding(16, 16, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Job Title', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600)),
              4.verticalSpace,
              CustomTextField(
                controller: jobTitleController,
                hintText: "e.g. Senior Flutter Developer",
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              16.verticalSpace,

              Text('Company', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600)),
              4.verticalSpace,
              CustomTextField(
                controller: companyController,
                hintText: "e.g. Tech Solutions Inc.",
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              16.verticalSpace,

              Text('Location', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600)),
              4.verticalSpace,
              CustomTextField(
                controller: locationController,
                hintText: "e.g. New York, USA",
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              16.verticalSpace,

              Text('Job Type', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600)),
              4.verticalSpace,
              DropdownButtonFormField<String>(
                value: selectedJobType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r),borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                items: jobTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => selectedJobType = value!),
              ),
              16.verticalSpace,

              Text('Experience Level', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600)),
              4.verticalSpace,
              DropdownButtonFormField<String>(
                value: selectedExperience,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r),borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                items: experienceLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                onChanged: (value) => setState(() => selectedExperience = value!),
              ),
              16.verticalSpace,

              Text('Salary Range (Optional)', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600)),
              4.verticalSpace,
              CustomTextField(
                controller: salaryController,
                hintText: "e.g. \$80,000 - \$120,000",
              ),
              16.verticalSpace,

              Text('Description', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600)),
              4.verticalSpace,
              CustomTextField(
                controller: descriptionController,
                hintText: "Describe the job role and responsibilities",
                maxLines: 5,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              16.verticalSpace,

              Text('Requirements', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600)),
              4.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: requirementController,
                      hintText: "Add a requirement",
                    ),
                  ),
                  8.horizontalSpace,
                  IconButton(
                    onPressed: _addRequirement,
                    icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 32.sp),
                  ),
                ],
              ),
              8.verticalSpace,
              if (requirements.isNotEmpty)
                ...requirements.asMap().entries.map((entry) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '• ${entry.value}',
                            style: AppTextStyles.bodyOpenSans,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeRequirement(entry.key),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              12.verticalSpace,

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

              Obx(() {
                return CustomButton(
                  isLoading: _controller.isLoading.value,
                  title: "Create Job",
                  onPressed: _handleCreateJob,
                );
              }),
              MediaQuery.of(context).padding.bottom.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}