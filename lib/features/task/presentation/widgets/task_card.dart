import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isTimerActive;
  final int elapsedSeconds;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onStartTimer;
  final VoidCallback onPauseTimer;
  final VoidCallback onStopTimer;

  const TaskCard({
    super.key,
    required this.task,
    this.isTimerActive = false,
    this.elapsedSeconds = 0,
    required this.onComplete,
    required this.onDelete,
    required this.onStartTimer,
    required this.onPauseTimer,
    required this.onStopTimer,
  });

  String _formatDuration(int totalSecs) {
    final hrs = totalSecs ~/ 3600;
    final mins = (totalSecs % 3600) ~/ 60;
    final secs = totalSecs % 60;

    if (hrs > 0) {
      return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDue = task.dueAt != null;
    final dueFormatted = hasDue ? DateFormat.yMMMd().add_jm().format(task.dueAt!) : '';

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onComplete();
        } else {
          onDelete();
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.w),
        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
        child: const Icon(SolarIconsOutline.checkCircle, color: Colors.green, size: 28),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(20)),
        child: const Icon(SolarIconsOutline.trashBinMinimalistic, color: Colors.red, size: 28),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(
            color: isTimerActive ? AppColors.primaryPink.withValues(alpha: 0.5) : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Completion Checkbox
                    GestureDetector(
                      onTap: onComplete,
                      child: Container(
                        width: 24.w,
                        height: 24.w,
                        margin: EdgeInsets.only(top: 2.h),
                        decoration: BoxDecoration(
                          color: task.completed ? AppColors.primaryPink : Colors.transparent,
                          border: Border.all(
                            color: task.completed ? AppColors.primaryPink : AppColors.textMuted,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: task.completed
                            ? const Icon(SolarIconsOutline.checkSquare, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: GoogleFonts.nunito(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: task.completed ? AppColors.textMuted : AppColors.textDark,
                              decoration: task.completed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (task.description != null && task.description!.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              task.description!,
                              style: GoogleFonts.nunito(fontSize: 13.sp, color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Timer Button / Controls
                    if (!task.completed) ...[
                      if (isTimerActive)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: onPauseTimer,
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(color: AppColors.lavLight, shape: BoxShape.circle),
                                child: const Icon(SolarIconsOutline.pause, size: 16, color: AppColors.lavender),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            GestureDetector(
                              onTap: onStopTimer,
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(color: AppColors.pinkLight, shape: BoxShape.circle),
                                child: const Icon(SolarIconsOutline.stop, size: 16, color: AppColors.primaryPink),
                              ),
                            ),
                          ],
                        )
                      else
                        GestureDetector(
                          onTap: onStartTimer,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppColors.creamBg,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.pinkLight),
                            ),
                            child: const Icon(SolarIconsOutline.play, size: 18, color: AppColors.primaryPink),
                          ),
                        ),
                    ],
                  ],
                ),

                // Running Timer Overlay
                if (isTimerActive && !task.completed) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.pinkLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _PulsingDot(),
                            SizedBox(width: 8.w),
                            Text(
                              'Time Tracking Running',
                              style: GoogleFonts.nunito(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryPink,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatDuration(elapsedSeconds),
                          style: GoogleFonts.baloo2(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Metadata details
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left chips (XP & Blooms)
                    Row(
                      children: [
                        _BadgeChip(
                          icon: '✨',
                          text: '+${task.xpReward} XP',
                          color: AppColors.lavLight,
                          textColor: AppColors.lavender,
                        ),
                        SizedBox(width: 6.w),
                        _BadgeChip(
                          icon: '🌸',
                          text: '+${task.bloomReward}',
                          color: AppColors.pinkLight,
                          textColor: AppColors.primaryPink,
                        ),
                        if (task.estimatedMinutes != null) ...[
                          SizedBox(width: 6.w),
                          _BadgeChip(
                            icon: '⏱️',
                            text: '${task.estimatedMinutes}m',
                            color: AppColors.creamBg,
                            textColor: AppColors.textDark,
                          ),
                        ],
                      ],
                    ),

                    // Right Due Date Chip
                    if (hasDue)
                      Text(
                        dueFormatted,
                        style: GoogleFonts.nunito(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: task.completed ? AppColors.textMuted : AppColors.primaryPink,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String icon;
  final String text;
  final Color color;
  final Color textColor;

  const _BadgeChip({required this.icon, required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: 10.sp)),
          SizedBox(width: 4.w),
          Text(
            text,
            style: GoogleFonts.nunito(fontSize: 11.sp, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: const BoxDecoration(color: AppColors.primaryPink, shape: BoxShape.circle),
      ),
    );
  }
}
