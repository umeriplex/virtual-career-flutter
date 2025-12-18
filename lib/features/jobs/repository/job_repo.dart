import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/utils/app_response.dart';
import '../model/job_model.dart';
import '../model/job_application_model.dart';

class JobRepository {
  final FirebaseFirestore _firestore;

  JobRepository(this._firestore);

  // Create a new job
  Future<AppResponse<JobModel>> createJob({
    required String creatorId,
    String? creatorName,
    String? creatorImage,
    required String jobTitle,
    required String company,
    required String description,
    required String location,
    required String jobType,
    required bool isPublic,
    required String experienceLevel,
    String? salaryRange,
    List<String> requirements = const [],
  }) async {
    try {
      final docRef = _firestore.collection('jobs').doc();

      final job = JobModel(
        id: docRef.id,
        creatorId: creatorId,
        creatorName: creatorName,
        creatorImage: creatorImage,
        jobTitle: jobTitle,
        company: company,
        description: description,
        location: location,
        jobType: jobType,
        experienceLevel: experienceLevel,
        salaryRange: salaryRange,
        requirements: requirements,
        dateCreated: DateTime.now(),
        isPublic: isPublic,
      );

      await docRef.set(job.toJson());

      return AppResponse(
        data: job,
        message: 'Job created successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error creating job: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get user's created jobs
  Future<AppResponse<List<JobModel>>> getMyJobs(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('creatorId', isEqualTo: userId)
          .orderBy('dateCreated', descending: true)
          .get();

      final jobs = snapshot.docs
          .map((doc) => JobModel.fromJson(doc.data(), doc.id))
          .toList();

      return AppResponse(
        data: jobs,
        message: 'Jobs fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching jobs: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get jobs from connections and public jobs (Feed)
  Future<AppResponse<List<JobModel>>> getConnectionsJobs(List<String> connectionIds, String currentUserId) async {
    try {
      List<JobModel> connectionJobs = [];
      List<JobModel> publicJobs = [];

      // 1. Fetch connections' jobs if there are connections
      if (connectionIds.isNotEmpty) {
        final connectionJobsSnapshot = await _firestore
            .collection('jobs')
            .where('creatorId', whereIn: connectionIds)
            .where('isActive', isEqualTo: true)
            .orderBy('dateCreated', descending: true)
            .get();

        connectionJobs = connectionJobsSnapshot.docs
            .map((doc) => JobModel.fromJson(doc.data(), doc.id))
            .toList();
      }

      // 2. Fetch public jobs
      final publicJobsSnapshot = await _firestore
          .collection('jobs')
          .where('isPublic', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('dateCreated', descending: true)
          .get();

      // Filter out public jobs that are already in connectionJobs
      // Also exclude jobs created by connections (if they were fetched in public query but duplicates would be handled by ID check anyway,
      // but simpler is to just filter public list).
      // Actually, simplest is to fetch public jobs and exclude those where creatorId is in connectionIds IF we already fetched them.
      // But firestore 'whereIn' is limited.
      // Better strategy:
      // - Connection Jobs: fetched above.
      // - Public Jobs: fetched above.
      // - Combine: Connection Jobs + (Public Jobs NOT in Connection Jobs list).

      final connectionJobIds = connectionJobs.map((j) => j.id).toSet();
      publicJobs = publicJobsSnapshot.docs
          .map((doc) => JobModel.fromJson(doc.data(), doc.id))
          .where((job) => 
              !connectionJobIds.contains(job.id) && 
              job.creatorId != currentUserId // exclude own jobs
          )
          .toList();

      // Combine: Connections first
      final allJobs = [...connectionJobs, ...publicJobs];

      return AppResponse(
        data: allJobs,
        message: 'Jobs fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching jobs: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Update job
  Future<AppResponse<JobModel>> updateJob({
    required String jobId,
    String? jobTitle,
    String? company,
    String? description,
    String? location,
    String? jobType,
    String? experienceLevel,
    String? salaryRange,
    List<String>? requirements,
    bool? isActive,
    bool? isPublic,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (jobTitle != null) updateData['jobTitle'] = jobTitle;
      if (company != null) updateData['company'] = company;
      if (description != null) updateData['description'] = description;
      if (location != null) updateData['location'] = location;
      if (jobType != null) updateData['jobType'] = jobType;
      if (experienceLevel != null) updateData['experienceLevel'] = experienceLevel;
      if (salaryRange != null) updateData['salaryRange'] = salaryRange;
      if (requirements != null) updateData['requirements'] = requirements;
      if (isActive != null) updateData['isActive'] = isActive;
      if (isPublic != null) updateData['isPublic'] = isPublic;

      await _firestore.collection('jobs').doc(jobId).update(updateData);

      final doc = await _firestore.collection('jobs').doc(jobId).get();
      final updatedJob = JobModel.fromJson(doc.data()!, jobId);

      return AppResponse(
        data: updatedJob,
        message: 'Job updated successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error updating job: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Delete job
  Future<AppResponse<void>> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();

      // Also delete all applications for this job
      final applications = await _firestore
          .collection('job_applications')
          .where('jobId', isEqualTo: jobId)
          .get();

      for (var doc in applications.docs) {
        await doc.reference.delete();
      }

      return AppResponse(
        message: 'Job deleted successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error deleting job: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Apply for a job
  Future<AppResponse<JobApplicationModel>> applyForJob({
    required String jobId,
    required String applicantId,
    required String coverLetter,
    String? phone,
    File? resumeFile,
    String? existingResumeUrl,
  }) async {
    try {
      String? resumeUrl = existingResumeUrl;

      // Upload resume if provided (overrides existingUrl if both present, or handling logic below)
      if (resumeFile != null) {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('resumes')
            .child('$applicantId-${DateTime.now().millisecondsSinceEpoch}.pdf');

        final UploadTask uploadTask = storageRef.putFile(resumeFile);
        final TaskSnapshot snapshot = await uploadTask;
        resumeUrl = await snapshot.ref.getDownloadURL();
      }

      final docRef = _firestore.collection('job_applications').doc();

      final application = JobApplicationModel(
        id: docRef.id,
        jobId: jobId,
        applicantId: applicantId,
        coverLetter: coverLetter,
        phone: phone,
        resumeUrl: resumeUrl,
        appliedDate: DateTime.now(),
      );

      await docRef.set(application.toJson());

      // Increment applicants count
      await _firestore.collection('jobs').doc(jobId).update({
        'applicantsCount': FieldValue.increment(1),
      });

      return AppResponse(
        data: application,
        message: 'Application submitted successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error submitting application: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get applications for a job
  Future<AppResponse<List<JobApplicationModel>>> getJobApplications(String jobId) async {
    try {
      final snapshot = await _firestore
          .collection('job_applications')
          .where('jobId', isEqualTo: jobId)
          .orderBy('appliedDate', descending: true)
          .get();

      final applications = snapshot.docs
          .map((doc) => JobApplicationModel.fromJson(doc.data(), doc.id))
          .toList();

      return AppResponse(
        data: applications,
        message: 'Applications fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching applications: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Update application status
  Future<AppResponse<void>> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      await _firestore.collection('job_applications').doc(applicationId).update({
        'status': status,
      });

      return AppResponse(
        message: 'Application status updated successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error updating status: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get user's applied jobs
  Future<AppResponse<List<JobApplicationModel>>> getMyApplications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('job_applications')
          .where('applicantId', isEqualTo: userId)
          .orderBy('appliedDate', descending: true)
          .get();

      final applications = snapshot.docs
          .map((doc) => JobApplicationModel.fromJson(doc.data(), doc.id))
          .toList();

      return AppResponse(
        data: applications,
        message: 'Applications fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching applications: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Check if user already applied for a job
  Future<AppResponse<bool>> hasApplied({
    required String jobId,
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('job_applications')
          .where('jobId', isEqualTo: jobId)
          .where('applicantId', isEqualTo: userId)
          .get();

      return AppResponse(
        data: snapshot.docs.isNotEmpty,
        message: 'Check completed',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: false,
        message: 'Error checking application: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }
}