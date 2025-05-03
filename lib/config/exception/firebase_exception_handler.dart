import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class FirebaseErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleAuthException(error);
    } else if (error is FirebaseException) {
      return _handleFirebaseException(error);
    } else if (error is PlatformException) {
      return _handlePlatformException(error);
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is FormatException) {
      return 'Data format error. Please try again.';
    } else if (error is StateError) {
      return 'Application state error. Please restart the app.';
    } else {
      return error.toString().replaceAll('Exception: ', '');
    }
  }

  static int getErrorCode(dynamic error) {
    if (error is FirebaseAuthException) {
      return _getAuthErrorCode(error);
    } else if (error is FirebaseException) {
      return int.tryParse(error.code) ?? 500;
    }
    return 500;
  }

  static String _handleAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email.';
      case 'invalid-email':
        return 'The email address is invalid. Please enter a valid email.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'invalid-credential':
        return 'The credential is malformed or has expired.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  static String _handleFirebaseException(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You don\'t have permission to access this resource.';
      case 'unavailable':
        return 'The service is currently unavailable. Please try again later.';
      case 'cancelled':
        return 'The operation was cancelled.';
      case 'unknown':
        return 'An unknown error occurred. Please try again.';
      case 'invalid-argument':
        return 'Invalid data provided. Please check your input.';
      case 'deadline-exceeded':
        return 'The operation timed out. Please try again.';
      case 'not-found':
        return 'The requested resource was not found.';
      case 'already-exists':
        return 'A resource with this identifier already exists.';
      case 'resource-exhausted':
        return 'Resource limit reached. Please try again later.';
      case 'failed-precondition':
        return 'Operation cannot be executed in the current system state.';
      case 'aborted':
        return 'The operation was aborted. Please try again.';
      case 'out-of-range':
        return 'Operation attempted beyond valid range.';
      case 'unimplemented':
        return 'This operation is not implemented or supported.';
      case 'internal':
        return 'Internal server error. Please try again later.';
      case 'data-loss':
        return 'Data loss occurred. Please try again.';
      case 'unauthenticated':
        return 'You need to be authenticated to perform this action.';
      default:
        return error.message ?? 'Firebase operation failed. Please try again.';
    }
  }

  static String _handlePlatformException(PlatformException error) {
    switch (error.code) {
      case 'sign_in_failed':
        return 'Sign in failed. Please try again.';
      case 'network_error':
        return 'Network error occurred. Please check your connection.';
      case 'storage_quota_exceeded':
        return 'Storage quota exceeded. Please free up space or upgrade.';
      case 'download_error':
        return 'Failed to download file. Please try again.';
      case 'upload_error':
        return 'Failed to upload file. Please try again.';
      default:
        return error.message ?? 'Platform operation failed. Please try again.';
    }
  }

  static int _getAuthErrorCode(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 409; // Conflict
      case 'invalid-email':
      case 'wrong-password':
      case 'user-not-found':
        return 400; // Bad Request
      case 'user-disabled':
        return 403; // Forbidden
      case 'too-many-requests':
        return 429; // Too Many Requests
      case 'operation-not-allowed':
        return 501; // Not Implemented
      case 'requires-recent-login':
        return 401; // Unauthorized
      default:
        return 500; // Internal Server Error
    }
  }

  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
        (error is FirebaseException && error.code == 'unavailable') ||
        (error is PlatformException && error.code == 'network_error');
  }

  static bool requiresReauthentication(dynamic error) {
    return (error is FirebaseAuthException && error.code == 'requires-recent-login') ||
        (error is FirebaseException && error.code == 'unauthenticated');
  }

  static bool isResourceNotFound(dynamic error) {
    return (error is FirebaseException && error.code == 'not-found') ||
        (error is FirebaseAuthException && error.code == 'user-not-found');
  }
}