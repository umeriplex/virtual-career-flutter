class SalaryModel {
  final String currency;
  final int min;
  final int max;
  final String period;

  SalaryModel({
    required this.currency,
    required this.min,
    required this.max,
    required this.period,
  });

  factory SalaryModel.fromJson(Map<String, dynamic> json) {
    return SalaryModel(
      currency: json['currency'] ?? 'PKR',
      min: json['min'] ?? 0,
      max: json['max'] ?? 0,
      period: json['period'] ?? 'month',
    );
  }

  String get formatted {
    final minK = min >= 1000 ? '${(min / 1000).toStringAsFixed(0)}K' : '$min';
    final maxK = max >= 1000 ? '${(max / 1000).toStringAsFixed(0)}K' : '$max';
    return '$currency $minK - $maxK / $period';
  }
}

class JobMarketModel {
  final String id;
  final String source;
  final String title;
  final String? company;
  final String location;
  final String jobType;
  final String category;
  final SalaryModel? salary;
  final int? experienceYears;
  final String? postedDate;
  final String? deadline;
  final List<String> skills;
  final String? careerLevel;
  final String? education;
  final String? gender;

  JobMarketModel({
    required this.id,
    required this.source,
    required this.title,
    this.company,
    required this.location,
    required this.jobType,
    required this.category,
    this.salary,
    this.experienceYears,
    this.postedDate,
    this.deadline,
    required this.skills,
    this.careerLevel,
    this.education,
    this.gender,
  });

  factory JobMarketModel.fromJson(Map<String, dynamic> json) {
    return JobMarketModel(
      id: json['id'] ?? '',
      source: json['source'] ?? '',
      title: json['title'] ?? '',
      company: json['company'],
      location: json['location'] ?? '',
      jobType: json['job_type'] ?? '',
      category: json['category'] ?? '',
      salary: json['salary'] != null
          ? SalaryModel.fromJson(json['salary'] as Map<String, dynamic>)
          : null,
      experienceYears: json['experience_years'],
      postedDate: json['posted_date'],
      deadline: json['deadline'],
      skills: List<String>.from(json['skills'] ?? []),
      careerLevel: json['career_level'],
      education: json['education'],
      gender: json['gender'],
    );
  }

  String get sourceLabel => source == 'rozee_pk' ? 'Rozee.pk' : 'International';
}

class NameCountModel {
  final String name;
  final int count;

  NameCountModel({required this.name, required this.count});

  factory NameCountModel.fromJson(Map<String, dynamic> json) {
    return NameCountModel(
      name: json['name'] ?? json['range'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class JobAnalyticsModel {
  final int totalJobs;
  final List<NameCountModel> topSkills;
  final List<NameCountModel> topCategories;
  final List<NameCountModel> jobTypeDistribution;
  final List<NameCountModel> topLocations;
  final List<NameCountModel> trendingJobTitles;
  final List<NameCountModel> careerLevelDistribution;
  final List<NameCountModel> experienceDistribution;

  JobAnalyticsModel({
    required this.totalJobs,
    required this.topSkills,
    required this.topCategories,
    required this.jobTypeDistribution,
    required this.topLocations,
    required this.trendingJobTitles,
    required this.careerLevelDistribution,
    required this.experienceDistribution,
  });

  factory JobAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return JobAnalyticsModel(
      totalJobs: json['total_jobs'] ?? 0,
      topSkills: (json['top_skills'] as List? ?? [])
          .map((e) => NameCountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topCategories: (json['top_categories'] as List? ?? [])
          .map((e) => NameCountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      jobTypeDistribution: (json['job_type_distribution'] as List? ?? [])
          .map((e) => NameCountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topLocations: (json['top_locations'] as List? ?? [])
          .map((e) => NameCountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      trendingJobTitles: (json['trending_job_titles'] as List? ?? [])
          .map((e) => NameCountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      careerLevelDistribution: (json['career_level_distribution'] as List? ?? [])
          .map((e) => NameCountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      experienceDistribution: (json['experience_distribution'] as List? ?? [])
          .map((e) => NameCountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
