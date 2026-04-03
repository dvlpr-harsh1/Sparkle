import 'package:flutter/material.dart';
import 'package:sparkle/core/themes/app_theme.dart';
import 'package:sparkle/features/profile/data/model/dependents_model.dart';

class DependentListTile extends StatelessWidget {
  final DependentModel dependent;
  final VoidCallback onDelete;

  const DependentListTile({
    super.key,
    required this.dependent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryLight,
            child: Text(
              dependent.name[0].toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dependent.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  dependent.relation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppTheme.danger, size: 20),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog( // ← use dialogContext
      title: const Text('Remove dependent'),
      content: Text('Remove ${dependent.name} from your dependents?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(), // ✅
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(); // ✅
            onDelete();
          },
          child: const Text(
            'Remove',
            style: TextStyle(color: AppTheme.danger),
          ),
        ),
      ],
    ),
  );
}
}