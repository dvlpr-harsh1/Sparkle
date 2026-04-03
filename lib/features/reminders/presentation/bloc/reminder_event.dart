import 'package:equatable/equatable.dart';
import 'package:sparkle/features/reminders/data/model/remider_model.dart';

sealed class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class ReminderWatchStarted extends ReminderEvent {
  final String userId;
  const ReminderWatchStarted(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ReminderAdded extends ReminderEvent {
  final ReminderModel reminder;
  const ReminderAdded(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class ReminderToggleDone extends ReminderEvent {
  final String userId;
  final String reminderId;
  final bool isDone;

  const ReminderToggleDone({
    required this.userId,
    required this.reminderId,
    required this.isDone,
  });

  @override
  List<Object?> get props => [userId, reminderId, isDone];
}

class ReminderUpdated extends ReminderEvent {
  final ReminderModel reminder;
  const ReminderUpdated(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class ReminderDeleted extends ReminderEvent {
  final String userId;
  final String reminderId;

  const ReminderDeleted({required this.userId, required this.reminderId});

  @override
  List<Object?> get props => [userId, reminderId];
}
