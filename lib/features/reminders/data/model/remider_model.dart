import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkle/features/reminders/data/model/remider_type.dart';

class ReminderModel {
  final String id;
  final String userId;
  final String? dependentId;
  final String title;
  final ReminderType type;
  final DateTime dateTime;
  final bool isDone;
  final String notes;

  const ReminderModel({
    required this.id,
    required this.userId,
    this.dependentId,
    required this.title,
    required this.type,
    required this.dateTime,
    this.isDone = false,
    this.notes = '',
  });

  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id,
      userId: map['userId'] ?? '',
      dependentId: map['dependentId'],
      title: map['title'] ?? '',
      type: ReminderType.values.byName(map['type'] ?? 'medication'),
      dateTime: (map['dateTime'] as Timestamp).toDate(),

      isDone: map['isDone'] ?? false,
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dependentId': dependentId,
      'title': title,
      'type': type.name,

      'dateTime': Timestamp.fromDate(dateTime),

      'isDone': isDone,
      'notes': notes,
    };
  }

  ReminderModel copyWith({
    String? title,
    ReminderType? type,
    DateTime? dateTime,
    bool? isDone,
    String? notes,
    String? dependentId,
  }) {
    return ReminderModel(
      id: id,
      userId: userId,
      dependentId: dependentId ?? this.dependentId,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      isDone: isDone ?? this.isDone,
      notes: notes ?? this.notes,
    );
  }

  bool get isOverdue =>
      DateTime.now().isAfter(dateTime) && !isDone;
  bool get isUpcoming {
    final now = DateTime.now();
    final diff = dateTime.difference(now);
    return diff.inHours >= 0 && diff.inHours <= 24 && !isDone;
  }
}