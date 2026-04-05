import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sparkle/features/records/data/model/health_records.dart';
import 'package:sparkle/features/records/data/model/record_category.dart';
import 'package:sparkle/features/records/data/repository/record_repository.dart';
import 'package:sparkle/features/records/presentation/bloc/record_bloc.dart';
import 'package:sparkle/features/records/presentation/bloc/record_event.dart';
import 'package:sparkle/features/records/presentation/bloc/record_state.dart';

class MockRecordRepository extends Mock implements RecordRepository {}

void main() {
  late MockRecordRepository recordRepository;

  // A sample record to use across tests
  final testRecord = HealthRecord(
    id: 'rec-1',
    userId: 'test-uid',
    category: RecordCategory.prescription,
    date: '01/04/2026',
    provider: 'Dr. Mehta',
    notes: 'Take twice daily',
  );

  setUp(() {
    recordRepository = MockRecordRepository();

    // registerFallbackValue needed for mocktail when passing complex objects
    registerFallbackValue(testRecord);
  });

  group('RecordBloc', () {

    blocTest<RecordBloc, RecordState>(
      'emits RecordLoaded when watch starts and records exist',
      build: () {
        // stub watchRecords to return a stream with one record
        when(() => recordRepository.watchRecords(any()))
            .thenAnswer((_) => Stream.value([testRecord]));

        return RecordBloc(recordRepository: recordRepository);
      },
      act: (bloc) => bloc.add(const RecordWatchStarted('test-uid')),
      expect: () => [
        const RecordLoading(),
        RecordLoaded([testRecord]),
      ],
    );

    blocTest<RecordBloc, RecordState>(
      'emits RecordLoaded with empty list when no records',
      build: () {
        when(() => recordRepository.watchRecords(any()))
            .thenAnswer((_) => Stream.value([]));

        return RecordBloc(recordRepository: recordRepository);
      },
      act: (bloc) => bloc.add(const RecordWatchStarted('test-uid')),
      expect: () => [
        const RecordLoading(),
        const RecordLoaded([]),
      ],
    );

    blocTest<RecordBloc, RecordState>(
      'calls addRecord on repository when RecordAdded event fires',
      build: () {
        when(() => recordRepository.watchRecords(any()))
            .thenAnswer((_) => Stream.value([testRecord]));

        // stub addRecord to complete successfully
        when(() => recordRepository.addRecord(any()))
            .thenAnswer((_) async {});

        return RecordBloc(recordRepository: recordRepository);
      },
      act: (bloc) async {
        bloc.add(const RecordWatchStarted('test-uid'));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(RecordAdded(testRecord));
      },
      verify: (_) {
        verify(() => recordRepository.addRecord(testRecord)).called(1);
      },
    );

    blocTest<RecordBloc, RecordState>(
      'calls deleteRecord on repository when RecordDeleted event fires',
      build: () {
        when(() => recordRepository.watchRecords(any()))
            .thenAnswer((_) => Stream.value([]));

        when(() => recordRepository.deleteRecord(any(), any()))
            .thenAnswer((_) async {});

        return RecordBloc(recordRepository: recordRepository);
      },
      act: (bloc) async {
        bloc.add(const RecordWatchStarted('test-uid'));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const RecordDeleted(
          userId: 'test-uid',
          recordId: 'rec-1',
        ));
      },
      verify: (_) {
        verify(() => recordRepository.deleteRecord('test-uid', 'rec-1'))
            .called(1);
      },
    );
  });
}