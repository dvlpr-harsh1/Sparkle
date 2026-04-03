import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sparkle/core/themes/app_theme.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_state.dart';
import 'package:sparkle/features/profile/data/model/dependents_model.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_state.dart';
import 'package:sparkle/features/reminders/data/model/remider_model.dart';
import 'package:sparkle/features/reminders/data/model/remider_type.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_event.dart';
import 'package:sparkle/shared/widgets/spartkle_textfield.dart';
import 'package:uuid/uuid.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  ReminderType _selectedType = ReminderType.medication;
  DateTime? _selectedDateTime;
  String? _selectedDependentId;
  String _selectedDependentName = 'Myself';

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Opens date picker then time picker in sequence
  Future<void> _pickDateTime() async {
    // Step 1 — pick date
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return; // user cancelled

    // Step 2 — pick time
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return; // user cancelled

    // Combine date + time into single DateTime
    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;

      final reminder = ReminderModel(
        id: const Uuid().v4(),
        userId: authState.user.uid,
        dependentId: _selectedDependentId,
        title: _titleController.text.trim(),
        type: _selectedType,
        dateTime: _selectedDateTime!,
        notes: _notesController.text.trim(),
      );

      context.read<ReminderBloc>().add(ReminderAdded(reminder));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final dependents = profileState is ProfileLoaded
        ? profileState.dependents
        : <DependentModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Add reminder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Who is this for
              const Text(
                'This reminder is for',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDependentName,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: 'Myself',
                        child: Text('Myself'),
                      ),
                      ...dependents.map(
                        (d) => DropdownMenuItem(
                          value: d.name,
                          child: Text('${d.name} (${d.relation})'),
                        ),
                      ),
                    ],
                    onChanged: (name) {
                      if (name == null) return;
                      setState(() {
                        _selectedDependentName = name;
                        _selectedDependentId = name == 'Myself'
                            ? null
                            : dependents
                                .firstWhere((d) => d.name == name)
                                .id;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Reminder type
              const Text(
                'Type',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ReminderType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${type.emoji} ${type.label}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.white : AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              SparkleTextField(
                label: 'Title',
                hint: 'e.g. Take Paracetamol, Visit Dr. Mehta',
                controller: _titleController,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Date time picker
              const Text(
                'Date & time',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0F0)),
                  ),
                  child: Text(
                    _selectedDateTime != null
                        ? DateFormat('dd MMM yyyy, hh:mm a')
                            .format(_selectedDateTime!)
                        : 'Select date and time',
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedDateTime != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SparkleTextField(
                label: 'Notes (optional)',
                hint: 'Any additional notes...',
                controller: _notesController,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}