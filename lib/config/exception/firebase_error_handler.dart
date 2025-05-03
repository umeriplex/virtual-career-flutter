import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please use a different email or log in.';
        case 'invalid-email':
          return 'The email address is not valid. Please check and try again.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled. Contact support.';
        case 'weak-password':
          return 'The password is too weak. Please choose a stronger password (at least 6 characters).';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'user-not-found':
          return 'No account found with this email. Please sign up first.';
        case 'wrong-password':
          return 'Incorrect password. Please try again or reset your password.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'invalid-credential':
          return 'Invalid login credentials. Please check and try again.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with this email but different sign-in method.';
        case 'requires-recent-login':
          return 'This operation requires recent authentication. Please log in again.';
        default:
          return 'An unexpected error occurred. Please try again.';
      }
    } else if (error is FirebaseException) {
      return 'Database error occurred. Please try again.';
    } else if (error is Exception) {
      return 'An error occurred: ${error.toString().replaceAll('Exception: ', '')}';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String getSignUpErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please log in instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Your password is too weak. Please use at least 6 characters.';
        default:
          return getErrorMessage(error);
      }
    }
    return getErrorMessage(error);
  }

  static String getSignInErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email. Please sign up first.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'user-disabled':
          return 'Your account has been disabled. Contact support for help.';
        default:
          return getErrorMessage(error);
      }
    }
    return getErrorMessage(error);
  }

  static String getPasswordResetErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email. Please check and try again.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        default:
          return getErrorMessage(error);
      }
    }
    return getErrorMessage(error);
  }
}