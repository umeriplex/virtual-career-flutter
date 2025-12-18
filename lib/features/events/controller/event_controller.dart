import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/utils/toast_helper.dart';
import 'package:virtual_career/features/auth/controller/auth_controller.dart';
import '../model/event_model.dart';
import '../model/event_registration_model.dart';
import '../repository/event_repo.dart';

class EventController extends GetxController {
  final EventRepository _eventRepository;

  final isLoading = false.obs;
  final myEvents = <EventModel>[].obs;
  final connectionsEvents = <EventModel>[].obs;
  final myRegistrations = <EventRegistrationModel>[].obs;
  final AuthController _authController = Get.find<AuthController>();

  EventController(this._eventRepository);

  @override
  void onReady() {
    fetchMyEvents();
    fetchConnectionsEvents();
    super.onReady();
  }

  // Create event
  Future<void> createEvent({
    required String creatorId,
    required String eventTitle,
    required String description,
    required String location,
    required String eventType,
    required DateTime eventDate,
    required bool isPublic,
    String? eventTime,
    String? meetingLink,
    int maxAttendees = 0,
  }) async {
    try {
      isLoading.value = true;
      final response = await _eventRepository.createEvent(
        creatorId: creatorId,
        creatorName: _authController.user?.fullName,
        creatorImage: _authController.user?.profileImageUrl,
        eventTitle: eventTitle,
        description: description,
        location: location,
        eventType: eventType,
        eventDate: eventDate,
        eventTime: eventTime,
        meetingLink: meetingLink,
        maxAttendees: maxAttendees,
        isPublic: isPublic,
      );

      if (response.success) {
        Get.back();
        showSuccessMessage(response.message);
        fetchMyEvents();
      } else {
        showErrorMessage(response.message);
      }
    } catch (e) {
      showErrorMessage('Failed to create event: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch user's events
  Future<void> fetchMyEvents() async {
    try {
      isLoading.value = true;
      // Replace with actual user ID from your auth system
      final String userId = _authController.user!.id;
      final response = await _eventRepository.getMyEvents(userId);

      if (response.success) {
        myEvents.assignAll(response.data!);
      } else {
        showErrorMessage(response.message!);
      }
    } catch (e) {
      showErrorMessage('Failed to fetch events: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch connections events
  Future<void> fetchConnectionsEvents({ List<String>? ids }) async {
    try {
      isLoading.value = true;
      // Replace with actual connection IDs from your system
      final List<String> connectionIds = ids ?? _authController.user?.connections ?? [];
      if (_authController.user == null) return;
      final response = await _eventRepository.getConnectionsEvents(connectionIds, _authController.user!.id);

      if (response.success) {
        connectionsEvents.assignAll(response.data!);
      } else {
        showErrorMessage(response.message!);
      }
    } catch (e) {
      showErrorMessage('Failed to fetch connections events: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Update event
  Future<void> updateEvent({
    required String eventId,
    String? eventTitle,
    String? description,
    String? location,
    String? eventType,
    DateTime? eventDate,
    String? eventTime,
    String? meetingLink,
    int? maxAttendees,
    bool? isActive,
    bool? isPublic,
  }) async {
    try {
      isLoading.value = true;
      final response = await _eventRepository.updateEvent(
        eventId: eventId,
        eventTitle: eventTitle,
        description: description,
        location: location,
        eventType: eventType,
        eventDate: eventDate,
        eventTime: eventTime,
        meetingLink: meetingLink,
        maxAttendees: maxAttendees,
        isActive: isActive,
        isPublic: isPublic,
      );

      if (response.success) {
        Get.back();
        showSuccessMessage(response.message);
        fetchMyEvents();
      } else {
        showErrorMessage(response.message!);
      }
    } catch (e) {
      showErrorMessage('Failed to update event: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      final confirmed = await Get.dialog(
        AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
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

      if (confirmed == true) {
        isLoading.value = true;
        final response = await _eventRepository.deleteEvent(eventId);

        if (response.success) {
          Get.back();
          showSuccessMessage('Event deleted successfully');
          fetchMyEvents();
        } else {
          showErrorMessage(response.message);
        }
      }
    } catch (e) {
      showErrorMessage('Failed to delete event: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Register for event
  Future<void> registerForEvent({
    required String eventId,
    required String userId,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      final response = await _eventRepository.registerForEvent(
        eventId: eventId,
        userId: userId,
        notes: notes,
      );

      if (response.success) {
        showSuccessMessage(response.message);
        fetchConnectionsEvents();
      } else {
        showErrorMessage(response.message!);
      }
    } catch (e) {
      showErrorMessage('Failed to register for event: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user is registered for event
  Future<bool> isUserRegistered({
    required String eventId,
    required String userId,
  }) async {
    try {
      final response = await _eventRepository.hasRegistered(
        eventId: eventId,
        userId: userId,
      );
      return response.data ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get event registrations
  Future<List<EventRegistrationModel>> getEventRegistrations(String eventId) async {
    try {
      final response = await _eventRepository.getEventRegistrations(eventId);
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }
}