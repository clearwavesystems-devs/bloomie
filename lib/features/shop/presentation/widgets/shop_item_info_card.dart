import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../models/accessory_effects.dart';

class ShopItemInfoCard extends StatelessWidget {
  final String itemId;
  final String name;
  final String description;
  final String category;
  final int price;
  final bool owned;

  const ShopItemInfoCard({
    super.key,
    required this.itemId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.owned,
  });

  @override
  Widget build(BuildContext context) {
    final effects = AccessoryEffects.getEffects(itemId);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                name,
                style: GoogleFonts.baloo2(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: owned ? Colors.green.withValues(alpha: 0.1) : AppColors.pinkLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: owned ? Colors.green : AppColors.primaryPink,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  owned ? 'Owned' : '$price 🌸',
                  style: GoogleFonts.nunito(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: owned ? Colors.green : AppColors.primaryPink,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Description
          if (description.isNotEmpty) ...[
            Text(
              description,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                color: AppColors.textDark.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
          ],

          // Special Effects
          if (effects.isNotEmpty) ...[
            Text(
              '✨ Special Effects',
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryPink,
              ),
            ),
            SizedBox(height: 12.h),
            ...effects.map((effect) => _EffectTile(effect: effect)),
            SizedBox(height: 20.h),
          ],

          // Category info
          Row(
            children: [
              Icon(
                SolarIconsOutline.tag,
                color: AppColors.textMuted,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                _getCategoryLabel(category),
                style: GoogleFonts.nunito(
                  fontSize: 12.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'pet_accessory':
        return 'Pet Accessory';
      case 'plant_skin':
        return 'Garden Skin';
      case 'adventure_key':
        return 'Adventure Key';
      default:
        return category;
    }
  }
}

class _EffectTile extends StatelessWidget {
  final AccessoryEffect effect;

  const _EffectTile({required this.effect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.pinkLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPink.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          if (effect.icon != null) ...[
            Text(
              effect.icon!,
              style: TextStyle(fontSize: 20.sp),
            ),
            SizedBox(width: 12.w),
          ],
          Icon(
            _getEffectIcon(effect.type),
            color: AppColors.primaryPink,
            size: 18.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effect.name,
                  style: GoogleFonts.nunito(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  effect.description,
                  style: GoogleFonts.nunito(
                    fontSize: 11.sp,
                    color: AppColors.textDark.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEffectIcon(AccessoryType type) {
    switch (type) {
      case AccessoryType.xpBoost:
        return SolarIconsOutline.star;
      case AccessoryType.bloomBoost:
        return SolarIconsOutline.leaf;
      case AccessoryType.streakProtection:
        return SolarIconsOutline.shield;
      case AccessoryType.moodBoost:
        return SolarIconsOutline.addCircle;
      case AccessoryType.gardenGrowth:
        return SolarIconsOutline.altArrowUp;
      case AccessoryType.duoBonus:
        return SolarIconsOutline.heart;
      case AccessoryType.hintAbility:
        return SolarIconsOutline.lightbulb;
      case AccessoryType.masteryBonus:
        return SolarIconsOutline.star;
      case AccessoryType.spookyCharm:
        return SolarIconsOutline.moon;
      case AccessoryType.festiveCheer:
        return SolarIconsOutline.snowflake;
    }
  }
}
