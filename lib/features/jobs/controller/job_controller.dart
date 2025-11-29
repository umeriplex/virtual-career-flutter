import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/utils/toast_helper.dart';
import '../model/job_model.dart';
import '../model/job_application_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../repository/job_repo.dart';

class JobController extends GetxController {
  final JobRepository _jobRepository;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<JobModel> myJobs = <JobModel>[].obs;
  final RxList<JobModel> connectionsJobs = <JobModel>[].obs;
  final RxList<JobApplicationModel> myApplications = <JobApplicationModel>[].obs;
  final RxList<JobApplicationModel> jobApplications = <JobApplicationModel>[].obs;
  final RxBool isLoading = false.obs;

  JobController(this._jobRepository);

  @override
  void onInit() {
    super.onInit();
    fetchMyJobs();
    fetchConnectionsJobs();
    fetchMyApplications();
  }

  Future<void> createJob({
    required String jobTitle,
    required String company,
    required String description,
    required String location,
    required String jobType,
    required String experienceLevel,
    required bool isPublic,
    String? salaryRange,
    List<String> requirements = const [],
  }) async {
    try {
      isLoading(true);
      final response = await _jobRepository.createJob(
        creatorId: _authController.user!.id,
        jobTitle: jobTitle,
        company: company,
        description: description,
        location: location,
        jobType: jobType,
        experienceLevel: experienceLevel,
        salaryRange: salaryRange,
        requirements: requirements,
        isPublic: isPublic,
      );

      if (response.success && response.data != null) {
        myJobs.insert(0, response.data!);
        showSuccessMessage(response.message);
      } else {
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint("Error creating job: $e");
      showErrorMessage("Failed to create job");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMyJobs() async {
    try {
      if (_authController.user == null) return;

      isLoading(true);
      final response = await _jobRepository.getMyJobs(_authController.user!.id);

      if (response.success) {
        myJobs.value = response.data ?? [];
      } else {
        debugPrint("Error fetching jobs: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error fetching jobs: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchConnectionsJobs() async {
    try {
      if (_authController.user == null) return;

      isLoading(true);
      final connectionIds = _authController.user!.connections;
      final response = await _jobRepository.getConnectionsJobs(connectionIds);

      if (response.success) {
        connectionsJobs.value = response.data ?? [];
      } else {
        debugPrint("Error fetching connections jobs: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error fetching connections jobs: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateJob({
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
      isLoading(true);
      final response = await _jobRepository.updateJob(
        jobId: jobId,
        jobTitle: jobTitle,
        company: company,
        description: description,
        location: location,
        jobType: jobType,
        experienceLevel: experienceLevel,
        salaryRange: salaryRange,
        requirements: requirements,
        isActive: isActive,
        isPublic: isPublic,
      );

      if (response.success && response.data != null) {
        final index = myJobs.indexWhere((job) => job.id == jobId);
        if (index != -1) {
          myJobs[index] = response.data!;
        }
        showSuccessMessage(response.message);
      } else {
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint("Error updating job: $e");
      showErrorMessage("Failed to update job");
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      isLoading(true);
      final response = await _jobRepository.deleteJob(jobId);

      if (response.success) {
        myJobs.removeWhere((job) => job.id == jobId);
        showSuccessMessage(response.message);
      } else {
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint("Error deleting job: $e");
      showErrorMessage("Failed to delete job");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> applyForJob({
    required String jobId,
    required String coverLetter,
    String? phone,
    File? resumeFile,
  }) async {
    try {
      if (_authController.user == null) return false;

      isLoading(true);
      final response = await _jobRepository.applyForJob(
        jobId: jobId,
        applicantId: _authController.user!.id,
        coverLetter: coverLetter,
        phone: phone,
        resumeFile: resumeFile,
      );

      if (response.success) {
        showSuccessMessage(response.message);
        await fetchMyApplications();
        return true;
      } else {
        showErrorMessage(response.message);
        return false;
      }
    } catch (e) {
      debugPrint("Error applying for job: $e");
      showErrorMessage("Failed to apply for job");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchJobApplications(String jobId) async {
    try {
      isLoading(true);
      final response = await _jobRepository.getJobApplications(jobId);

      if (response.success) {
        jobApplications.value = response.data ?? [];
      } else {
        debugPrint("Error fetching applications: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error fetching applications: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      isLoading(true);
      final response = await _jobRepository.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
      );

      if (response.success) {
        final index = jobApplications.indexWhere((app) => app.id == applicationId);
        if (index != -1) {
          jobApplications[index] = jobApplications[index].copyWith(status: status);
        }
        showSuccessMessage(response.message);
      } else {
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint("Error updating application status: $e");
      showErrorMessage("Failed to update status");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMyApplications() async {
    try {
      if (_authController.user == null) return;

      isLoading(true);
      final response = await _jobRepository.getMyApplications(_authController.user!.id);

      if (response.success) {
        myApplications.value = response.data ?? [];
      } else {
        debugPrint("Error fetching applications: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error fetching applications: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> hasApplied(String jobId) async {
    try {
      if (_authController.user == null) return false;

      final response = await _jobRepository.hasApplied(
        jobId: jobId,
        userId: _authController.user!.id,
      );

      return response.data ?? false;
    } catch (e) {
      debugPrint("Error checking application: $e");
      return false;
    }
  }
}