import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/app_response.dart';
import '../model/event_model.dart';
import '../model/event_registration_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore;

  EventRepository(this._firestore);

  // Create a new event
  Future<AppResponse<EventModel>> createEvent({
    required String creatorId,
    String? creatorName,
    String? creatorImage,
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
      final docRef = _firestore.collection('events').doc();

      final event = EventModel(
        id: docRef.id,
        creatorId: creatorId,
        creatorName: creatorName,
        creatorImage: creatorImage,
        eventTitle: eventTitle,
        description: description,
        location: location,
        eventType: eventType,
        eventDate: eventDate,
        eventTime: eventTime,
        meetingLink: meetingLink,
        maxAttendees: maxAttendees,
        dateCreated: DateTime.now(),
        isPublic: isPublic,
      );

      await docRef.set(event.toJson());

      return AppResponse(
        data: event,
        message: 'Event created successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error creating event: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get user's created events
  Future<AppResponse<List<EventModel>>> getMyEvents(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('creatorId', isEqualTo: userId)
          .orderBy('eventDate', descending: false)
          .get();

      final events = snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data(), doc.id))
          .toList();

      return AppResponse(
        data: events,
        message: 'Events fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching events: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get events from connections and public events
  Future<AppResponse<List<EventModel>>> getConnectionsEvents(List<String> connectionIds, String currentUserId) async {
    try {
      List<EventModel> connectionEvents = [];
      List<EventModel> publicEvents = [];

      // Fetch connection's events
      if (connectionIds.isNotEmpty) {
        final connectionEventsSnapshot = await _firestore
            .collection('events')
            .where('creatorId', whereIn: connectionIds)
            .where('isActive', isEqualTo: true)
            .orderBy('eventDate', descending: false)
            .get();

        connectionEvents = connectionEventsSnapshot.docs
            .map((doc) => EventModel.fromJson(doc.data(), doc.id))
            .toList();
      }

      // Fetch public events
      final publicEventsSnapshot = await _firestore
          .collection('events')
          .where('isPublic', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('eventDate', descending: false)
          .get();

      // Get connection creator IDs for filtering
      final connectionCreatorIds = connectionEvents.map((e) => e.creatorId).toSet();

      publicEvents = publicEventsSnapshot.docs
          .map((doc) => EventModel.fromJson(doc.data(), doc.id))
          .where((event) =>
      !connectionCreatorIds.contains(event.creatorId) && // Exclude if creator is in connections
      event.creatorId != currentUserId // Exclude own events
      ).toList();


      print('Connection Events Count: ${connectionEvents.length}');
      print('Public Events Count: ${publicEvents.length}');

      // Combine: connections first, then public
      final allEvents = [...connectionEvents, ...publicEvents];

      return AppResponse(
        data: allEvents,
        message: 'Events fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching events: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Update event
  Future<AppResponse<EventModel>> updateEvent({
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
      final Map<String, dynamic> updateData = {};

      if (eventTitle != null) updateData['eventTitle'] = eventTitle;
      if (description != null) updateData['description'] = description;
      if (location != null) updateData['location'] = location;
      if (eventType != null) updateData['eventType'] = eventType;
      if (eventDate != null) updateData['eventDate'] = eventDate.toIso8601String();
      if (eventTime != null) updateData['eventTime'] = eventTime;
      if (meetingLink != null) updateData['meetingLink'] = meetingLink;
      if (maxAttendees != null) updateData['maxAttendees'] = maxAttendees;
      if (isActive != null) updateData['isActive'] = isActive;
      if (isPublic != null) updateData['isPublic'] = isPublic;

      await _firestore.collection('events').doc(eventId).update(updateData);

      final doc = await _firestore.collection('events').doc(eventId).get();
      final updatedEvent = EventModel.fromJson(doc.data()!, eventId);

      return AppResponse(
        data: updatedEvent,
        message: 'Event updated successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error updating event: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Delete event
  Future<AppResponse<void>> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();

      // Also delete all registrations for this event
      final registrations = await _firestore
          .collection('event_registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      for (var doc in registrations.docs) {
        await doc.reference.delete();
      }

      return AppResponse(
        message: 'Event deleted successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error deleting event: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Register for an event
  Future<AppResponse<EventRegistrationModel>> registerForEvent({
    required String eventId,
    required String userId,
    String? notes,
  }) async {
    try {
      final docRef = _firestore.collection('event_registrations').doc();

      final registration = EventRegistrationModel(
        id: docRef.id,
        eventId: eventId,
        userId: userId,
        registeredDate: DateTime.now(),
        notes: notes,
      );

      await docRef.set(registration.toJson());

      // Increment registered count
      await _firestore.collection('events').doc(eventId).update({
        'registeredCount': FieldValue.increment(1),
      });

      return AppResponse(
        data: registration,
        message: 'Registered successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        message: 'Error registering for event: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Get registrations for an event
  Future<AppResponse<List<EventRegistrationModel>>> getEventRegistrations(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('event_registrations')
          .where('eventId', isEqualTo: eventId)
          .orderBy('registeredDate', descending: true)
          .get();

      final registrations = snapshot.docs
          .map((doc) => EventRegistrationModel.fromJson(doc.data(), doc.id))
          .toList();

      return AppResponse(
        data: registrations,
        message: 'Registrations fetched successfully',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: [],
        message: 'Error fetching registrations: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }

  // Check if user already registered for an event
  Future<AppResponse<bool>> hasRegistered({
    required String eventId,
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('event_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      return AppResponse(
        data: snapshot.docs.isNotEmpty,
        message: 'Check completed',
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return AppResponse(
        data: false,
        message: 'Error checking registration: ${e.toString()}',
        success: false,
        statusCode: 400,
      );
    }
  }
}