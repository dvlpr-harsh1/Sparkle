import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkle/core/themes/app_theme.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_state.dart';
import 'package:sparkle/features/profile/data/model/dependents_model.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_state.dart';
import 'package:sparkle/features/records/data/model/health_records.dart';
import 'package:sparkle/features/records/data/model/record_category.dart';
import 'package:sparkle/features/records/presentation/bloc/record_bloc.dart';
import 'package:sparkle/features/records/presentation/bloc/record_event.dart';
import 'package:sparkle/shared/widgets/spartkle_textfield.dart';
import 'package:uuid/uuid.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();

  final _medicineNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _labNameController = TextEditingController();
  final _vaccineNameController = TextEditingController();
  final _diagnosisController = TextEditingController();

  RecordCategory _selectedCategory = RecordCategory.prescription;

  String? _selectedDependentId;
  String _selectedDependentName = 'Myself';

  @override
  void dispose() {
    _providerController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _medicineNameController.dispose();
    _dosageController.dispose();
    _labNameController.dispose();
    _vaccineNameController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;
      final Map<String, dynamic> details = switch (_selectedCategory) {
        RecordCategory.prescription => {
            'medicineName': _medicineNameController.text.trim(),
            'dosage': _dosageController.text.trim(),
          },
        RecordCategory.lab => {
            'labName': _labNameController.text.trim(),
          },
        RecordCategory.vaccine => {
            'vaccineName': _vaccineNameController.text.trim(),
          },
        RecordCategory.visit => {
            'diagnosis': _diagnosisController.text.trim(),
          },
      };

      final record = HealthRecord(
        id: const Uuid().v4(),
        userId: authState.user.uid,
        dependentId: _selectedDependentId,
        category: _selectedCategory,
        date: _dateController.text.trim(),
        provider: _providerController.text.trim(),
        notes: _notesController.text.trim(),
        details: details,
      );

      context.read<RecordBloc>().add(RecordAdded(record));
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
      appBar: AppBar(title: const Text('Add record')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This record is for',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _WhoSelector(
                selectedName: _selectedDependentName,
                dependents: dependents,
                onSelected: (id, name) => setState(() {
                  _selectedDependentId = id;
                  _selectedDependentName = name;
                }),
              ),

              const SizedBox(height: 20),

              // CATEGORY
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RecordCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
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
                        '${category.emoji} ${category.label}',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isSelected ? Colors.white : AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              _CategoryFields(
                category: _selectedCategory,
                medicineNameController: _medicineNameController,
                dosageController: _dosageController,
                labNameController: _labNameController,
                vaccineNameController: _vaccineNameController,
                diagnosisController: _diagnosisController,
              ),

              const SizedBox(height: 16),

              SparkleTextField(
                label: 'Provider / Doctor',
                hint: 'e.g. Dr. Mehta, City Hospital',
                controller: _providerController,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Provider is required' : null,
              ),
              const SizedBox(height: 16),
              SparkleTextField(
                label: 'Date',
                hint: 'DD/MM/YYYY',
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Date is required' : null,
              ),
              const SizedBox(height: 16),
              SparkleTextField(
                label: 'Notes',
                hint: 'Any additional notes...',
                controller: _notesController,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhoSelector extends StatelessWidget {
  final String selectedName;
  final List<DependentModel> dependents;
  final void Function(String? id, String name) onSelected;

  const _WhoSelector({
    required this.selectedName,
    required this.dependents,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedName,
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
            if (name == 'Myself') {
              onSelected(null, 'Myself');
            } else {
              final dep = dependents.firstWhere((d) => d.name == name);
              onSelected(dep.id, dep.name);
            }
          },
        ),
      ),
    );
  }
}

class _CategoryFields extends StatelessWidget {
  final RecordCategory category;
  final TextEditingController medicineNameController;
  final TextEditingController dosageController;
  final TextEditingController labNameController;
  final TextEditingController vaccineNameController;
  final TextEditingController diagnosisController;

  const _CategoryFields({
    required this.category,
    required this.medicineNameController,
    required this.dosageController,
    required this.labNameController,
    required this.vaccineNameController,
    required this.diagnosisController,
  });

  @override
  Widget build(BuildContext context) {
    return switch (category) {
      RecordCategory.prescription => Column(
          children: [
            SparkleTextField(
              label: 'Medicine name',
              hint: 'e.g. Paracetamol 500mg',
              controller: medicineNameController,
            ),
            const SizedBox(height: 16),
            SparkleTextField(
              label: 'Dosage & frequency',
              hint: 'e.g. 1 tablet twice daily',
              controller: dosageController,
            ),
            const SizedBox(height: 16),
          ],
        ),
      RecordCategory.lab => Column(
          children: [
            SparkleTextField(
              label: 'Lab / Test name',
              hint: 'e.g. CBC, Blood Sugar, Lipid Panel',
              controller: labNameController,
            ),
            const SizedBox(height: 16),
          ],
        ),
      RecordCategory.vaccine => Column(
          children: [
            SparkleTextField(
              label: 'Vaccine name',
              hint: 'e.g. Covid-19, Hepatitis B',
              controller: vaccineNameController,
            ),
            const SizedBox(height: 16),
          ],
        ),
      RecordCategory.visit => Column(
          children: [
            SparkleTextField(
              label: 'Diagnosis / Reason for visit',
              hint: 'e.g. Fever, Annual checkup',
              controller: diagnosisController,
            ),
            const SizedBox(height: 16),
          ],
        ),
    };
  }
}