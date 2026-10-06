import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../cubit/adventure_cubit.dart';
import '../../models/adventure_content.dart';

class AdventureEventSheet extends StatelessWidget {
  final AdventureEvent event;
  final dynamic currentLand;

  const AdventureEventSheet({
    super.key,
    required this.event,
    required this.currentLand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1040),
            const Color(0xFF2A1F45).withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24.h),

          // Event header with emoji
          if (event.emoji != null) ...[
            Text(event.emoji!, style: TextStyle(fontSize: 48.sp)),
            SizedBox(height: 12.h),
          ],

          // Event title
          Text(
            event.title,
            style: GoogleFonts.baloo2(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),

          // Event description
          Text(
            event.description,
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),

          // Event type badge
          _EventTypeBadge(type: event.type),
          SizedBox(height: 24.h),

          // Choices
          Text(
            'What do you do?',
            style: GoogleFonts.baloo2(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 16.h),

          ...event.choices.map((choice) => _ChoiceButton(
            choice: choice,
            onPressed: () => _makeChoice(context, choice),
          )),

          SizedBox(height: 16.h),

          // Skip option
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Leave',
              style: GoogleFonts.nunito(
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _makeChoice(BuildContext context, EventChoice choice) {
    context.read<AdventureCubit>().makeEventChoice(choice);
    Navigator.pop(context);

    // Show result snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (choice.emoji != null) ...[
              Text(choice.emoji!, style: TextStyle(fontSize: 20)),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Text(
                choice.resultText ?? 'You made your choice.',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
            ),
            if (choice.xpReward != null) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${choice.xpReward} XP',
                  style: GoogleFonts.nunito(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: const Color(0xFF1E1040),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _EventTypeBadge extends StatelessWidget {
  final EventType type;

  const _EventTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bgColor;
    IconData icon;

    switch (type) {
      case EventType.randomEncounter:
        label = 'Random Encounter';
        bgColor = Colors.amber.withValues(alpha: 0.2);
        icon = SolarIconsOutline.bolt;
        break;
      case EventType.discovery:
        label = 'Discovery';
        bgColor = Colors.cyan.withValues(alpha: 0.2);
        icon = SolarIconsOutline.mapPoint;
        break;
      case EventType.challenge:
        label = 'Challenge';
        bgColor = Colors.red.withValues(alpha: 0.2);
        icon = SolarIconsOutline.shield;
        break;
      case EventType.storyBeat:
        label = 'Story Moment';
        bgColor = Colors.purple.withValues(alpha: 0.2);
        icon = SolarIconsOutline.bookBookmark;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: Colors.white70),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final EventChoice choice;
  final VoidCallback onPressed;

  const _ChoiceButton({
    required this.choice,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasReward = (choice.xpReward ?? 0) > 0 || (choice.progressBonus ?? 0) > 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasReward
                  ? [
                      AppColors.primaryPink.withValues(alpha: 0.3),
                      AppColors.lavender.withValues(alpha: 0.3),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasReward
                  ? AppColors.primaryPink.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  choice.text,
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (choice.emoji != null) ...[
                SizedBox(width: 8.w),
                Text(choice.emoji!, style: TextStyle(fontSize: 18.sp)),
              ],
              if (hasReward) ...[
                SizedBox(width: 8.w),
                Icon(
                  SolarIconsOutline.star,
                  color: Colors.amber,
                  size: 18.sp,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
