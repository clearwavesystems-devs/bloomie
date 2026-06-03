import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../cubit/adventure_cubit.dart';
import '../../cubit/adventure_state.dart';
import '../../models/adventure_content.dart';

class AdventureChallengeSheet extends StatelessWidget {
  final AdventureChallenge challenge;
  final dynamic currentLand;

  const AdventureChallengeSheet({
    super.key,
    required this.challenge,
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

          // Challenge header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (challenge.emoji != null) ...[
                Text(challenge.emoji!, style: TextStyle(fontSize: 32.sp)),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Text(
                  'Challenge Accepted!',
                  style: GoogleFonts.baloo2(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Challenge type badge
          _ChallengeTypeBadge(type: challenge.type),
          SizedBox(height: 20.h),

          // Question
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              challenge.question,
              style: GoogleFonts.nunito(
                fontSize: 15.sp,
                color: Colors.white,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),

          // Reward info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryPink.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(SolarIconsOutline.star, color: Colors.amber, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Rewards: +${challenge.xpReward} XP',
                  style: GoogleFonts.nunito(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (challenge.progressBonus != null) ...[
                  SizedBox(width: 16.w),
                  Icon(SolarIconsOutline.mapPoint, color: Colors.cyan, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    '+${challenge.progressBonus}% Progress',
                    style: GoogleFonts.nunito(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Options
          ...challenge.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _OptionButton(
              option: option,
              index: index,
              onPressed: () => _submitAnswer(context, option),
            );
          }),

          SizedBox(height: 16.h),

          // Cancel option
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Give Up',
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

  void _submitAnswer(BuildContext context, ChallengeOption option) {
    final cubit = context.read<AdventureCubit>();
    cubit.answerChallenge(option);
    Navigator.pop(context);

    // Show result
    final color = option.isCorrect ? Colors.green : Colors.red;
    final icon = option.isCorrect ? '✅' : '❌';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(icon, style: TextStyle(fontSize: 20)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                option.feedback ?? (option.isCorrect ? 'Correct!' : 'Not quite...'),
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
            ),
            if (option.isCorrect) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${cubit.state is AdventureLoaded ? (cubit.state as AdventureLoaded).currentLevel : 30} XP',
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
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _ChallengeTypeBadge extends StatelessWidget {
  final ChallengeType type;

  const _ChallengeTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bgColor;
    IconData icon;

    switch (type) {
      case ChallengeType.quiz:
        label = 'Quiz';
        bgColor = Colors.blue.withValues(alpha: 0.2);
        icon = SolarIconsOutline.notes;
        break;
      case ChallengeType.riddle:
        label = 'Riddle';
        bgColor = Colors.purple.withValues(alpha: 0.2);
        icon = SolarIconsOutline.lightbulb;
        break;
      case ChallengeType.wisdom:
        label = 'Wisdom';
        bgColor = Colors.amber.withValues(alpha: 0.2);
        icon = SolarIconsOutline.star;
        break;
      case ChallengeType.observation:
        label = 'Observation';
        bgColor = Colors.green.withValues(alpha: 0.2);
        icon = SolarIconsOutline.eye;
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

class _OptionButton extends StatelessWidget {
  final ChallengeOption option;
  final int index;
  final VoidCallback onPressed;

  const _OptionButton({
    required this.option,
    required this.index,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final letter = String.fromCharCode(65 + index); // A, B, C, D...

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Letter indicator
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: GoogleFonts.baloo2(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  option.text,
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
