import 'package:sparkle/features/insights/data/models/insight_model.dart';
import 'package:sparkle/features/profile/data/model/user_model.dart';
import 'package:sparkle/features/records/data/model/health_records.dart';
import 'package:sparkle/features/records/data/model/record_category.dart';
import 'package:sparkle/features/reminders/data/model/remider_model.dart';

class InsightsEngine {
  
  static List<InsightModel> generate({
    required UserProfile profile,
    required List<HealthRecord> records,
    required List<ReminderModel> reminders,
  }) {
    final insights = <InsightModel>[];
    final now = DateTime.now();

    // Profile incomplete
    if (profile.completionPercentage < 1.0) {
      insights.add(const InsightModel(
        emoji: '👤',
        title: 'Complete your profile',
        description:
            'Add your date of birth, gender and blood group for better health insights.',
        type: InsightType.tip,
      ));
    }

    // No records
    if (records.isEmpty) {
      insights.add(const InsightModel(
        emoji: '📁',
        title: 'Start your health vault',
        description:
            'Add your first prescription, lab report or vaccination record.',
        type: InsightType.info,
      ));
      // r
      return insights;
    }

    final vaccineRecords = records
        .where((r) => r.category == RecordCategory.vaccine)
        .toList();

    if (vaccineRecords.isEmpty) {
      insights.add(const InsightModel(
        emoji: '💉',
        title: 'No vaccination records found',
        description:
            'Add your vaccination history to keep track of immunizations.',
        type: InsightType.warning,
      ));
    } else {
      // parse the recent vaccine date
      final lastVaccine = _mostRecentDate(vaccineRecords);
      if (lastVaccine != null) {
        final monthsSince =
            (now.difference(lastVaccine).inDays / 30).floor();
        if (monthsSince >= 12) {
          insights.add(InsightModel(
            emoji: '💉',
            title: 'Vaccination may be due',
            description:
                'Your last vaccination record is $monthsSince months old. Consider consulting your doctor.',
            type: InsightType.warning,
          ));
        }
      }
    }
    final visitRecords = records
        .where((r) => r.category == RecordCategory.visit)
        .toList();

    if (visitRecords.isEmpty) {
      insights.add(const InsightModel(
        emoji: '🏥',
        title: 'Annual checkup due',
        description:
            'No visit records found. Regular checkups help catch issues early.',
        type: InsightType.warning,
      ));
    } else {
      final lastVisit = _mostRecentDate(visitRecords);
      if (lastVisit != null) {
        final monthsSince =
            (now.difference(lastVisit).inDays / 30).floor();
        if (monthsSince >= 12) {
          insights.add(InsightModel(
            emoji: '🏥',
            title: 'Annual checkup due',
            description:
                'Your last visit was $monthsSince months ago. Consider scheduling a checkup.',
            type: InsightType.warning,
          ));
        }
      }
    }

    // Overdue reminders
    final overdueCount = reminders.where((r) => r.isOverdue).length;
    if (overdueCount > 0) {
      insights.add(InsightModel(
        emoji: '⏰',
        title: '$overdueCount overdue reminder${overdueCount > 1 ? 's' : ''}',
        description:
            'You have overdue medication or appointment reminders. Check your reminders tab.',
        type: InsightType.warning,
      ));
    }

    if (insights.isEmpty) {
      insights.add(const InsightModel(
        emoji: '✅',
        title: 'Everything looks good',
        description:
            'Your health records are up to date. Keep it up!',
        type: InsightType.success,
      ));
    }

    return insights;
  }

  static DateTime? _mostRecentDate(List<HealthRecord> records) {
    DateTime? mostRecent;

    for (final record in records) {
      try {
        final parts = record.date.split('/');
        if (parts.length != 3) continue;

        final date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]), 
          int.parse(parts[0]), 
        );

        if (mostRecent == null || date.isAfter(mostRecent)) {
          mostRecent = date;
        }
      } catch (_) {
        continue; 
      }
    }

    return mostRecent;
  }
}