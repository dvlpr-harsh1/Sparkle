import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkle/core/themes/app_theme.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_state.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_state.dart';
import 'package:sparkle/features/records/data/model/health_records.dart';
import 'package:sparkle/features/records/data/model/record_category.dart';
import 'package:sparkle/features/records/presentation/bloc/record_bloc.dart';
import 'package:sparkle/features/records/presentation/bloc/record_event.dart';

class RecordCard extends StatelessWidget {
  final HealthRecord record;
  const RecordCard({super.key, required this.record});

  String _getOwnerName(BuildContext context) {
    if (record.dependentId == null) return 'Myself';

    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      final dependent = profileState.dependents
          .where((d) => d.id == record.dependentId)
          .firstOrNull;
      return dependent?.name ?? 'Unknown';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${record.category.emoji} ${record.category.label}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              // Share toggle
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  record.isShared ? Icons.share : Icons.share_outlined,
                  size: 20,
                  color: record.isShared
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
                onPressed: () => _toggleShare(context),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppTheme.danger,
                ),
                onPressed: () => _delete(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Provider name
          Text(
            record.provider,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Date
          Text(
            record.date,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'For: ${_getOwnerName(context)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          // Category
          if (record.details.isNotEmpty && _detailSummary().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _detailSummary(),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Notes
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              record.notes,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Shared indicator
          if (record.isShared) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppTheme.success,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Shared with caregiver',
                  style: TextStyle(fontSize: 12, color: AppTheme.success),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _detailSummary() {
    return switch (record.category) {
      RecordCategory.prescription =>
        record.details['medicineName']?.toString().isNotEmpty == true
            ? '💊 ${record.details['medicineName']} — ${record.details['dosage'] ?? ''}'
            : '',
      RecordCategory.lab =>
        record.details['labName']?.toString().isNotEmpty == true
            ? '🧪 ${record.details['labName']}'
            : '',
      RecordCategory.vaccine =>
        record.details['vaccineName']?.toString().isNotEmpty == true
            ? '💉 ${record.details['vaccineName']}'
            : '',
      RecordCategory.visit =>
        record.details['diagnosis']?.toString().isNotEmpty == true
            ? '🏥 ${record.details['diagnosis']}'
            : '',
    };
  }

  void _toggleShare(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<RecordBloc>().add(
      RecordSharingUpdated(
        userId: authState.user.uid,
        recordId: record.id,
        isShared: !record.isShared,
        sharedWith: record.sharedWith,
      ),
    );
  }

  void _delete(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete record'),
        content: const Text('This record will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<RecordBloc>().add(
                RecordDeleted(userId: authState.user.uid, recordId: record.id),
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
