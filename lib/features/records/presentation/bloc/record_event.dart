import 'package:equatable/equatable.dart';
import 'package:sparkle/features/records/data/model/health_records.dart';

sealed class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object?> get props => [];
}

// Start watching records for this user
class RecordWatchStarted extends RecordEvent {
  final String userId;
  const RecordWatchStarted(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RecordAdded extends RecordEvent {
  final HealthRecord record;
  const RecordAdded(this.record);

  @override
  List<Object?> get props => [record];
}

class RecordUpdated extends RecordEvent {
  final HealthRecord record;
  const RecordUpdated(this.record);

  @override
  List<Object?> get props => [record];
}

class RecordDeleted extends RecordEvent {
  final String userId;
  final String recordId;
  const RecordDeleted({required this.userId, required this.recordId});

  @override
  List<Object?> get props => [userId, recordId];
}

class RecordSharingUpdated extends RecordEvent {
  final String userId;
  final String recordId;
  final bool isShared;
  final List<String> sharedWith;

  const RecordSharingUpdated({
    required this.userId,
    required this.recordId,
    required this.isShared,
    required this.sharedWith,
  });

  @override
  List<Object?> get props => [userId, recordId, isShared, sharedWith];
}