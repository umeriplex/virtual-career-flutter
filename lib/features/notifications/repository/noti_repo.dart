import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/app_response.dart';
import '../model/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  // Create a notification
  Future<AppResponse<NotificationModel>> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    try {
      final docRef = _firestore.collection('notifications').doc();

      final notification = NotificationModel(
        id: docRef.id,
        userId: userId,
        title: title,
        message: message,
        type: type,
        referenceId: referenceId,
        createdAt: DateTime.now(),
      );

      await docRef.set(notification.toJson());

      return AppResponse(
        data: notification,
        message: 'Notification created successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error creating notification: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get user's notifications
  Future<AppResponse<List<NotificationModel>>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
          .toList();

      return AppResponse(
        data: notifications,
        message: 'Notifications fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching notifications: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get unread notifications count
  Future<AppResponse<int>> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return AppResponse(
        data: snapshot.docs.length,
        message: 'Unread count fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: 0,
        message: 'Error fetching unread count: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Mark notification as read
  Future<AppResponse<void>> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });

      return AppResponse(
        message: 'Notification marked as read',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error marking notification as read: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Mark all notifications as read
  Future<AppResponse<void>> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      return AppResponse(
        message: 'All notifications marked as read',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error marking all as read: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Delete a notification
  Future<AppResponse<void>> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();

      return AppResponse(
        message: 'Notification deleted successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error deleting notification: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Delete all notifications for a user
  Future<AppResponse<void>> deleteAllNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return AppResponse(
        message: 'All notifications deleted successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error deleting notifications: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Stream notifications (real-time updates)
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
        .toList());
  }
}