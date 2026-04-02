class DependentModel {
  final String id;
  final String name;
  final String relation;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;

  const DependentModel({
    required this.id,
    required this.name,
    required this.relation,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
  });

  factory DependentModel.fromMap(String id, Map<String, dynamic> map) {
    return DependentModel(
      id: id,
      name: map['name'] ?? '',
      relation: map['relation'] ?? '',
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'],
      bloodGroup: map['bloodGroup'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relation': relation,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodGroup': bloodGroup,
    };
  }
}
