import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../models/adventure_content.dart';

class CollectibleFoundDialog extends StatelessWidget {
  final Collectible collectible;
  final int xpEarned;
  final VoidCallback onContinue;

  const CollectibleFoundDialog({
    super.key,
    required this.collectible,
    required this.xpEarned,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E1040),
              const Color(0xFF2A1F45).withValues(alpha: 0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryPink.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rarity stars
            _buildRarityStars(),
            SizedBox(height: 16.h),

            // Collectible emoji (animated)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPink.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        collectible.emoji,
                        style: TextStyle(fontSize: 48.sp),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),

            // "Found!" text
            Text(
              'You Found!',
              style: GoogleFonts.baloo2(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryPink,
              ),
            ),
            SizedBox(height: 8.h),

            // Collectible name
            Text(
              collectible.name,
              style: GoogleFonts.baloo2(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              collectible.description,
              style: GoogleFonts.nunito(
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),

            // XP reward
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPink, AppColors.lavender],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(SolarIconsOutline.star, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    '+$xpEarned XP',
                    style: GoogleFonts.baloo2(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
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
                  'Continue Exploring',
                  style: GoogleFonts.baloo2(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRarityStars() {
    final color = _getRarityColor();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        collectible.rarity,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Icon(
            SolarIconsBold.star,
            color: color,
            size: 16.sp,
          ),
        ),
      ),
    );
  }

  Color _getRarityColor() {
    switch (collectible.rarity) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
