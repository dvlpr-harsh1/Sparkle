import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkle/features/records/data/repository/record_repository.dart';
import 'package:sparkle/features/records/presentation/bloc/record_event.dart';
import 'package:sparkle/features/records/presentation/bloc/record_state.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final RecordRepository _recordRepository;

  RecordBloc({required RecordRepository recordRepository})
    : _recordRepository = recordRepository,
      super(const RecordInitial()) {
    on<RecordWatchStarted>(_onWatchStarted);
    on<RecordAdded>(_onAdded);
    on<RecordUpdated>(_onUpdated);
    on<RecordDeleted>(_onDeleted);
    on<RecordSharingUpdated>(_onSharingUpdated);
  }

  // emit.forEach listens to the stream
  // every time Firestore sends new data → new state emitted
  // UI rebuilds automatically
  Future<void> _onWatchStarted(
    RecordWatchStarted event,
    Emitter<RecordState> emit,
  ) async {
    emit(const RecordLoading());
    await emit.forEach(
      _recordRepository.watchRecords(event.userId),
      onData: (records) => RecordLoaded(records),
      onError: (_, __) => const RecordFailure('Failed to load records'),
    );
  }

  Future<void> _onAdded(RecordAdded event, Emitter<RecordState> emit) async {
    try {
      await _recordRepository.addRecord(event.record);
      // no need to emit here — stream will fire automatically
    } catch (e) {
      emit(const RecordFailure('Failed to add record'));
    }
  }

  Future<void> _onUpdated(
    RecordUpdated event,
    Emitter<RecordState> emit,
  ) async {
    try {
      await _recordRepository.updateRecord(event.record);
    } catch (e) {
      emit(const RecordFailure('Failed to update record'));
    }
  }

  Future<void> _onDeleted(
    RecordDeleted event,
    Emitter<RecordState> emit,
  ) async {
    try {
      await _recordRepository.deleteRecord(event.userId, event.recordId);
    } catch (e) {
      emit(const RecordFailure('Failed to delete record'));
    }
  }

  Future<void> _onSharingUpdated(
    RecordSharingUpdated event,
    Emitter<RecordState> emit,
  ) async {
    try {
      await _recordRepository.updateSharing(
        event.userId,
        event.recordId,
        isShared: event.isShared,
        sharedWith: event.sharedWith,
      );
    } catch (e) {
      emit(const RecordFailure('Failed to update sharing'));
    }
  }
}
