class EventRegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final DateTime registeredDate;
  final String? notes;

  EventRegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.registeredDate,
    this.notes,
  });

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json, String id) {
    return EventRegistrationModel(
      id: id,
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      registeredDate: DateTime.parse(json['registeredDate']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'registeredDate': registeredDate.toIso8601String(),
      'notes': notes,
    };
  }
}