import 'package:cloud_firestore/cloud_firestore.dart';

import 'resumer_model.dart';

class UserResume {
  String id;
  final String userId;
  final String pdfUrl;
  final String thumbnailUrl;
  final String title;
  final DateTime createdAt;
  final ResumeMetadata metaData;

  UserResume({
    this.id = '',
    required this.userId,
    required this.pdfUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.createdAt,
    required this.metaData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pdfUrl': pdfUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'createdAt': createdAt,
      'metaData': metaData.toJson(),
    };
  }

  factory UserResume.fromJson(Map<String, dynamic> json) {
    return UserResume(
      id: json['id'] as String,
      userId: json['userId'] as String,
      pdfUrl: json['pdfUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      title: json['title'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      metaData: ResumeMetadata.fromJson(json['metaData'] as Map<String, dynamic>),
    );
  }

  // For Firestore where createdAt is a server timestamp
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'pdfUrl': pdfUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'metaData': metaData.toJson(),
    };
  }
}

class ResumeMetadata {
  final int size;
  final int pages;
  final DateTime lastUpdated;
  final Resume resume;

  ResumeMetadata({
    required this.size,
    required this.pages,
    required this.lastUpdated,
    required this.resume,
  });

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'pages': pages,
      'lastUpdated': lastUpdated,
      'resume': resume.toJson(),
    };
  }

  factory ResumeMetadata.fromJson(Map<String, dynamic> json) {
    return ResumeMetadata(
      size: json['size'] as int,
      pages: json['pages'] as int,
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
      resume: Resume.fromJson(json['resume'] as Map<String, dynamic>),
    );
  }

  // For Firestore where lastUpdated is a server timestamp
  Map<String, dynamic> toFirestore() {
    return {
      'size': size,
      'pages': pages,
      'lastUpdated': FieldValue.serverTimestamp(),
      'resume': resume.toJson(),
    };
  }
}