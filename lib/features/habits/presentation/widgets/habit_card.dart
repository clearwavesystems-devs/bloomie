import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final String? partnerNote;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    this.partnerNote,
  });

  String _getCategoryName(int index) {
    switch (index) {
      case 0: return 'hydration';
      case 1: return 'wellness';
      case 2: return 'learning';
      case 3: return 'movement';
      case 4: return 'rest';
      default: return 'custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = habit.currentCount >= habit.targetCount;
    
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryPink.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(habit.iconBg),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  habit.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDone ? AppColors.textMuted : AppColors.textDark,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    '${_getCategoryName(habit.category)} · ${habit.streakCount} day streak',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (partnerNote != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.lavLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        partnerNote!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lavender,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _CheckIndicator(isDone: isDone),
          ],
        ),
      ).animate(target: isDone ? 1 : 0)
       .shimmer(duration: 400.ms, color: Colors.white.withOpacity(0.5)),
    );
  }
}

class _CheckIndicator extends StatelessWidget {
  final bool isDone;

  const _CheckIndicator({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isDone 
          ? const LinearGradient(colors: [AppColors.primaryPink, AppColors.lavender])
          : null,
        border: isDone ? null : Border.all(color: AppColors.textMuted.withOpacity(0.3), width: 2),
      ),
      child: isDone 
        ? const Icon(Icons.check, size: 16, color: Colors.white)
        : null,
    ).animate(target: isDone ? 1 : 0)
     .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 200.ms, curve: Curves.bounceOut);
  }
}
