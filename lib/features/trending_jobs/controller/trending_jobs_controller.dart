import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/job_market_model.dart';
import '../service/job_market_service.dart';

class TrendingJobsController extends GetxController {
  final JobMarketService _service;

  TrendingJobsController(this._service);

  final RxBool isLoading = false.obs;
  final RxList<JobMarketModel> allJobs = <JobMarketModel>[].obs;
  final RxList<JobMarketModel> filteredJobs = <JobMarketModel>[].obs;
  final Rx<JobAnalyticsModel?> analytics = Rx<JobAnalyticsModel?>(null);
  final RxInt totalJobs = 0.obs;

  // Search & Filter state
  final RxString searchQuery = ''.obs;
  final RxString selectedJobType = ''.obs;
  final RxString selectedLocation = ''.obs;
  final RxString selectedExperience = ''.obs;
  final RxBool isSearching = false.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading(true);
      final results = await Future.wait([
        _service.getJobs(),
        _service.getAnalytics(),
        _service.getTotalJobs(),
      ]);

      allJobs.value = results[0] as List<JobMarketModel>;
      analytics.value = results[1] as JobAnalyticsModel;
      totalJobs.value = results[2] as int;
      filteredJobs.value = allJobs;
    } catch (e) {
      debugPrint('Error loading job market data: $e');
    } finally {
      isLoading(false);
    }
  }

  void searchJobs(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  void setJobTypeFilter(String type) {
    selectedJobType.value = selectedJobType.value == type ? '' : type;
    _applyFilters();
  }

  void setLocationFilter(String location) {
    selectedLocation.value = selectedLocation.value == location ? '' : location;
    _applyFilters();
  }

  void setExperienceFilter(String experience) {
    selectedExperience.value = selectedExperience.value == experience ? '' : experience;
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedJobType.value = '';
    selectedLocation.value = '';
    selectedExperience.value = '';
    filteredJobs.value = allJobs;
  }

  void _applyFilters() {
    isSearching(true);

    List<JobMarketModel> results = allJobs.toList();

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      results = results.where((job) {
        return job.title.toLowerCase().contains(query) ||
            job.location.toLowerCase().contains(query) ||
            job.category.toLowerCase().contains(query) ||
            (job.company?.toLowerCase().contains(query) ?? false) ||
            job.skills.any((s) => s.toLowerCase().contains(query));
      }).toList();
    }

    if (selectedJobType.value.isNotEmpty) {
      results = results.where((job) => job.jobType == selectedJobType.value).toList();
    }

    if (selectedLocation.value.isNotEmpty) {
      results = results.where((job) =>
          job.location.toLowerCase().contains(selectedLocation.value.toLowerCase()),
      ).toList();
    }

    if (selectedExperience.value.isNotEmpty) {
      results = results.where((job) {
        if (job.experienceYears == null) return false;
        switch (selectedExperience.value) {
          case '0-1 years':
            return job.experienceYears! <= 1;
          case '2-3 years':
            return job.experienceYears! >= 2 && job.experienceYears! <= 3;
          case '4-6 years':
            return job.experienceYears! >= 4 && job.experienceYears! <= 6;
          case '7+ years':
            return job.experienceYears! >= 7;
          default:
            return true;
        }
      }).toList();
    }

    filteredJobs.value = results;
    isSearching(false);
  }

  List<String> get jobTypeFilters {
    final types = analytics.value?.jobTypeDistribution
        .where((e) => e.name != 'NA')
        .map((e) => e.name)
        .toList() ?? [];
    return types;
  }

  List<String> get locationFilters {
    final locations = analytics.value?.topLocations
        .where((e) => e.name != 'NA')
        .take(8)
        .map((e) => e.name)
        .toList() ?? [];
    return locations;
  }

  List<String> get experienceFilters {
    return analytics.value?.experienceDistribution
        .map((e) => e.name)
        .toList() ?? [];
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
