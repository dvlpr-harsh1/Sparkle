import 'package:sparkle/features/records/data/model/record_category.dart';

class HealthRecord {
  final String id;
  final String userId;
  final String? dependentId;
  final RecordCategory category;
  final String date;
  final String provider;
  final String notes;
  final bool isShared;
  final List<String> sharedWith;
  final Map<String, dynamic> details;

  const HealthRecord({
    required this.id,
    required this.userId,
    this.dependentId,
    required this.category,
    required this.date,
    required this.provider,
    required this.notes,
    this.isShared = false,
    this.sharedWith = const [],
    this.details = const {}, 
  });

  factory HealthRecord.fromMap(String id, Map<String, dynamic> map) {
    return HealthRecord(
      id: id,
      userId: map['userId'] ?? '',
      dependentId: map['dependentId'],
      category: RecordCategory.values.byName(
        map['category'] ?? 'prescription',
      ),
      date: map['date'] ?? '',
      provider: map['provider'] ?? '',
      notes: map['notes'] ?? '',
      isShared: map['isShared'] ?? false,
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
      details: Map<String, dynamic>.from(map['details'] ?? {}), // ← add
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dependentId': dependentId,
      'category': category.name,
      'date': date,
      'provider': provider,
      'notes': notes,
      'isShared': isShared,
      'sharedWith': sharedWith,
      'details': details,
    };
  }

  HealthRecord copyWith({
    RecordCategory? category,
    String? date,
    String? provider,
    String? notes,
    bool? isShared,
    List<String>? sharedWith,
    Map<String, dynamic>? details,
  }) {
    return HealthRecord(
      id: id,
      userId: userId,
      dependentId: dependentId,
      category: category ?? this.category,
      date: date ?? this.date,
      provider: provider ?? this.provider,
      notes: notes ?? this.notes,
      isShared: isShared ?? this.isShared,
      sharedWith: sharedWith ?? this.sharedWith,
      details: details ?? this.details,
    );
  }
}