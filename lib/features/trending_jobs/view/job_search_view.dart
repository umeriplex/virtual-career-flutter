import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:virtual_career/core/theme/app_colors.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import '../controller/trending_jobs_controller.dart';
import '../model/job_market_model.dart';

class JobSearchView extends StatefulWidget {
  const JobSearchView({super.key});

  @override
  State<JobSearchView> createState() => _JobSearchViewState();
}

class _JobSearchViewState extends State<JobSearchView> {
  final _controller = Get.find<TrendingJobsController>();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    if (_controller.searchQuery.value.isNotEmpty) {
      _searchController.text = _controller.searchQuery.value;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Jobs'),
      ),
      body: Column(
        children: [
          _buildSearchBar(responsive),
          _buildFilterChips(responsive),
          _buildResultCount(),
          Expanded(child: _buildResults(responsive)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Responsive responsive) {
    return Padding(
      padding: responsive.responsivePadding(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: (value) => _controller.searchJobs(value),
        decoration: InputDecoration(
          hintText: 'Search by title, company, skill, location...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _controller.searchJobs('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  Widget _buildFilterChips(Responsive responsive) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Type filters
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: responsive.responsivePadding(16, 0, 16, 0),
              children: [
                _buildFilterLabel('Type:'),
                ..._controller.jobTypeFilters.take(6).map((type) {
                  final isSelected = _controller.selectedJobType.value == type;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: FilterChip(
                      label: Text(
                        type,
                        style: AppTextStyles.captionOpenSans.copyWith(
                          fontSize: 11.sp,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => _controller.setJobTypeFilter(type),
                      selectedColor: AppColor.primaryColor,
                      backgroundColor: Colors.grey[100],
                      checkmarkColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                    ),
                  );
                }),
              ],
            ),
          ),
          4.verticalSpace,
          // Location filters
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: responsive.responsivePadding(16, 0, 16, 0),
              children: [
                _buildFilterLabel('Location:'),
                ..._controller.locationFilters.map((location) {
                  final isSelected = _controller.selectedLocation.value == location;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: FilterChip(
                      label: Text(
                        location,
                        style: AppTextStyles.captionOpenSans.copyWith(
                          fontSize: 11.sp,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => _controller.setLocationFilter(location),
                      selectedColor: AppColor.primaryColor,
                      backgroundColor: Colors.grey[100],
                      checkmarkColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                    ),
                  );
                }),
              ],
            ),
          ),
          4.verticalSpace,
          // Experience filters
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: responsive.responsivePadding(16, 0, 16, 0),
              children: [
                _buildFilterLabel('Experience:'),
                ..._controller.experienceFilters.map((exp) {
                  final isSelected = _controller.selectedExperience.value == exp;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: FilterChip(
                      label: Text(
                        exp,
                        style: AppTextStyles.captionOpenSans.copyWith(
                          fontSize: 11.sp,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => _controller.setExperienceFilter(exp),
                      selectedColor: AppColor.primaryColor,
                      backgroundColor: Colors.grey[100],
                      checkmarkColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                    ),
                  );
                }),
              ],
            ),
          ),
          8.verticalSpace,
        ],
      );
    });
  }

  Widget _buildFilterLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.captionOpenSans.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCount() {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing ${_controller.filteredJobs.length} of ${_controller.totalJobs.value} jobs',
              style: AppTextStyles.captionOpenSans.copyWith(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            if (_controller.searchQuery.value.isNotEmpty ||
                _controller.selectedJobType.value.isNotEmpty ||
                _controller.selectedLocation.value.isNotEmpty ||
                _controller.selectedExperience.value.isNotEmpty)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _controller.clearFilters();
                },
                child: Text(
                  'Clear all',
                  style: AppTextStyles.captionOpenSans.copyWith(
                    fontSize: 12.sp,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildResults(Responsive responsive) {
    return Obx(() {
      if (_controller.isSearching.value) {
        return _buildShimmerList();
      }

      if (_controller.filteredJobs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
              16.verticalSpace,
              Text(
                'No jobs found',
                style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
              ),
              8.verticalSpace,
              Text(
                'Try adjusting your search or filters',
                style: AppTextStyles.captionOpenSans.copyWith(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: responsive.responsivePadding(16, 8, 16, 16),
        itemCount: _controller.filteredJobs.length,
        itemBuilder: (context, index) {
          final job = _controller.filteredJobs[index];
          return _buildJobCard(job, responsive, index);
        },
      );
    });
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobCard(JobMarketModel job, Responsive responsive, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () => Get.toNamed(
          RouteNames.jobMarketDetail,
          arguments: {'job': job},
        ),
        child: Padding(
          padding: responsive.responsivePadding(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: AppTextStyles.bodyOpenSans.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: job.source == 'rozee_pk'
                          ? Colors.green[50]
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      job.sourceLabel,
                      style: AppTextStyles.captionOpenSans.copyWith(
                        fontSize: 10.sp,
                        color: job.source == 'rozee_pk'
                            ? Colors.green
                            : AppColor.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (job.company != null) ...[
                4.verticalSpace,
                Text(
                  job.company!,
                  style: AppTextStyles.captionOpenSans.copyWith(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              8.verticalSpace,
              Row(
                children: [
                  Icon(Icons.location_on, size: 14.sp, color: Colors.grey),
                  4.horizontalSpace,
                  Expanded(
                    child: Text(
                      job.location,
                      style: AppTextStyles.captionOpenSans.copyWith(fontSize: 11.sp),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      job.jobType,
                      style: AppTextStyles.captionOpenSans.copyWith(
                        fontSize: 10.sp,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                  if (job.salary != null) ...[
                    8.horizontalSpace,
                    Text(
                      job.salary!.formatted,
                      style: AppTextStyles.captionOpenSans.copyWith(
                        fontSize: 10.sp,
                        color: AppColor.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              if (job.skills.isNotEmpty) ...[
                8.verticalSpace,
                Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: job.skills.take(4).map((skill) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        skill,
                        style: AppTextStyles.captionOpenSans.copyWith(
                          fontSize: 10.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index.clamp(0, 10) * 50).ms);
  }
}
