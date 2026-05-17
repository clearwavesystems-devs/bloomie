import 'package:bloomie/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../cubit/habits_cubit.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '🌸';
  int _selectedCategoryIndex = 1; // wellness
  final int _targetCount = 1;
  bool _isShared = false;
  Color _selectedColor = AppColors.pinkLight;

  final List<String> _emojis = ['🌸', '🧘', '💧', '🚶', '📖', '✍️', '🥦', '☕', '🛌', '🧹'];
  final List<Color> _colors = [
    AppColors.pinkLight,
    AppColors.lavLight,
    AppColors.peach,
    const Color(0xFFE0F7FA),
    const Color(0xFFF1F8E9),
    const Color(0xFFFFFDE7),
  ];

  final List<String> _categories = ['hydration', 'wellness', 'learning', 'movement', 'rest', 'custom'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Habit Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Choose Emoji', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _emojis
                  .map(
                    (e) => GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = e),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedEmoji == e
                              ? AppColors.primaryPink.withValues(alpha: 0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Icon Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: _colors
                  .map(
                    (color) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color ? AppColors.primaryPink : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: List.generate(
                _categories.length,
                (index) => ChoiceChip(
                  label: Text(_categories[index]),
                  selected: _selectedCategoryIndex == index,
                  onSelected: (val) => setState(() => _selectedCategoryIndex = index),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Share with Partner'),
              value: _isShared,
              onChanged: (val) => setState(() => _isShared = val),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    final habit = Habit(
                      id: const Uuid().v4(),
                      name: _nameController.text,
                      emoji: _selectedEmoji,
                      category: _selectedCategoryIndex,
                      frequency: 0, // daily
                      customDays: '[]',
                      isSharedWithPartner: _isShared,
                      iconBg: _selectedColor.value,
                      createdAt: DateTime.now(),
                      isArchived: false,
                      currentCount: 0,
                      targetCount: _targetCount,
                      streakCount: 0,
                      longestStreak: 0,
                      xpReward: 50,
                    );
                    context.read<HabitsCubit>().addHabit(habit);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Habit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
