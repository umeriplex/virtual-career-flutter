
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/components/custom_text_field.dart';
import 'package:virtual_career/core/components/custom_button.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/core/utils/toast_helper.dart';
import 'package:virtual_career/features/jobs/controller/job_controller.dart';
import 'package:virtual_career/features/jobs/model/job_model.dart';

class EditJobView extends StatefulWidget {
  const EditJobView({super.key});

  @override
  State<EditJobView> createState() => _EditJobViewState();
}

class _EditJobViewState extends State<EditJobView> {
  final _controller = Get.find<JobController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController jobTitleController;
  late TextEditingController companyController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController salaryController;
  final TextEditingController requirementController = TextEditingController();

  late String selectedJobType;
  late String selectedExperience;
  late List<String> requirements;
  late bool _isPublic;
  late bool _isActive;
  late String jobId;

  final List<String> jobTypes = ['Full-time', 'Part-time', 'Contract', 'Internship', 'Remote'];
  final List<String> experienceLevels = ['Entry Level', 'Mid Level', 'Senior Level', 'Executive'];

  @override
  void initState() {
    super.initState();
    final JobModel job = Get.arguments as JobModel;
    jobId = job.id;
    jobTitleController = TextEditingController(text: job.jobTitle);
    companyController = TextEditingController(text: job.company);
    descriptionController = TextEditingController(text: job.description);
    locationController = TextEditingController(text: job.location);
    salaryController = TextEditingController(text: job.salaryRange);
    
    selectedJobType = job.jobType;
    selectedExperience = job.experienceLevel;
    requirements = List.from(job.requirements);
    _isPublic = job.isPublic;
    _isActive = job.isActive;
  }

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

  Future<void> _handleUpdateJob() async {
    if (_formKey.currentState!.validate()) {
      if (requirements.isEmpty) {
        showErrorMessage("Please add at least one requirement");
        return;
      }

      await _controller.updateJob(
        jobId: jobId,
        jobTitle: jobTitleController.text,
        company: companyController.text,
        description: descriptionController.text,
        location: locationController.text,
        jobType: selectedJobType,
        experienceLevel: selectedExperience,
        salaryRange: salaryController.text.isEmpty ? null : salaryController.text,
        requirements: requirements,
        isPublic: _isPublic,
        isActive: _isActive,
      );

      Get.back();
      // Optional: Refresh details page if needed manually, but better if details page listens to controller or re-fetches
      // Since Details page received JobModel as arg, we might need to pass updated job back or details page should use stream/refresh
      // For now, simpler is to just go back, and the previous list might update.
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Job',),
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
              
              SwitchListTile(
                 title: Text('Active Status', style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.bold)),
                 subtitle: Text(_isActive ? 'Job is currently open' : 'Job is currently closed'),
                 value: _isActive,
                 activeColor: Theme.of(context).primaryColor,
                 onChanged: (bool value) {
                   setState(() {
                     _isActive = value;
                   });
                 },
              ),

              Obx(() {
                return CustomButton(
                  isLoading: _controller.isLoading.value,
                  title: "Update Job",
                  onPressed: _handleUpdateJob,
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
