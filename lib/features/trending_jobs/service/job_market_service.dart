import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/job_market_model.dart';

class JobMarketService {
  List<JobMarketModel>? _cachedJobs;
  JobAnalyticsModel? _cachedAnalytics;
  int? _cachedTotalJobs;

  Future<void> _loadData() async {
    if (_cachedJobs != null) return;

    final jsonString = await rootBundle.loadString('assets/job_data_json.json');
    final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;

    _cachedTotalJobs = (data['meta'] as Map<String, dynamic>?)?['total_jobs'] ?? 0;

    _cachedAnalytics = JobAnalyticsModel.fromJson(
      data['analytics'] as Map<String, dynamic>? ?? {},
    );

    _cachedJobs = (data['jobs'] as List? ?? [])
        .map((e) => JobMarketModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<JobMarketModel>> getJobs() async {
    await _loadData();
    return _cachedJobs!;
  }

  Future<JobAnalyticsModel> getAnalytics() async {
    await _loadData();
    return _cachedAnalytics!;
  }

  Future<int> getTotalJobs() async {
    await _loadData();
    return _cachedTotalJobs!;
  }
}
