import 'package:equatable/equatable.dart';
import 'package:sparkle/features/records/data/model/health_records.dart';
import 'package:sparkle/features/records/data/model/record_category.dart';

sealed class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object?> get props => [];
}

class RecordInitial extends RecordState {
  const RecordInitial();
}

class RecordLoading extends RecordState {
  const RecordLoading();
}

class RecordLoaded extends RecordState {
  final List<HealthRecord> records;

  const RecordLoaded(this.records);

  List<HealthRecord> byCategory(RecordCategory category) =>
      records.where((r) => r.category == category).toList();

  List<HealthRecord> get recent => records.take(5).toList();

  @override
  List<Object?> get props => [records];
}

class RecordFailure extends RecordState {
  final String message;
  const RecordFailure(this.message);

  @override
  List<Object?> get props => [message];
}