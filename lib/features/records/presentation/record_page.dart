import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkle/core/themes/app_theme.dart';
import 'package:sparkle/features/records/data/model/record_category.dart';
import 'package:sparkle/features/records/presentation/add_record_page.dart';
import 'package:sparkle/features/records/presentation/bloc/record_bloc.dart';
import 'package:sparkle/features/records/presentation/bloc/record_state.dart';
import 'package:sparkle/shared/widgets/record_card.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  RecordCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Records')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<RecordBloc>(),
              child: const AddRecordPage(),
            ),
          ),
        ),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Category filter chips
          _CategoryFilter(
            selected: _selectedCategory,
            onSelected: (category) =>
                setState(() => _selectedCategory = category),
          ),
          Expanded(
            child: BlocBuilder<RecordBloc, RecordState>(
              builder: (context, state) {
                if (state is RecordLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RecordFailure) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppTheme.danger),
                    ),
                  );
                }

                if (state is RecordLoaded) {
                  final records = _selectedCategory != null
                      ? state.byCategory(_selectedCategory!)
                      : state.records;

                  if (records.isEmpty) {
                    return const _EmptyRecords();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: records.length,
                    itemBuilder: (_, i) => RecordCard(record: records[i]),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final RecordCategory? selected;
  final void Function(RecordCategory?) onSelected;

  const _CategoryFilter({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // "All" chip
          FilterChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
            selectedColor: AppTheme.primaryLight,
            checkmarkColor: AppTheme.primary,
          ),
          const SizedBox(width: 8),
          // One chip per category
          ...RecordCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${category.emoji} ${category.label}'),
                selected: selected == category,
                onSelected: (_) =>
                    onSelected(selected == category ? null : category),
                selectedColor: AppTheme.primaryLight,
                checkmarkColor: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 56,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'No records yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tap + to add your first health record',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
