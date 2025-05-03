import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:virtual_career/core/managers/cache_manager.dart';
import '../../../config/exception/firebase_error_handler.dart';
import '../../../core/utils/app_response.dart';
import '../model/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepository(this._firestore, this._firebaseAuth);


  // Sign in with Google
  Future<AppResponse<UserModel>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AppResponse(
          message: 'Google sign-in aborted',
          success: false,
          statusCode: 400,
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      UserModel userModel;

      if (userDoc.exists) {
        userModel = UserModel.fromJson(userDoc.data()!, userCredential.user!.uid);
      } else {
        // New user, create entry
        userModel = UserModel(
          id: userCredential.user!.uid,
          fullName: userCredential.user!.displayName ?? '',
          email: userCredential.user!.email ?? '',
          dateCreated: DateTime.now(),
          isActive: true,
        );
        await _firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toJson());
      }

      await saveUser(userModel);

      return AppResponse(
        data: userModel,
        message: 'Google sign-in successful',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: AuthErrorHandler.getErrorMessage(e),
        success: false,
        statusCode: 400,
      );
    }
  }


  // Sign up with email and password
  Future<AppResponse<UserModel>> signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: credential.user!.uid,
        fullName: fullName,
        email: email,
        dateCreated: DateTime.now(),
        isActive: true,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set(user.toJson());

      await saveUser(user);

      return AppResponse(
        data: user,
        message: 'Sign up successful',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: AuthErrorHandler.getErrorMessage(e),
        success: false,
        statusCode: 400,
      );
    }
  }

  // Sign in with email and password
  Future<AppResponse<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        return AppResponse(
          message: 'User not found in database',
          success: false,
          statusCode: 404,
        );
      }

      final user = UserModel.fromJson(doc.data()!, credential.user!.uid);

      await saveUser(user);

      return AppResponse(
        data: user,
        message: 'Sign in successful',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: AuthErrorHandler.getErrorMessage(e),
        success: false,
        statusCode: 400,
      );
    }
  }

  // Forgot password
  Future<AppResponse<void>> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return AppResponse(
        message: 'Password reset email sent successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: AuthErrorHandler.getPasswordResetErrorMessage(e),
        success: false,
        statusCode: 400,
      );
    }
  }

  // Sign out
  Future<AppResponse<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await SharedPrefs.instance.removeUser();
      return AppResponse(
        message: 'Signed out successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: AuthErrorHandler.getErrorMessage(e),
        success: false,
        statusCode: 400,
      );
    }
  }

  // Check isLogged in
  Future<AppResponse<bool>> isLoggedIn() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AppResponse(
          data: false,
          message: 'No user logged in',
          success: true,
          statusCode: 200,
        );
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return AppResponse(
          data: false,
          message: 'User not found in database',
          success: true,
          statusCode: 200,
        );
      }

      return AppResponse(
        data: true,
        message: 'User is logged in',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: false,
        message: 'Error checking login status',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get current user
  Future<AppResponse<UserModel?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AppResponse(
          data: null,
          message: 'No current user',
          success: true,
          statusCode: 200,
        );
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return AppResponse(
          data: null,
          message: 'User not found',
          success: true,
          statusCode: 200,
        );
      }

      final userModel = UserModel.fromJson(doc.data()!, user.uid);

      return AppResponse(
        data: userModel,
        message: 'User fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: null,
        message: 'Error fetching current user',
        success: false,
        statusCode: 400,
      );
    }
  }

  Future<AppResponse<void>> saveUser(UserModel user) async {
    try {
      await SharedPrefs.instance.setUser(user);
      return AppResponse(
        message: 'User saved locally',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error saving user to local storage',
        success: false,
        statusCode: 400,
      );
    }
  }

  AppResponse<UserModel?> getUserFromPrefs() {
    try {
      final user = SharedPrefs.instance.getUser();
      return AppResponse(
        data: user,
        message: 'User fetched from local storage',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: null,
        message: 'Error getting user from local storage',
        success: false,
        statusCode: 400,
      );
    }
  }
}
