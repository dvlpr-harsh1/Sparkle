class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? photoUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.dateOfBirth,
    this.bloodGroup,
    this.gender,
    this.photoUrl,
  });
  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    return UserProfile(
      id: id,
      name: map['name'],
      email: map['email'],
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'],
      bloodGroup: map['bloodGroup'],
      photoUrl: map['photoUrl'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'photoUrl': photoUrl,
    };
  }

  UserProfile copyWith({
    String? name,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? photoUrl,
  }) {
    return UserProfile(
      id: id,
      email: email,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // How complete is this profile? Used in dashboard later
  double get completionPercentage {
    int filled = 0;
    if (name.isNotEmpty) filled++;
    if (dateOfBirth != null) filled++;
    if (gender != null) filled++;
    if (bloodGroup != null) filled++;
    return filled / 4;
  }
}
