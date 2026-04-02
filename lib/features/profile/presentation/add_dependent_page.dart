import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkle/core/themes/app_theme.dart';
import 'package:sparkle/features/profile/data/model/dependents_model.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_event.dart';
import 'package:sparkle/shared/widgets/spartkle_textfield.dart';
import 'package:uuid/uuid.dart';

class AddDependentPage extends StatefulWidget {
  final String userId;
  const AddDependentPage({super.key, required this.userId});

  @override
  State<AddDependentPage> createState() => _AddDependentPageState();
}

class _AddDependentPageState extends State<AddDependentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedRelation;
  String? _selectedGender;

  final _relations = ['Spouse', 'Child', 'Parent', 'Sibling', 'Other'];
  final _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final dependent = DependentModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        relation: _selectedRelation!,
        dateOfBirth: _dobController.text.isEmpty ? null : _dobController.text,
        gender: _selectedGender,
      );
      context.read<ProfileBloc>().add(
            ProfileDependentAdded(
              userId: widget.userId,
              dependent: dependent,
            ),
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add dependent')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SparkleTextField(
                label: 'Full name',
                hint: 'Dependent\'s name',
                controller: _nameController,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Relation',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedRelation,
                hint: const Text('Select relation'),
                items: _relations
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRelation = v),
                validator: (v) => v == null ? 'Please select a relation' : null,
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),
              SparkleTextField(
                label: 'Date of birth',
                hint: 'DD/MM/YYYY',
                controller: _dobController,
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: const Text('Select gender'),
                items: _genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add dependent'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}