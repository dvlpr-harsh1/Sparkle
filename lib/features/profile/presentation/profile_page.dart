import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkle/core/themes/app_theme.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_state.dart';
import 'package:sparkle/features/profile/data/model/user_model.dart';
import 'package:sparkle/features/profile/presentation/add_dependent_page.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_event.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_state.dart';
import 'package:sparkle/shared/widgets/dependent_list_tile.dart';
import 'package:sparkle/shared/widgets/spartkle_textfield.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton(
            onPressed: () => _showEditProfileSheet(context),
            child: const Text('Edit'),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileFailure) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppTheme.danger),
              ),
            );
          }

          if (state is ProfileLoaded) {
            return _ProfileContent(state: state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final state = context.read<ProfileBloc>().state;
    if (state is! ProfileLoaded) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: _EditProfileSheet(profile: state.profile),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileLoaded state;
  const _ProfileContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Profile completion card
        _CompletionCard(percentage: profile.completionPercentage),
        const SizedBox(height: 24),

        // Profile info
        _InfoCard(profile: profile),
        const SizedBox(height: 24),

        // Dependents
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dependents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: AddDependentPage(userId: profile.id),
                  ),
                ),
              ),

              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.dependents.isEmpty)
          const _EmptyDependents()
        else
          ...state.dependents.map(
            (d) => DependentListTile(
              dependent: d,
              onDelete: () => context.read<ProfileBloc>().add(
                ProfileDependentDeleted(userId: profile.id, dependentId: d.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final double percentage;
  const _CompletionCard({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile ${(percentage * 100).toInt()}% complete',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white,
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
          if (percentage < 1.0) ...[
            const SizedBox(height: 8),
            const Text(
              'Complete your profile for better insights',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final UserProfile profile;
  const _InfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0F0)),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Name', value: profile.name),
          _InfoRow(label: 'Email', value: profile.email),
          _InfoRow(label: 'Date of birth', value: profile.dateOfBirth ?? '—'),
          _InfoRow(label: 'Gender', value: profile.gender ?? '—'),
          _InfoRow(
            label: 'Blood group',
            value: profile.bloodGroup ?? '—',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFE0E0F0)),
      ],
    );
  }
}

class _EmptyDependents extends StatelessWidget {
  const _EmptyDependents();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.people_outline, size: 40, color: AppTheme.textSecondary),
          SizedBox(height: 8),
          Text(
            'No dependents added yet',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// Edit profile bottom sheet
class _EditProfileSheet extends StatefulWidget {
  final UserProfile profile;
  const _EditProfileSheet({required this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _dobController = TextEditingController(
    text: widget.profile.dateOfBirth ?? '',
  );
  String? _selectedGender;
  String? _selectedBloodGroup;

  final _genders = ['Male', 'Female', 'Other'];
  final _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.profile.gender;
    _selectedBloodGroup = widget.profile.bloodGroup;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
        ProfileUpdateRequested(
          widget.profile.copyWith(
            name: _nameController.text.trim(),
            dateOfBirth: _dobController.text.isEmpty
                ? null
                : _dobController.text,
            gender: _selectedGender,
            bloodGroup: _selectedBloodGroup,
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            SparkleTextField(
              label: 'Full name',
              controller: _nameController,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            SparkleTextField(
              label: 'Date of birth',
              hint: 'DD/MM/YYYY',
              controller: _dobController,
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            // Gender dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Blood group',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  hint: const Text('Select blood group'),
                  items: _bloodGroups
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedBloodGroup = v),
                  decoration: const InputDecoration(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Save changes')),
          ],
        ),
      ),
    );
  }
}
