import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:virtual_career/core/theme/app_colors.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import '../model/job_market_model.dart';

class JobMarketDetailView extends StatefulWidget {
  const JobMarketDetailView({super.key});

  @override
  State<JobMarketDetailView> createState() => _JobMarketDetailViewState();
}

class _JobMarketDetailViewState extends State<JobMarketDetailView>
    with TickerProviderStateMixin {
  late JobMarketModel job;
  late AnimationController _salaryAnimController;
  late Animation<double> _salaryAnim;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    job = args['job'] as JobMarketModel;

    _salaryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _salaryAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _salaryAnimController, curve: Curves.easeOut),
    );
    _salaryAnimController.forward();
  }

  @override
  void dispose() {
    _salaryAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: SingleChildScrollView(
        padding: responsive.responsivePadding(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Source Badge
            _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            16.verticalSpace,

            // Info Row
            _buildInfoRow().animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),
            16.verticalSpace,

            // Salary Card
            if (job.salary != null)
              _buildSalaryCard().animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
            if (job.salary != null) 16.verticalSpace,

            // Details Section
            _buildDetailsSection(responsive).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1),
            16.verticalSpace,

            // Skills
            if (job.skills.isNotEmpty)
              _buildSkillsSection().animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1),
            if (job.skills.isNotEmpty) 16.verticalSpace,

            // Category Badge
            _buildCategoryBadge().animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                job.title,
                style: AppTextStyles.headlineOpenSans.copyWith(
                  fontSize: 22.sp,
                ),
              ),
            ),
            8.horizontalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: job.source == 'rozee_pk' ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: job.source == 'rozee_pk' ? Colors.green : AppColor.primaryColor,
                ),
              ),
              child: Text(
                job.sourceLabel,
                style: AppTextStyles.captionOpenSans.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: job.source == 'rozee_pk' ? Colors.green : AppColor.primaryColor,
                ),
              ),
            ),
          ],
        ),
        if (job.company != null) ...[
          8.verticalSpace,
          Row(
            children: [
              Icon(Icons.business, size: 16.sp, color: Colors.grey),
              6.horizontalSpace,
              Text(
                job.company!,
                style: AppTextStyles.bodyOpenSans.copyWith(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        _buildInfoChip(Icons.work_outline, job.jobType, AppColor.primaryColor),
        8.horizontalSpace,
        if (job.experienceYears != null)
          _buildInfoChip(Icons.timeline, '${job.experienceYears} yrs exp', Colors.orange),
        if (job.experienceYears != null) 8.horizontalSpace,
        if (job.careerLevel != null)
          Expanded(
            child: _buildInfoChip(Icons.stairs, job.careerLevel!, Colors.purple),
          ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          4.horizontalSpace,
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.captionOpenSans.copyWith(
                fontSize: 11.sp,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryCard() {
    final salary = job.salary!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColor.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monetization_on, color: AppColor.green, size: 22.sp),
              8.horizontalSpace,
              Text(
                'Salary',
                style: AppTextStyles.bodyOpenSans.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.green,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          AnimatedBuilder(
            animation: _salaryAnim,
            builder: (context, _) {
              final minVal = (salary.min * _salaryAnim.value).toInt();
              final maxVal = (salary.max * _salaryAnim.value).toInt();
              final formatter = NumberFormat('#,###');
              return Text(
                '${salary.currency} ${formatter.format(minVal)} - ${formatter.format(maxVal)}',
                style: AppTextStyles.headlineOpenSans.copyWith(
                  fontSize: 22.sp,
                  color: AppColor.green,
                ),
              );
            },
          ),
          4.verticalSpace,
          Text(
            'per ${salary.period}',
            style: AppTextStyles.captionOpenSans.copyWith(
              color: AppColor.green.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(Responsive responsive) {
    final details = <_DetailItem>[
      _DetailItem(Icons.location_on, 'Location', job.location),
      if (job.company != null) _DetailItem(Icons.business, 'Company', job.company!),
      if (job.postedDate != null) _DetailItem(Icons.calendar_today, 'Posted Date', job.postedDate!),
      if (job.deadline != null) _DetailItem(Icons.event, 'Deadline', job.deadline!),
      if (job.education != null) _DetailItem(Icons.school, 'Education', job.education!),
      if (job.gender != null && job.gender != 'NA') _DetailItem(Icons.person, 'Gender', job.gender!),
      if (job.experienceYears != null) _DetailItem(Icons.timeline, 'Experience', '${job.experienceYears} years'),
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Details',
            style: AppTextStyles.subHeadlineOpenSans.copyWith(fontSize: 16.sp),
          ),
          12.verticalSpace,
          ...details.asMap().entries.map((entry) {
            final index = entry.key;
            final detail = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Icon(detail.icon, size: 20.sp, color: Colors.grey[600]),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.label,
                          style: AppTextStyles.captionOpenSans.copyWith(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                        ),
                        2.verticalSpace,
                        Text(
                          detail.value,
                          style: AppTextStyles.bodyOpenSans.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms, delay: (index * 60).ms);
          }),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Skills',
            style: AppTextStyles.subHeadlineOpenSans.copyWith(fontSize: 16.sp),
          ),
          12.verticalSpace,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: job.skills.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  skill,
                  style: AppTextStyles.captionOpenSans.copyWith(
                    fontSize: 12.sp,
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms, delay: (index * 40).ms).scale(begin: const Offset(0.8, 0.8));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(Icons.category, size: 20.sp, color: AppColor.primaryColor),
          12.horizontalSpace,
          Text(
            'Category: ',
            style: AppTextStyles.bodyOpenSans.copyWith(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                job.category,
                style: AppTextStyles.bodyOpenSans.copyWith(
                  fontSize: 13.sp,
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;

  _DetailItem(this.icon, this.label, this.value);
}
