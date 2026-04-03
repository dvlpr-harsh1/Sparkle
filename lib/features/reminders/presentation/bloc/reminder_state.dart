import 'package:equatable/equatable.dart';
import 'package:sparkle/features/reminders/data/model/remider_model.dart';

sealed class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {
  const ReminderInitial();
}

class ReminderLoading extends ReminderState {
  const ReminderLoading();
}

class ReminderLoaded extends ReminderState {
  final List<ReminderModel> reminders;

  const ReminderLoaded(this.reminders);

  List<ReminderModel> get pending => reminders.where((r) => !r.isDone).toList();

  List<ReminderModel> get completed =>
      reminders.where((r) => r.isDone).toList();

  List<ReminderModel> get upcoming =>
      reminders.where((r) => r.isUpcoming).toList();

  List<ReminderModel> get overdue =>
      reminders.where((r) => r.isOverdue).toList();

  @override
  List<Object?> get props => [reminders];
}

class ReminderFailure extends ReminderState {
  final String message;
  const ReminderFailure(this.message);

  @override
  List<Object?> get props => [message];
}
