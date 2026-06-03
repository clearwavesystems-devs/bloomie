import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../models/adventure_content.dart';

class LoreUnlockedSheet extends StatelessWidget {
  final LoreEntry lore;
  final String landId;
  final VoidCallback onContinue;

  const LoreUnlockedSheet({
    super.key,
    required this.lore,
    required this.landId,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1040),
            const Color(0xFF2A1F45).withValues(alpha: 0.9),
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

          // Lore unlocked header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (lore.emoji != null) ...[
                Text(lore.emoji!, style: TextStyle(fontSize: 32.sp)),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Text(
                  'Lore Discovered!',
                  style: GoogleFonts.baloo2(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPink,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Lore entry card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryPink.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  lore.title,
                  style: GoogleFonts.baloo2(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),

                // Content
                Text(
                  lore.content,
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Progress indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SolarIconsOutline.mapPoint,
                  color: AppColors.primaryPink,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Unlocked at ${lore.requiredProgress}% exploration',
                  style: GoogleFonts.nunito(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Continue button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                onContinue();
              },
              child: Text(
                'Continue Journey',
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
