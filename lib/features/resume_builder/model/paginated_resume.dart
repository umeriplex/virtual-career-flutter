import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_resume.dart';

class PaginatedResumes {
  final List<UserResume> resumes;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PaginatedResumes({
    required this.resumes,
    this.lastDocument,
    required this.hasMore,
  });
}