import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/database/app_database.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final String? partnerNote;

  const HabitCard({super.key, required this.habit, required this.onToggle, this.partnerNote});

  String _getCategoryName(int index) {
    switch (index) {
      case 0:
        return 'hydration';
      case 1:
        return 'wellness';
      case 2:
        return 'learning';
      case 3:
        return 'movement';
      case 4:
        return 'rest';
      default:
        return 'custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = habit.currentCount >= habit.targetCount;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Color(habit.iconBg).withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(habit.emoji, style: TextStyle(fontSize: 24.sp)),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: GoogleFonts.baloo2(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isDone ? Colors.grey : const Color(0xFF3A2030),
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    '${_getCategoryName(habit.category)} · ${habit.streakCount} day streak',
                    style: GoogleFonts.nunito(fontSize: 12.sp, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  if (partnerNote != null) ...[
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(color: const Color(0xFFF2E8FF), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        partnerNote!,
                        style: GoogleFonts.nunito(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC07AD0),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _CheckIndicator(isDone: isDone),
          ],
        ),
      ).animate(target: isDone ? 1 : 0).shimmer(duration: 400.ms, color: Colors.white.withOpacity(0.5)),
    );
  }
}

class _CheckIndicator extends StatelessWidget {
  final bool isDone;

  const _CheckIndicator({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDone ? const LinearGradient(colors: [Color(0xFFE896B0), Color(0xFFC07AD0)]) : null,
            border: isDone ? null : Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: isDone ? Icon(Icons.check, size: 18.sp, color: Colors.white) : null,
        )
        .animate(target: isDone ? 1 : 0)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 200.ms, curve: Curves.bounceOut);
  }
}
