import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/app_response.dart';
import '../../auth/model/user_model.dart';

class ConnectionRepository {
  final FirebaseFirestore _firestore;

  ConnectionRepository(this._firestore);

  // Follow/Connect with a user
  Future<AppResponse<void>> connectWithUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Add targetUserId to current user's connections
      await _firestore.collection('users').doc(currentUserId).update({
        'connections': FieldValue.arrayUnion([targetUserId]),
      });

      // Add currentUserId to target user's followers
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayUnion([currentUserId]),
      });

      return AppResponse(
        message: 'Connected successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error connecting: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Unfollow/Disconnect from a user
  Future<AppResponse<void>> disconnectFromUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Remove targetUserId from current user's connections
      await _firestore.collection('users').doc(currentUserId).update({
        'connections': FieldValue.arrayRemove([targetUserId]),
      });

      // Remove currentUserId from target user's followers
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayRemove([currentUserId]),
      });

      return AppResponse(
        message: 'Disconnected successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error disconnecting: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get user's connections list
  Future<AppResponse<List<UserModel>>> getMyConnections(String userId) async {
    try {
      // Get current user
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return AppResponse(
          data: [],
          message: 'User not found',
          success: false,
          statusCode: 404,
        );
      }

      final user = UserModel.fromJson(userDoc.data()!, userDoc.id);

      if (user.connections.isEmpty) {
        return AppResponse(
          data: [],
          message: 'No connections found',
          success: true,
          statusCode: 200,
        );
      }

      // Get all connected users
      final connectionsSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: user.connections)
          .get();

      final connections = connectionsSnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();

      return AppResponse(
        data: connections,
        message: 'Connections fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching connections: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get user's followers list
  Future<AppResponse<List<UserModel>>> getMyFollowers(String userId) async {
    try {
      // Get current user
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return AppResponse(
          data: [],
          message: 'User not found',
          success: false,
          statusCode: 404,
        );
      }

      final user = UserModel.fromJson(userDoc.data()!, userDoc.id);

      if (user.followers.isEmpty) {
        return AppResponse(
          data: [],
          message: 'No followers found',
          success: true,
          statusCode: 200,
        );
      }

      // Get all followers
      final followersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: user.followers)
          .get();

      final followers = followersSnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();

      return AppResponse(
        data: followers,
        message: 'Followers fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching followers: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Search users by name or email
  Future<AppResponse<List<UserModel>>> searchUsers({
    required String query,
    required String currentUserId,
  }) async {
    try {
      if (query.isEmpty) {
        return AppResponse(
          data: [],
          message: 'Query cannot be empty',
          success: false,
          statusCode: 400,
        );
      }

      // Search by full name (case-insensitive)
      final snapshot = await _firestore
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: query)
          .where('fullName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .where((user) => user.id != currentUserId) // Exclude current user
          .toList();

      return AppResponse(
        data: users,
        message: 'Users fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error searching users: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get user by ID
  Future<AppResponse<UserModel>> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return AppResponse(
          message: 'User not found',
          success: false,
          statusCode: 404,
        );
      }

      final user = UserModel.fromJson(doc.data()!, doc.id);

      return AppResponse(
        data: user,
        message: 'User fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error fetching user: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Check if user is connected
  Future<AppResponse<bool>> isConnected({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();

      if (!doc.exists) {
        return AppResponse(
          data: false,
          message: 'User not found',
          success: false,
          statusCode: 404,
        );
      }

      final user = UserModel.fromJson(doc.data()!, doc.id);
      final isConnected = user.connections.contains(targetUserId);

      return AppResponse(
        data: isConnected,
        message: 'Check completed',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: false,
        message: 'Error checking connection: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get suggested users (users not yet connected)
  Future<AppResponse<List<UserModel>>> getSuggestedUsers({
    required String currentUserId,
    int limit = 10,
  }) async {
    try {
      // Get current user to exclude their connections
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (!userDoc.exists) {
        return AppResponse(
          data: [],
          message: 'User not found',
          success: false,
          statusCode: 404,
        );
      }

      final currentUser = UserModel.fromJson(userDoc.data()!, userDoc.id);

      // Get random users
      final snapshot = await _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .limit(limit * 3) // Fetch more to filter out connections
          .get();

      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .where((user) =>
      user.id != currentUserId &&
          !currentUser.connections.contains(user.id)
      )
          .take(limit)
          .toList();

      return AppResponse(
        data: users,
        message: 'Suggested users fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching suggested users: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }
}