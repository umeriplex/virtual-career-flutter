class EventModel {
  final String id;
  final String creatorId;
  final String eventTitle;
  final String description;
  final String location;
  final String eventType; // Online, In-person, Hybrid
  final DateTime eventDate;
  final String? eventTime;
  final String? meetingLink;
  final int maxAttendees;
  final DateTime dateCreated;
  final bool isActive;
  final bool isPublic;
  final int registeredCount;

  EventModel({
    required this.id,
    required this.creatorId,
    required this.eventTitle,
    required this.description,
    required this.location,
    required this.eventType,
    required this.eventDate,
    this.eventTime,
    this.meetingLink,
    this.maxAttendees = 0,
    required this.dateCreated,
    this.isActive = true,
    this.isPublic = true,
    this.registeredCount = 0,
  });

  factory EventModel.fromJson(Map<String, dynamic> json, String id) {
    return EventModel(
      id: id,
      creatorId: json['creatorId'] ?? '',
      eventTitle: json['eventTitle'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      eventType: json['eventType'] ?? '',
      eventDate: DateTime.parse(json['eventDate']),
      eventTime: json['eventTime'],
      meetingLink: json['meetingLink'],
      maxAttendees: json['maxAttendees'] ?? 0,
      dateCreated: DateTime.parse(json['dateCreated']),
      isActive: json['isActive'] ?? true,
      registeredCount: json['registeredCount'] ?? 0,
      isPublic: json['isPublic'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creatorId': creatorId,
      'eventTitle': eventTitle,
      'description': description,
      'location': location,
      'eventType': eventType,
      'eventDate': eventDate.toIso8601String(),
      'eventTime': eventTime,
      'meetingLink': meetingLink,
      'maxAttendees': maxAttendees,
      'dateCreated': dateCreated.toIso8601String(),
      'isActive': isActive,
      'registeredCount': registeredCount,
      'isPublic': isPublic,
    };
  }

  EventModel copyWith({
    String? id,
    String? creatorId,
    String? eventTitle,
    String? description,
    String? location,
    String? eventType,
    DateTime? eventDate,
    String? eventTime,
    String? meetingLink,
    int? maxAttendees,
    DateTime? dateCreated,
    bool? isActive,
    int? registeredCount,
    bool? isPublic,
  }) {
    return EventModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      eventTitle: eventTitle ?? this.eventTitle,
      description: description ?? this.description,
      location: location ?? this.location,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      meetingLink: meetingLink ?? this.meetingLink,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      dateCreated: dateCreated ?? this.dateCreated,
      isActive: isActive ?? this.isActive,
      registeredCount: registeredCount ?? this.registeredCount,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}