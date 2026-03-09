import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/create_post_provider.dart';

class HabitSelector extends ConsumerWidget {
  const HabitSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHabit = ref.watch(createPostProvider).selectedHabit;

    return GestureDetector(
      onTap: () => _showHabitPicker(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2434),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedHabit ?? 'Select a habit',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  void _showHabitPicker(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual user habits from database
    // For now, using dummy data with fake IDs
    final habits = [
      {'id': '123e4567-e89b-12d3-a456-426614174001', 'name': 'Morning Workout 🏋️'},
      {'id': '123e4567-e89b-12d3-a456-426614174002', 'name': 'Reading 📚'},
      {'id': '123e4567-e89b-12d3-a456-426614174003', 'name': 'Meditation 🧘'},
      {'id': '123e4567-e89b-12d3-a456-426614174004', 'name': 'Journaling ✍️'},
      {'id': '123e4567-e89b-12d3-a456-426614174005', 'name': 'Running 🏃'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Habit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...habits.map(
              (habit) => ListTile(
                title: Text(
                  habit['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  ref.read(createPostProvider.notifier).selectHabit(
                        habit['name']!,
                        habit['id']!,
                      );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}