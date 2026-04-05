import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkle/features/reminders/data/repository/reminder_repository.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_event.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository _reminderRepository;

  ReminderBloc({required ReminderRepository reminderRepository})
      : _reminderRepository = reminderRepository,
        super(const ReminderInitial()) {
    on<ReminderWatchStarted>(_onWatchStarted);
    on<ReminderAdded>(_onAdded);
    on<ReminderToggleDone>(_onToggleDone);
    on<ReminderUpdated>(_onUpdated);
    on<ReminderDeleted>(_onDeleted);
  }

  Future<void> _onWatchStarted(
    ReminderWatchStarted event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    await emit.forEach(
      _reminderRepository.watchReminders(event.userId),
      onData: (reminders) => ReminderLoaded(reminders),
      onError: (_, __) => const ReminderFailure('Failed to load reminders'),
    );
  }

  Future<void> _onAdded(
    ReminderAdded event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _reminderRepository.addReminder(event.reminder);
    } catch (e) {
      emit(const ReminderFailure('Failed to add reminder'));
    }
  }

  Future<void> _onToggleDone(
    ReminderToggleDone event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _reminderRepository.toggleDone(
        event.userId,
        event.reminderId,
        event.isDone,
      );
    } catch (e) {
      emit(const ReminderFailure('Failed to update reminder'));
    }
  }

  Future<void> _onUpdated(
    ReminderUpdated event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _reminderRepository.updateReminder(event.reminder);
    } catch (e) {
      emit(const ReminderFailure('Failed to update reminder'));
    }
  }

  Future<void> _onDeleted(
    ReminderDeleted event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _reminderRepository.deleteReminder(
        event.userId,
        event.reminderId,
      );
    } catch (e) {
      emit(const ReminderFailure('Failed to delete reminder'));
    }
  }
}