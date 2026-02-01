import 'package:virtual_career/features/auth/model/user_model.dart';

class EventRegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final DateTime registeredDate;
  final String? notes;
  final UserData? user;

  EventRegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.registeredDate,
    this.notes,
    this.user,
  });

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json, String id) {
    return EventRegistrationModel(
      id: id,
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      registeredDate: DateTime.parse(json['registeredDate']),
      notes: json['notes'],
      user: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'registeredDate': registeredDate.toIso8601String(),
      'notes': notes,
      'user': user != null ? user!.toJson() : null,
    };
  }

  // copy with method
  EventRegistrationModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    DateTime? registeredDate,
    String? notes,
    UserData? user,
  }) {
    return EventRegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      registeredDate: registeredDate ?? this.registeredDate,
      notes: notes ?? this.notes,
      user: user ?? this.user,
    );
  }
}

class UserData {
  final String? fullName;
  final String? email;
  final String? profileImageUrl;

  UserData({
    this.fullName,
    this.email,
    this.profileImageUrl,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      fullName: json['fullName'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }
}