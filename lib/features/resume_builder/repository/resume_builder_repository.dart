import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:virtual_career/core/constant/app_constants.dart';
import 'package:image/image.dart' as img;
import '../../../config/exception/firebase_error_handler.dart';
import '../../../config/exception/firebase_exception_handler.dart';
import '../../../core/utils/app_response.dart';
import '../model/paginated_resume.dart';
import '../model/resumer_model.dart';
import '../model/user_resume.dart';


class ResumeBuilderRepository{
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  ResumeBuilderRepository(this._firestore, this._storage);

  Future<String> _uploadPdfFile(File pdfFile, String userId) async {
    final fileName = p.basename(pdfFile.path);
    final destination = 'users/$userId/pdfs/$fileName';

    try {
      final ref = _storage.ref(destination);
      await ref.putFile(pdfFile);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _uploadThumbnail(File thumbnailFile, String userId) async {
    final fileName = p.basename(thumbnailFile.path);
    final destination = 'users/$userId/thumbnails/$fileName';

    try {
      final ref = _storage.ref(destination);
      await ref.putFile(thumbnailFile);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }


  Future<int> _estimatePageCount(File pdfFile) async {
    final fileSize = await pdfFile.length();
    return (fileSize / 50000).ceil();
  }

  Future<AppResponse<void>> uploadUserResume({
    required String userId,
    required File pdfFile,
    required File thumbnailFile,
    required String title,
    required Resume resume,
  }) async {
    try {
      // 1. Upload PDF to Storage
      final pdfUrl = await _uploadPdfFile(pdfFile, userId);

      // 2. Generate thumbnail (using Firebase Extension)
      final thumbnailUrl = await _uploadThumbnail(thumbnailFile, userId);

      // 3. Create resume document
      final userResume = UserResume(
        userId: userId,
        pdfUrl: pdfUrl,
        thumbnailUrl: thumbnailUrl,
        title: title,
        createdAt: DateTime.now(), // Will be replaced by server timestamp
        metaData: ResumeMetadata(
          size: await pdfFile.length(),
          pages: await _estimatePageCount(pdfFile),
          lastUpdated: DateTime.now(), // Will be replaced by server timestamp
          resume: resume,
        ),
      );

      // Generate resume ID
      final resumeId = _firestore.collection('pdfs').doc().id;
      userResume.id = resumeId;

      // 4. Batch write for atomic operation
      final batch = _firestore.batch();
      final resumeRef = _firestore.collection('pdfs').doc(resumeId);

      // Add to pdfs collection
      batch.set(resumeRef, userResume.toJson());

      // Add reference to user document
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'resumes': FieldValue.arrayUnion([resumeRef.id])
      });

      await batch.commit();
      return AppResponse(
        message: 'Resume uploaded successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: FirebaseErrorHandler.getErrorMessage(e),
        success: false,
        statusCode: 400,
      );
    }
  }



  Stream<List<UserResume>> getUserResumesStream(String userId) {
    return _firestore
        .collection('pdfs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
      debugPrint('Firestore error: $error');
      return const Stream.empty(); // Keep stream alive on errors
    })
        .map((snapshot) => snapshot.docs
        .map((doc) => UserResume.fromJson(doc.data())..id = doc.id)
        .toList());
  }

  Future<AppResponse<List<UserResume>>> getUserResumes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('pdfs')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      List<UserResume> resumes = snapshot.docs
          .map((doc) => UserResume.fromJson(doc.data())..id = doc.id)
          .toList();
      return AppResponse(
        message: 'Resumes fetched successfully',
        success: true,
        statusCode: 200,
        data: resumes,
      );
    } catch (e) {
      debugPrint('Error fetching resumes: $e');
      throw FirebaseErrorHandler.getErrorMessage(e);
    }
  }

  /// Stream a single resume with real-time updates
  Stream<UserResume?> getResumeStream(String resumeId) {
    return _firestore
        .collection('pdfs')
        .doc(resumeId)
        .snapshots()
        .asyncMap((snapshot) {
      if (!snapshot.exists) return null;
      try {
        return UserResume.fromJson(snapshot.data() as Map<String, dynamic>)
          ..id = snapshot.id;
      } catch (e) {
        debugPrint('Error parsing resume $resumeId: $e');
        return null;
      }
    })
        .handleError((error) {
      debugPrint('Error in resume stream: $error');
      throw FirebaseErrorHandler.getErrorMessage(error);
    });
  }

  /// Get resumes with pagination support
  Future<PaginatedResumes> getResumesPaginated(
      String userId, {
        int limit = 10,
        DocumentSnapshot? lastDocument,
        bool ascending = false,
      }) async {
    try {
      final query = _firestore
          .collection('pdfs')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: !ascending)
          .limit(limit);

      final paginatedQuery = lastDocument != null
          ? query.startAfterDocument(lastDocument)
          : query;

      final snapshot = await paginatedQuery.get();

      final resumes = await Future.wait(
        snapshot.docs.map((doc) async {
          try {
            return UserResume.fromJson(doc.data())
              ..id = doc.id;
          } catch (e) {
            debugPrint('Error parsing resume ${doc.id}: $e');
            return null;
          }
        }),
      );

      return PaginatedResumes(
        resumes: resumes.whereType<UserResume>().toList(),
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == limit,
      );
    } catch (e) {
      debugPrint('Error fetching paginated resumes: $e');
      throw FirebaseErrorHandler.getErrorMessage(e);
    }
  }
}