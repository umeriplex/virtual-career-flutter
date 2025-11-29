class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? bio;
  final String? profileImageUrl;
  final DateTime dateCreated;
  final bool isActive;
  final List<String> connections; // List of user IDs
  final List<String> followers; // List of user IDs who follow this user

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.bio,
    this.profileImageUrl,
    required this.dateCreated,
    required this.isActive,
    this.connections = const [],
    this.followers = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'],
      dateCreated: DateTime.parse(json['dateCreated']),
      isActive: json['isActive'] ?? true,
      connections: List<String>.from(json['connections'] ?? []),
      followers: List<String>.from(json['followers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'dateCreated': dateCreated.toIso8601String(),
      'isActive': isActive,
      'connections': connections,
      'followers': followers,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? bio,
    String? profileImageUrl,
    DateTime? dateCreated,
    bool? isActive,
    List<String>? connections,
    List<String>? followers,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateCreated: dateCreated ?? this.dateCreated,
      isActive: isActive ?? this.isActive,
      connections: connections ?? this.connections,
      followers: followers ?? this.followers,
    );
  }
}