import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/noti_repo.dart';
import '../model/notification_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../../../core/utils/toast_helper.dart';

class NotificationController extends GetxController {
  final NotificationRepository _notificationRepository;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<List<NotificationModel>>? _notificationStream;

  NotificationController(this._notificationRepository);

  @override
  void onInit() {
    super.onInit();
    _startListeningToNotifications();
  }

  @override
  void onClose() {
    _notificationStream?.cancel();
    super.onClose();
  }

  // Start listening to real-time notifications
  void _startListeningToNotifications() {
    if (_authController.user == null) return;

    _notificationStream = _notificationRepository
        .streamUserNotifications(_authController.user!.id)
        .listen((notificationList) {
      notifications.value = notificationList;
      _updateUnreadCount();
    });
  }

  // Create a notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    try {
      final response = await _notificationRepository.createNotification(
        userId: userId,
        title: title,
        message: message,
        type: type,
        referenceId: referenceId,
      );

      if (!response.success) {
        debugPrint("Error creating notification: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error creating notification: $e");
    }
  }

  // Fetch notifications
  Future<void> fetchNotifications() async {
    try {
      if (_authController.user == null) return;

      isLoading(true);
      final response = await _notificationRepository.getUserNotifications(
        _authController.user!.id,
      );

      if (response.success) {
        notifications.value = response.data ?? [];
        _updateUnreadCount();
      } else {
        debugPrint("Error fetching notifications: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      isLoading(false);
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _notificationRepository.markAsRead(notificationId);

      if (response.success) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          _updateUnreadCount();
        }
      } else {
        debugPrint("Error marking notification as read: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      if (_authController.user == null) return;

      isLoading(true);
      final response = await _notificationRepository.markAllAsRead(
        _authController.user!.id,
      );

      if (response.success) {
        showSuccessMessage(response.message);
        await fetchNotifications();
      } else {
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint("Error marking all as read: $e");
      showErrorMessage("Failed to mark all as read");
    } finally {
      isLoading(false);
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await _notificationRepository.deleteNotification(notificationId);

      if (response.success) {
        notifications.removeWhere((n) => n.id == notificationId);
        _updateUnreadCount();
        showSuccessMessage(response.message);
      } else {
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint("Error deleting notification: $e");
      showErrorMessage("Failed to delete notification");
    }
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      if (_authController.user == null) return;

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete All'),
          content: const Text('Are you sure you want to delete all notifications?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isLoading(true);
      final response = await _notificationRepository.deleteAllNotifications(
        _authController.user!.id,
      );

      if (response.success) {
        notifications.clear();
        unreadCount.value = 0;
        showSuccessMessage(response.message);
      } else {
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint("Error deleting all notifications: $e");
      showErrorMessage("Failed to delete all notifications");
    } finally {
      isLoading(false);
    }
  }

  // Update unread count
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return notifications.where((n) => !n.isRead).toList();
  }

  // Get read notifications
  List<NotificationModel> get readNotifications {
    return notifications.where((n) => n.isRead).toList();
  }

  // Helper methods to create specific notification types

  // Job application notification
  Future<void> notifyJobApplication({
    required String jobCreatorId,
    required String applicantName,
    required String jobTitle,
    required String jobId,
  }) async {
    await createNotification(
      userId: jobCreatorId,
      title: 'New Job Application',
      message: '$applicantName applied for $jobTitle',
      type: 'job_application',
      referenceId: jobId,
    );
  }

  // Job status update notification
  Future<void> notifyJobStatusUpdate({
    required String applicantId,
    required String jobTitle,
    required String status,
    required String jobId,
  }) async {
    await createNotification(
      userId: applicantId,
      title: 'Application Status Updated',
      message: 'Your application for $jobTitle has been $status',
      type: 'job_status',
      referenceId: jobId,
    );
  }

  // New connection notification
  Future<void> notifyNewConnection({
    required String userId,
    required String connectorName,
    required String connectorId,
  }) async {
    await createNotification(
      userId: userId,
      title: 'New Connection',
      message: '$connectorName started following you',
      type: 'connection',
      referenceId: connectorId,
    );
  }

  // Event registration notification
  Future<void> notifyEventRegistration({
    required String eventCreatorId,
    required String attendeeName,
    required String eventTitle,
    required String eventId,
  }) async {
    await createNotification(
      userId: eventCreatorId,
      title: 'New Event Registration',
      message: '$attendeeName registered for $eventTitle',
      type: 'event_registration',
      referenceId: eventId,
    );
  }
}