import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/utils/toast_helper.dart';
import '../repository/auth_repository.dart';
import '../model/user_model.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  AuthController(this._authRepository);

  UserModel? get user => _user.value;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }


  Future<UserModel?> signInWithGoogle() async {
    try {
      isLoading(true);
      final response = await _authRepository.signInWithGoogle();
      if(response.success){
        _user.value = response.data;
        return response.data;
      } else {
        debugPrint("Error while signing in with Google: ${response.message}");
        showErrorMessage(response.message);
        return null;
      }
    } catch (e) {
      debugPrint("Error while signing in with Google: $e");
      return null;
    } finally {
      isLoading(false);
    }
  }


  void updateUser (UserModel user){
    if(_user.value != null){
      UserModel updatedUser = _user.value!.copyWith(
        fullName: user.fullName,
        email: user.email,
        bio: user.bio,
        isActive: user.isActive,
        id: user.id,
        dateCreated: user.dateCreated,
        profileImageUrl: user.profileImageUrl,
      );
      _user.value = updatedUser;
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      isLoading(true);
      final user = await _authRepository.getCurrentUser();
      if(user.success){
        _user.value = user.data;
      }
      else{
        _user.value = null;
        debugPrint("Error while fetching user: ${user.message}");
      }
    } catch (e) {
      _user.value = null;
      debugPrint("Error while fetching user: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<UserModel?> signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      isLoading(true);
      final user = await _authRepository.signUpWithEmailAndPassword(
        fullName: fullName,
        email: email,
        password: password,
      );

      if(user.success){
        _user.value = user.data;
        return user.data;
      }
      else{
        debugPrint("Error while signing up: ${user.message}");
        showErrorMessage(user.message);
        return null;
      }
    } catch (e) {
      debugPrint("Error while signing up: $e");
      return null;
    } finally {
      isLoading(false);
    }
  }

  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      isLoading(true);
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if(user.success){
        _user.value = user.data;
        return user.data;
      }
      else{
        debugPrint("Error while signing in: ${user.message}");
        showErrorMessage(user.message);
        return null;
      }
    } catch (e) {
      debugPrint("Error while signing in: $e");
      return null;
    } finally {
      isLoading(false);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading(true);
      var response = await _authRepository.forgotPassword(email);
      if(response.success){
        showSuccessMessage("Password reset email sent successfully");
      }else{
        debugPrint("Error while sending password reset email: ${response.message}");
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint("Error while sending password reset email: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> signOut() async {
    try {
      isLoading(true);
      var response = await _authRepository.signOut();
      if(response.success){
        showSuccessMessage("Signed out successfully");
        _user.value = null;
        return true;
      }
      else{
        debugPrint("Error while signing out: ${response.message}");
        showErrorMessage(response.message);
        return false;
      }
    } catch (e) {
      debugPrint("Error while signing out: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      isLoading(true);
      final loggedIn = await _authRepository.isLoggedIn();
      return loggedIn.data ?? false;
    } catch (e) {
      return false;
    } finally {
      isLoading(false);
    }
  }


  Future<bool> updateProfile({
    String? fullName,
    String? bio,
  }) async {
    try {
      if (_user.value == null) return false;

      isLoading(true);
      final response = await _authRepository.updateProfile(
        userId: _user.value!.id,
        fullName: fullName,
        bio: bio,
      );

      if (response.success) {
        _user.value = response.data;
        showSuccessMessage(response.message);
        return true;
      } else {
        showErrorMessage(response.message);
        return false;
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
      showErrorMessage("Failed to update profile");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateProfilePicture(File imageFile) async {
    try {
      if (_user.value == null) return false;

      isLoading(true);
      final response = await _authRepository.updateProfilePicture(
        userId: _user.value!.id,
        imageFile: imageFile,
      );

      if (response.success) {
        _user.value = response.data;
        showSuccessMessage(response.message);
        return true;
      } else {
        showErrorMessage(response.message);
        return false;
      }
    } catch (e) {
      debugPrint("Error updating profile picture: $e");
      showErrorMessage("Failed to update profile picture");
      return false;
    } finally {
      isLoading(false);
    }
  }

}