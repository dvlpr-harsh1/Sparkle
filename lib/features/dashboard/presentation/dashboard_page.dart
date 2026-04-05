import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sparkle/core/themes/app_theme.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_event.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_state.dart';
import 'package:sparkle/features/records/data/model/health_records.dart';
import 'package:sparkle/features/records/presentation/bloc/record_bloc.dart';
import 'package:sparkle/features/records/presentation/bloc/record_state.dart';
import 'package:sparkle/features/reminders/data/model/remider_model.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_state.dart';

import '../../insights/data/insight_engine.dart';
import '../../insights/data/models/insight_model.dart';
import '../../profile/data/model/user_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final recordState = context.watch<RecordBloc>().state;
    final reminderState = context.watch<ReminderBloc>().state;

    final profile = profileState is ProfileLoaded ? profileState.profile : null;
    final records = recordState is RecordLoaded
        ? recordState.records
        : <HealthRecord>[];
    final reminders = reminderState is ReminderLoaded
        ? reminderState.reminders
        : <ReminderModel>[];
    final upcomingReminders = reminderState is ReminderLoaded
        ? reminderState.upcoming
        : <ReminderModel>[];

    final insights = profile != null
        ? InsightsEngine.generate(
            profile: profile,
            records: records,
            reminders: reminders,
          )
        : <InsightModel>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sparkle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
        ],
      ),
      body: profileState is ProfileLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Greeting
                _GreetingCard(profile: profile),
                const SizedBox(height: 20),

                // Profile completion
                if (profile != null && profile.completionPercentage < 1.0) ...[
                  _CompletionBanner(percentage: profile.completionPercentage),
                  const SizedBox(height: 20),
                ],

                // Status snapshot row
                _StatusRow(
                  recordCount: records.length,
                  reminderCount: upcomingReminders.length,
                  dependentCount: profileState is ProfileLoaded
                      ? profileState.dependents.length
                      : 0,
                ),
                const SizedBox(height: 24),

                // Upcoming reminders
                if (upcomingReminders.isNotEmpty) ...[
                  _SectionTitle(
                    title: 'Upcoming reminders',
                    onTap: () => context.go('/reminders'),
                  ),
                  const SizedBox(height: 10),
                  ...upcomingReminders
                      .take(3)
                      .map((r) => _ReminderItem(reminder: r)),
                  const SizedBox(height: 24),
                ],

                // Recent records
                if (records.isNotEmpty) ...[
                  _SectionTitle(
                    title: 'Recent records',
                    onTap: () => context.go('/records'),
                  ),
                  const SizedBox(height: 10),
                  ...records.take(3).map((r) => _RecordItem(record: r)),
                  const SizedBox(height: 24),
                ],

                // Sparkle Insights
                _SectionTitle(
                  title: 'Sparkle Insights',
                  subtitle: 'Informational only — not medical advice',
                ),
                const SizedBox(height: 10),
                ...insights.map((i) => _InsightCard(insight: i)),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

// Top Greeting
class _GreetingCard extends StatelessWidget {
  final UserProfile? profile;
  const _GreetingCard({required this.profile});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greeting()},',
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        Text(
          profile?.name ?? 'there',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          DateFormat('EEEE, dd MMMM').format(DateTime.now()),
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

// Profile completion banner
class _CompletionBanner extends StatelessWidget {
  final double percentage;
  const _CompletionBanner({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile ${(percentage * 100).toInt()}% complete',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.white,
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: const Text(
              'Complete',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final int recordCount;
  final int reminderCount;
  final int dependentCount;

  const _StatusRow({
    required this.recordCount,
    required this.reminderCount,
    required this.dependentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusCard(
          count: recordCount,
          label: 'Records',
          emoji: '📁',
          onTap: () => context.go('/records'),
        ),
        const SizedBox(width: 10),
        _StatusCard(
          count: reminderCount,
          label: 'Upcoming',
          emoji: '⏰',
          onTap: () => context.go('/reminders'),
        ),
        const SizedBox(width: 10),
        _StatusCard(
          count: dependentCount,
          label: 'Dependents',
          emoji: '👨‍👩‍👧',
          onTap: () => context.go('/profile'),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final int count;
  final String label;
  final String emoji;
  final VoidCallback onTap;

  const _StatusCard({
    required this.count,
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E0F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SectionTitle({required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'See all',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// Upcoming reminder item
class _ReminderItem extends StatelessWidget {
  final ReminderModel reminder;
  const _ReminderItem({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0F0)),
      ),
      child: Row(
        children: [
          Text(reminder.type.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('dd MMM, hh:mm a').format(reminder.dateTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Recent record item
class _RecordItem extends StatelessWidget {
  final HealthRecord record;
  const _RecordItem({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0F0)),
      ),
      child: Row(
        children: [
          Text(record.category.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.provider,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${record.category.label} • ${record.date}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Insight card
class _InsightCard extends StatelessWidget {
  final InsightModel insight;
  const _InsightCard({required this.insight});

  Color get _bgColor {
    return switch (insight.type) {
      InsightType.warning => const Color(0xFFFFF3E0),
      InsightType.info => const Color(0xFFE3F2FD),
      InsightType.success => const Color(0xFFE8F5E9),
      InsightType.tip => AppTheme.primaryLight,
    };
  }

  Color get _textColor {
    return switch (insight.type) {
      InsightType.warning => const Color(0xFFE65100),
      InsightType.info => const Color(0xFF0D47A1),
      InsightType.success => AppTheme.success,
      InsightType.tip => AppTheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: _textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
