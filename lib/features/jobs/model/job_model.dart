class JobModel {
  final String id;
  final String creatorId;
  final String jobTitle;
  final String company;
  final String description;
  final String location;
  final String jobType; // Full-time, Part-time, Contract, etc.
  final String experienceLevel; // Entry, Mid, Senior
  final String? salaryRange;
  final List<String> requirements;
  final DateTime dateCreated;
  final bool isActive;
  final int applicantsCount;
  final bool isPublic;

  JobModel({
    required this.id,
    required this.creatorId,
    required this.jobTitle,
    required this.company,
    required this.description,
    required this.location,
    required this.jobType,
    required this.experienceLevel,
    this.salaryRange,
    this.requirements = const [],
    required this.dateCreated,
    this.isActive = true,
    this.isPublic = true,
    this.applicantsCount = 0,
  });

  factory JobModel.fromJson(Map<String, dynamic> json, String id) {
    return JobModel(
      id: id,
      creatorId: json['creatorId'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      company: json['company'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      jobType: json['jobType'] ?? '',
      experienceLevel: json['experienceLevel'] ?? '',
      salaryRange: json['salaryRange'],
      requirements: List<String>.from(json['requirements'] ?? []),
      dateCreated: DateTime.parse(json['dateCreated']),
      isActive: json['isActive'] ?? true,
      applicantsCount: json['applicantsCount'] ?? 0,
      isPublic: json['isPublic'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creatorId': creatorId,
      'jobTitle': jobTitle,
      'company': company,
      'description': description,
      'location': location,
      'jobType': jobType,
      'experienceLevel': experienceLevel,
      'salaryRange': salaryRange,
      'requirements': requirements,
      'dateCreated': dateCreated.toIso8601String(),
      'isActive': isActive,
      'applicantsCount': applicantsCount,
      'isPublic': isPublic,
    };
  }

  JobModel copyWith({
    String? id,
    String? creatorId,
    String? jobTitle,
    String? company,
    String? description,
    String? location,
    String? jobType,
    String? experienceLevel,
    String? salaryRange,
    List<String>? requirements,
    DateTime? dateCreated,
    bool? isActive,
    bool? isPublic,
    int? applicantsCount,
  }) {
    return JobModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      description: description ?? this.description,
      location: location ?? this.location,
      jobType: jobType ?? this.jobType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      salaryRange: salaryRange ?? this.salaryRange,
      requirements: requirements ?? this.requirements,
      dateCreated: dateCreated ?? this.dateCreated,
      isActive: isActive ?? this.isActive,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}