class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final bool isActive;
  final DateTime dateCreated;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.isActive = true,
    required this.dateCreated,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'isActive': isActive,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  // Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      isActive: json['isActive'] ?? true,
      dateCreated: DateTime.parse(json['dateCreated']),
    );
  }

  // copyWith method to create a new instance with updated values
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? profileImageUrl,
    String? bio,
    bool? isActive,
    DateTime? dateCreated,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      isActive: isActive ?? this.isActive,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}