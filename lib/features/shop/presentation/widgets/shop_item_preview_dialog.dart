import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../models/accessory_effects.dart';

class ShopItemPreviewDialog extends StatefulWidget {
  final String itemId;
  final String name;
  final String emoji;
  final int price;
  final String category;
  final String description;
  final VoidCallback onBuy;
  final VoidCallback onEquip;
  final bool owned;
  final bool equipped;

  const ShopItemPreviewDialog({
    super.key,
    required this.itemId,
    required this.name,
    required this.emoji,
    required this.price,
    required this.category,
    this.description = '',
    required this.onBuy,
    required this.onEquip,
    this.owned = false,
    this.equipped = false,
  });

  @override
  State<ShopItemPreviewDialog> createState() => _ShopItemPreviewDialogState();
}

class _ShopItemPreviewDialogState extends State<ShopItemPreviewDialog> {
  bool _isConfirming = false;

  @override
  Widget build(BuildContext context) {
    final effects = AccessoryEffects.getEffects(widget.itemId);
    final isAccessory = widget.category == 'pet_accessory';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20.h),

              if (!_isConfirming) ...[
                // Item emoji
                Hero(
                  tag: 'shop_item_${widget.itemId}',
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: AppColors.pinkLight.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.emoji,
                      style: TextStyle(fontSize: 48.sp),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Item name
                Text(
                  widget.name,
                  style: GoogleFonts.baloo2(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),

                // Category badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(widget.category),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getCategoryLabel(widget.category),
                    style: GoogleFonts.nunito(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Description
                if (widget.description.isNotEmpty) ...[
                  Text(
                    widget.description,
                    style: GoogleFonts.nunito(
                      fontSize: 13.sp,
                      color: AppColors.textDark.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
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
                  ...effects.map((effect) => _buildEffectChip(effect: effect)),
                  SizedBox(height: 20.h),
                ],

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Price: ',
                      style: GoogleFonts.nunito(
                        fontSize: 14.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${widget.price} 🌸',
                      style: GoogleFonts.baloo2(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryPink,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Action buttons
                if (widget.owned) ...[
                  if (isAccessory) ...[
                    // Accessories can be equipped/unequipped
                    if (widget.equipped) ...[
                      _buildSecondaryButton(
                        'Unequip',
                        SolarIconsOutline.logout,
                        () {
                          Navigator.pop(context);
                          widget.onEquip();
                        },
                        color: Colors.grey,
                      ),
                    ] else ...[
                      _buildPrimaryButton(
                        'Equip',
                        SolarIconsOutline.checkSquare,
                        () {
                          Navigator.pop(context);
                          widget.onEquip();
                        },
                      ),
                    ],
                  ] else ...[
                    // Other items can't be unequipped
                    _buildPrimaryButton(
                      'Equipped',
                      SolarIconsOutline.checkSquare,
                      () => Navigator.pop(context),
                      enabled: false,
                    ),
                  ],
                ] else ...[
                  // Not owned - can buy
                  Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton(
                          'Cancel',
                          SolarIconsOutline.closeCircle,
                          () => Navigator.pop(context),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildPrimaryButton(
                          'Buy Now',
                          SolarIconsOutline.shop,
                          () {
                            setState(() {
                              _isConfirming = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                // Confirmation screen
                Text(
                  'Confirm Purchase 🛍️',
                  style: GoogleFonts.baloo2(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Are you sure you want to purchase',
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.emoji,
                      style: TextStyle(fontSize: 24.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      widget.name,
                      style: GoogleFonts.baloo2(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'for ',
                      style: GoogleFonts.nunito(
                        fontSize: 14.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${widget.price} Blooms 🌸',
                      style: GoogleFonts.baloo2(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryPink,
                      ),
                    ),
                    Text(
                      '?',
                      style: GoogleFonts.nunito(
                        fontSize: 14.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildSecondaryButton(
                        'Back',
                        SolarIconsOutline.arrowLeft,
                        () {
                          setState(() {
                            _isConfirming = false;
                          });
                        },
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildPrimaryButton(
                        'Confirm',
                        SolarIconsOutline.checkSquare,
                        () {
                          Navigator.pop(context);
                          widget.onBuy();
                        },
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    String text,
    IconData icon,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: enabled ? onPressed : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              text,
              style: GoogleFonts.baloo2(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    String text,
    IconData icon,
    VoidCallback onPressed, {
    Color color = AppColors.textDark,
  }) {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              text,
              style: GoogleFonts.baloo2(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectChip({required AccessoryEffect effect}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.pinkLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryPink.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (effect.icon != null) ...[
            Text(effect.icon!, style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 6.w),
          ],
          Icon(
            _getEffectTypeIcon(effect.type),
            color: AppColors.primaryPink,
            size: 14.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            effect.name,
            style: GoogleFonts.nunito(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEffectTypeIcon(AccessoryType type) {
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
      case AccessoryType.spookyCharm:
        return SolarIconsOutline.moon;
      case AccessoryType.festiveCheer:
        return SolarIconsOutline.snowflake;
      default:
        return SolarIconsOutline.star;
    }
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'pet_accessory':
        return const Color(0xFFFFB6C1); // Pink
      case 'plant_skin':
        return const Color(0xFF81C784); // Green
      case 'adventure_key':
        return const Color(0xFF9C27B0); // Blue
      default:
        return Colors.grey;
    }
  }
}
