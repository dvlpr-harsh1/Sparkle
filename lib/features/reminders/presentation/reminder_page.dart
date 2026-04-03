import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sparkle/core/themes/app_theme.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_state.dart';
import 'package:sparkle/features/reminders/data/model/remider_model.dart';
import 'package:sparkle/features/reminders/presentation/add_reminder_page.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_event.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_state.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<ReminderBloc>(),
              child: const AddReminderPage(),
            ),
          ),
        ),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReminderFailure) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppTheme.danger),
              ),
            );
          }

          if (state is ReminderLoaded) {
            if (state.reminders.isEmpty) {
              return const _EmptyReminders();
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Overdue section
                if (state.overdue.isNotEmpty) ...[
                  _SectionHeader(title: 'Overdue', color: AppTheme.danger),
                  const SizedBox(height: 8),
                  ...state.overdue.map((r) => _ReminderTile(reminder: r)),
                  const SizedBox(height: 16),
                ],

                // Pending section
                if (state.pending.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Upcoming',
                    color: AppTheme.textPrimary,
                  ),
                  const SizedBox(height: 8),
                  ...state.pending
                      .where((r) => !r.isOverdue)
                      .map((r) => _ReminderTile(reminder: r)),
                  const SizedBox(height: 16),
                ],

                // Completed section
                if (state.completed.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Completed',
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  ...state.completed.map((r) => _ReminderTile(reminder: r)),
                ],
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  const _ReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          // red border if overdue, normal otherwise
          color: reminder.isOverdue
              ? AppTheme.danger.withOpacity(0.4)
              : const Color(0xFFE0E0F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // Checkbox to mark done
        leading: Checkbox(
          value: reminder.isDone,
          activeColor: AppTheme.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          onChanged: (val) {
            context.read<ReminderBloc>().add(
              ReminderToggleDone(
                userId: authState.user.uid,
                reminderId: reminder.id,
                isDone: val ?? false,
              ),
            );
          },
        ),
        title: Text(
          '${reminder.type.emoji} ${reminder.title}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
            // strikethrough if done
            decoration: reminder.isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              // Format DateTime to readable string
              DateFormat('dd MMM yyyy, hh:mm a').format(reminder.dateTime),
              style: TextStyle(
                fontSize: 12,
                color: reminder.isOverdue
                    ? AppTheme.danger
                    : AppTheme.textSecondary,
              ),
            ),
            if (reminder.notes.isNotEmpty)
              Text(
                reminder.notes,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            size: 20,
            color: AppTheme.danger,
          ),
          onPressed: () => _delete(context, authState.user.uid),
        ),
      ),
    );
  }

  void _delete(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete reminder'),
        content: Text('Delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ReminderBloc>().add(
                ReminderDeleted(userId: userId, reminderId: reminder.id),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReminders extends StatelessWidget {
  const _EmptyReminders();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 56,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tap + to add a medication or appointment reminder',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
