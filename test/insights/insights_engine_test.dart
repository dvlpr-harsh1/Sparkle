import 'package:flutter_test/flutter_test.dart';
import 'package:sparkle/features/insights/data/insight_engine.dart';
import 'package:sparkle/features/insights/data/models/insight_model.dart';
import 'package:sparkle/features/profile/data/model/user_model.dart';
import 'package:sparkle/features/records/data/model/health_records.dart';
import 'package:sparkle/features/records/data/model/record_category.dart';
import 'package:sparkle/features/reminders/data/model/remider_model.dart';
import 'package:sparkle/features/reminders/data/model/remider_type.dart';

void main() {
  // Helper — creates a minimal valid profile
  UserProfile makeProfile({
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
  }) {
    return UserProfile(
      id: 'test-uid',
      name: 'Harsh',
      email: 'harsh@test.com',
      dateOfBirth: dateOfBirth,
      gender: gender,
      bloodGroup: bloodGroup,
    );
  }

  // Helper — creates a health record with a specific category and date
  HealthRecord makeRecord({
    required RecordCategory category,
    required String date,
  }) {
    return HealthRecord(
      id: 'rec-1',
      userId: 'test-uid',
      category: category,
      date: date,
      provider: 'Dr. Test',
      notes: '',
    );
  }

  // Helper — creates a reminder
  ReminderModel makeReminder({
    required bool isDone,
    required DateTime dateTime,
  }) {
    return ReminderModel(
      id: 'rem-1',
      userId: 'test-uid',
      title: 'Test reminder',
      type: ReminderType.medication,
      dateTime: dateTime,
      isDone: isDone,
    );
  }

  group('InsightsEngine', () {
    test('returns profile incomplete tip when profile is not 100%', () {
      // incomplete profile — no DOB, gender, blood group
      final profile = makeProfile();
      final insights = InsightsEngine.generate(
        profile: profile,
        records: [],
        reminders: [],
      );

      expect(
        insights.any((i) => i.type == InsightType.tip),
        isTrue,
        reason: 'Should show tip when profile is incomplete',
      );
    });

    test('returns start health vault insight when no records exist', () {
      final profile = makeProfile(
        dateOfBirth: '01/01/1995',
        gender: 'Male',
        bloodGroup: 'B+',
      );

      final insights = InsightsEngine.generate(
        profile: profile,
        records: [],
        reminders: [],
      );

      expect(
        insights.any((i) => i.title.contains('vault')),
        isTrue,
        reason: 'Should prompt to start health vault when no records',
      );
    });

    test('returns no vaccination warning when no vaccine records exist', () {
      final profile = makeProfile(
        dateOfBirth: '01/01/1995',
        gender: 'Male',
        bloodGroup: 'B+',
      );

      // only a prescription record, no vaccine
      final records = [
        makeRecord(category: RecordCategory.prescription, date: '01/01/2026'),
      ];

      final insights = InsightsEngine.generate(
        profile: profile,
        records: records,
        reminders: [],
      );

      expect(
        insights.any((i) => i.title.contains('vaccination')),
        isTrue,
        reason: 'Should warn about missing vaccination records',
      );
    });

    test(
      'returns vaccination due warning when last vaccine is over 12 months ago',
      () {
        final profile = makeProfile(
          dateOfBirth: '01/01/1995',
          gender: 'Male',
          bloodGroup: 'B+',
        );

        // vaccine record from 2 years ago
        final records = [
          makeRecord(category: RecordCategory.vaccine, date: '01/01/2024'),
          makeRecord(category: RecordCategory.visit, date: '01/01/2026'),
        ];

        final insights = InsightsEngine.generate(
          profile: profile,
          records: records,
          reminders: [],
        );

        expect(
          insights.any(
            (i) =>
                i.title.contains('Vaccination') &&
                i.type == InsightType.warning,
          ),
          isTrue,
          reason: 'Should warn when last vaccination was over 12 months ago',
        );
      },
    );

    test('returns annual checkup due when no visit records exist', () {
      final profile = makeProfile(
        dateOfBirth: '01/01/1995',
        gender: 'Male',
        bloodGroup: 'B+',
      );

      final records = [
        makeRecord(category: RecordCategory.vaccine, date: '01/03/2026'),
      ];

      final insights = InsightsEngine.generate(
        profile: profile,
        records: records,
        reminders: [],
      );

      expect(
        insights.any((i) => i.title.contains('checkup')),
        isTrue,
        reason: 'Should warn about missing annual checkup',
      );
    });

    test('returns overdue reminder warning when reminder is past due', () {
      final profile = makeProfile(
        dateOfBirth: '01/01/1995',
        gender: 'Male',
        bloodGroup: 'B+',
      );

      final records = [
        makeRecord(category: RecordCategory.vaccine, date: '01/03/2026'),
        makeRecord(category: RecordCategory.visit, date: '01/03/2026'),
      ];

      // reminder from yesterday, not done
      final reminders = [
        makeReminder(
          isDone: false,
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      final insights = InsightsEngine.generate(
        profile: profile,
        records: records,
        reminders: reminders,
      );

      expect(
        insights.any((i) => i.title.contains('overdue')),
        isTrue,
        reason: 'Should show overdue reminder warning',
      );
    });

    test('returns all good insight when everything is up to date', () {
      final profile = makeProfile(
        dateOfBirth: '01/01/1995',
        gender: 'Male',
        bloodGroup: 'B+',
      );

      // recent vaccine and visit records
      final now = DateTime.now();
      final recentDate =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      final records = [
        makeRecord(category: RecordCategory.vaccine, date: recentDate),
        makeRecord(category: RecordCategory.visit, date: recentDate),
      ];

      final insights = InsightsEngine.generate(
        profile: profile,
        records: records,
        reminders: [],
      );

      expect(
        insights.any((i) => i.type == InsightType.success),
        isTrue,
        reason: 'Should show success when everything is up to date',
      );
    });
  });
}
