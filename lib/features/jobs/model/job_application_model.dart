class JobApplicationModel {
  final String id;
  final String jobId;
  final String applicantId;
  final String coverLetter;
  final String? resumeUrl;
  final String? phone;
  final DateTime appliedDate;
  final String status; // pending, reviewed, accepted, rejected

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.coverLetter,
    this.resumeUrl,
    this.phone,
    required this.appliedDate,
    this.status = 'pending',
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json, String id) {
    return JobApplicationModel(
      id: id,
      jobId: json['jobId'] ?? '',
      applicantId: json['applicantId'] ?? '',
      coverLetter: json['coverLetter'] ?? '',
      resumeUrl: json['resumeUrl'],
      phone: json['phone'],
      appliedDate: DateTime.parse(json['appliedDate']),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'applicantId': applicantId,
      'coverLetter': coverLetter,
      'resumeUrl': resumeUrl,
      'phone': phone,
      'appliedDate': appliedDate.toIso8601String(),
      'status': status,
    };
  }

  JobApplicationModel copyWith({
    String? id,
    String? jobId,
    String? applicantId,
    String? coverLetter,
    String? resumeUrl,
    String? phone,
    DateTime? appliedDate,
    String? status,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      applicantId: applicantId ?? this.applicantId,
      coverLetter: coverLetter ?? this.coverLetter,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      phone: phone ?? this.phone,
      appliedDate: appliedDate ?? this.appliedDate,
      status: status ?? this.status,
    );
  }
}