import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/utils/toast_helper.dart';
import 'package:virtual_career/features/resume_builder/model/user_resume.dart';

import '../../../core/managers/cache_manager.dart';
import '../model/resumer_model.dart';
import '../repository/resume_builder_repository.dart';

class ResumeBuilderController extends GetxController{
  final ResumeBuilderRepository _resumeBuilderRepository;
  ResumeBuilderController(this._resumeBuilderRepository);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<List<UserResume>> _resumes = Rx<List<UserResume>>([]);
  List<UserResume> get resumes => _resumes.value;


  // upload user resume
  RxBool isLoading = false.obs;
  Future<bool> uploadUserResume({
    required String userId,
    required File pdfFile,
    required String title,
    required Resume resume,
    required File thumbnailFile,
  }) async {
    try {
      isLoading(true);
      final response = await _resumeBuilderRepository.uploadUserResume(
        userId: userId,
        pdfFile: pdfFile,
        title: title,
        resume: resume,
        thumbnailFile: thumbnailFile,
      );
      if (response.success) {
        showSuccessMessage(response.message);
      } else {
        showErrorMessage(response.message);
      }
      return response.success;
    } catch (e) {
      debugPrint('Error uploading resume: $e');
      showErrorMessage('An error occurred while uploading the resume: $e');
      return false;
    }finally { isLoading(false); }
  }


  // delete user resume
  Future<bool> deleteUserResume(String resumeId) async {
    try {
      final response = await _resumeBuilderRepository.deleteResume(resumeId);
      if (response.success) {
        showSuccessMessage(response.message);
        _resumes.value.removeWhere((resume) => resume.id == resumeId);
        _resumes.refresh();
      } else {
        showErrorMessage(response.message);
      }
      return response.success;
    } catch (e) {
      debugPrint('Error deleting resume: $e');
      showErrorMessage('An error occurred while deleting the resume: $e');
      return false;
    }
  }


  Future<void> fetchUserResumes(String userId) async {
    try {
      final response = await _resumeBuilderRepository.getUserResumes(userId);
      if (response.success) {
        _resumes.value = response.data ?? [];
      } else {
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint('Error fetching resumes: $e');
      showErrorMessage('An error occurred while fetching resumes: $e');
    }
  }



  @override
  void onInit() {
    super.onInit();
    fetchUserResumes(SharedPrefs.instance.getUser()!.id);
  }


}