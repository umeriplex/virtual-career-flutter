import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/theme/app_colors.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import '../controller/trending_jobs_controller.dart';
import '../model/job_market_model.dart';

class TrendingJobsView extends StatefulWidget {
  const TrendingJobsView({super.key});

  @override
  State<TrendingJobsView> createState() => _TrendingJobsViewState();
}

class _TrendingJobsViewState extends State<TrendingJobsView> {
  final _controller = Get.find<TrendingJobsController>();

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      body: Obx(() {
        if (_controller.isLoading.value && _controller.allJobs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(responsive),
            SliverToBoxAdapter(
              child: Padding(
                padding: responsive.responsivePadding(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatCards(responsive),
                    24.verticalSpace,
                    _buildTrendingJobs(responsive),
                    24.verticalSpace,
                    _buildInDemandSkills(responsive),
                    24.verticalSpace,
                    _buildJobTypeChart(responsive),
                    24.verticalSpace,
                    _buildCategoriesChart(responsive),
                    24.verticalSpace,
                    _buildExperienceChart(responsive),
                    24.verticalSpace,
                    _buildTopLocations(responsive),
                    32.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(Responsive responsive) {
    return SliverAppBar(
      expandedHeight: 140.h,
      floating: false,
      pinned: true,
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(RouteNames.jobSearch),
          icon: const Icon(Icons.search),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Job Market Trends',
          style: AppTextStyles.titleOpenSans.copyWith(
            color: Colors.white,
            fontSize: 18.sp,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30.r),
              bottomRight: Radius.circular(30.r),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20.w,
                bottom: -10.h,
                child: Icon(
                  Icons.trending_up,
                  size: 120.sp,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards(Responsive responsive) {
    final analytics = _controller.analytics.value;
    if (analytics == null) return const SizedBox.shrink();

    final stats = [
      _StatItem(Icons.work_outline, 'Total Jobs', '${_controller.totalJobs.value}', AppColor.primaryColor),
      _StatItem(Icons.code, 'Skills', '${analytics.topSkills.length}', Colors.green),
      _StatItem(Icons.location_on_outlined, 'Locations', '${analytics.topLocations.length}', Colors.orange),
      _StatItem(Icons.category_outlined, 'Categories', '${analytics.topCategories.length}', Colors.purple),
    ];

    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stats.length,
        separatorBuilder: (_, __) => 12.horizontalSpace,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Container(
            width: 140.w,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(stat.icon, color: stat.color, size: 24.sp),
                8.verticalSpace,
                Text(
                  stat.value,
                  style: AppTextStyles.headlineOpenSans.copyWith(
                    fontSize: 18.sp,
                    color: stat.color,
                  ),
                ),
                Text(
                  stat.label,
                  style: AppTextStyles.captionOpenSans.copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildTrendingJobs(Responsive responsive) {
    final analytics = _controller.analytics.value;
    if (analytics == null) return const SizedBox.shrink();

    final trending = analytics.trendingJobTitles.where((e) => e.name != 'NA').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange, size: 22.sp),
            8.horizontalSpace,
            Text(
              'Trending Jobs',
              style: AppTextStyles.subHeadlineOpenSans.copyWith(fontSize: 18.sp),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
        12.verticalSpace,
        SizedBox(
          height: 140.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trending.length,
            separatorBuilder: (_, __) => 12.horizontalSpace,
            itemBuilder: (context, index) {
              final job = trending[index];
              return InkWell(
                onTap: () {
                  _controller.searchJobs(job.name);
                  Get.toNamed(RouteNames.jobSearch);
                },
                child: Container(
                  width: 180.w,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.trending_up, color: AppColor.primaryColor, size: 20.sp),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyOpenSans.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                          4.verticalSpace,
                          Text(
                            '${job.count} openings',
                            style: AppTextStyles.captionOpenSans.copyWith(
                              color: AppColor.primaryColor,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: (index * 80).ms).slideX(begin: 0.3);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInDemandSkills(Responsive responsive) {
    final analytics = _controller.analytics.value;
    if (analytics == null) return const SizedBox.shrink();

    final skills = analytics.topSkills.take(20).toList();
    final maxCount = skills.isNotEmpty ? skills.first.count : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'In-Demand Skills',
          style: AppTextStyles.subHeadlineOpenSans.copyWith(fontSize: 18.sp),
        ).animate().fadeIn(duration: 400.ms),
        12.verticalSpace,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: skills.asMap().entries.map((entry) {
            final index = entry.key;
            final skill = entry.value;
            final tier = skill.count / maxCount;

            Color chipColor;
            if (tier > 0.6) {
              chipColor = AppColor.primaryColor;
            } else if (tier > 0.3) {
              chipColor = Colors.blue[300]!;
            } else {
              chipColor = Colors.blue[100]!;
            }

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: chipColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: chipColor.withOpacity(0.3)),
              ),
              child: Text(
                '${skill.name} (${skill.count})',
                style: AppTextStyles.captionOpenSans.copyWith(
                  color: tier > 0.3 ? AppColor.primaryColor : Colors.blue[700],
                  fontWeight: tier > 0.6 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11.sp,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms).scale(begin: const Offset(0.8, 0.8));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildJobTypeChart(Responsive responsive) {
    final analytics = _controller.analytics.value;
    if (analytics == null) return const SizedBox.shrink();

    final items = analytics.jobTypeDistribution.where((e) => e.name != 'NA').toList();
    final total = items.fold<int>(0, (sum, e) => sum + e.count);

    final colors = [
      AppColor.primaryColor,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Type Distribution',
          style: AppTextStyles.subHeadlineOpenSans.copyWith(fontSize: 18.sp),
        ).animate().fadeIn(duration: 400.ms),
        16.verticalSpace,
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 180.h,
                child: CustomPaint(
                  size: Size(180.w, 180.h),
                  painter: _DonutChartPainter(
                    items: items,
                    total: total,
                    colors: colors,
                  ),
                ),
              ),
              16.verticalSpace,
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final percentage = (item.count / total * 100).toStringAsFixed(1);
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTextStyles.captionOpenSans.copyWith(fontSize: 12.sp),
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: AppTextStyles.captionOpenSans.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideX(begin: 0.1);
              }),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildCategoriesChart(Responsive responsive) {
    final analytics = _controller.analytics.value;
    if (analytics == null) return const SizedBox.shrink();

    final categories = analytics.topCategories.where((e) => e.name != 'NA').toList();
    final maxCount = categories.isNotEmpty ? categories.first.count : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Industry Categories',
          style: AppTextStyles.subHeadlineOpenSans.copyWith(fontSize: 18.sp),
        ).animate().fadeIn(duration: 400.ms),
        16.verticalSpace,
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final ratio = category.count / maxCount;

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            category.name,
                            style: AppTextStyles.captionOpenSans.copyWith(
                              fontSize: 12.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          '${category.count}',
                          style: AppTextStyles.captionOpenSans.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    6.verticalSpace,
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: ratio),
                      duration: Duration(milliseconds: 800 + (index * 100)),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 8.h,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              AppColor.primaryColor.withOpacity(0.7 + (ratio * 0.3)),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (index * 80).ms);
            }).toList(),
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildExperienceChart(Responsive responsive) {
    final analytics = _controller.analytics.value;
    if (analytics == null) return const SizedBox.shrink();

    final items = analytics.experienceDistribution;
    final maxCount = items.fold<int>(0, (max, e) => e.count > max ? e.count : max);

    final colors = [Colors.blue[300]!, AppColor.primaryColor, Colors.blue[700]!, Colors.blue[900]!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience Distribution',
          style: AppTextStyles.subHeadlineOpenSans.copyWith(fontSize: 18.sp),
        ).animate().fadeIn(duration: 400.ms),
        16.verticalSpace,
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final ratio = maxCount > 0 ? item.count / maxCount : 0.0;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${item.count}',
                        style: AppTextStyles.captionOpenSans.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                          color: Colors.black87,
                        ),
                      ),
                      8.verticalSpace,
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ratio),
                        duration: Duration(milliseconds: 800 + (index * 150)),
                        curve: Curves.easeOut,
                        builder: (context, value, _) {
                          return Container(
                            height: (120 * value).h,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(8.r),
                              ),
                            ),
                          );
                        },
                      ),
                      8.verticalSpace,
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.captionOpenSans.copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildTopLocations(Responsive responsive) {
    final analytics = _controller.analytics.value;
    if (analytics == null) return const SizedBox.shrink();

    final locations = analytics.topLocations.where((e) => e.name != 'NA').toList();
    final maxCount = locations.isNotEmpty ? locations.first.count : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Locations',
          style: AppTextStyles.subHeadlineOpenSans.copyWith(fontSize: 18.sp),
        ).animate().fadeIn(duration: 400.ms),
        16.verticalSpace,
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: locations.asMap().entries.map((entry) {
              final index = entry.key;
              final location = entry.value;
              final ratio = location.count / maxCount;

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                    8.horizontalSpace,
                    SizedBox(
                      width: 80.w,
                      child: Text(
                        location.name,
                        style: AppTextStyles.captionOpenSans.copyWith(
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ratio),
                        duration: Duration(milliseconds: 800 + (index * 100)),
                        curve: Curves.easeOut,
                        builder: (context, value, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 12.h,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(
                                AppColor.primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    8.horizontalSpace,
                    Text(
                      '${location.count}',
                      style: AppTextStyles.captionOpenSans.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (index * 80).ms);
            }).toList(),
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
      ],
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _StatItem(this.icon, this.label, this.value, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final List<NameCountModel> items;
  final int total;
  final List<Color> colors;

  _DonutChartPainter({
    required this.items,
    required this.total,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 30.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -pi / 2;

    for (int i = 0; i < items.length; i++) {
      final sweepAngle = (items[i].count / total) * 2 * pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = colors[i % colors.length]
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$total',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
