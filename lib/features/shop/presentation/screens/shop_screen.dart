import 'package:bloomie/features/profile/cubit/profile_cubit.dart';
import 'package:bloomie/features/profile/cubit/profile_state.dart';
import 'package:bloomie/features/shop/cubit/shop_cubit.dart';
import 'package:bloomie/features/shop/cubit/shop_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import '../widgets/shop_item_preview_dialog.dart';
import '../../models/accessory_effects.dart';
import '../../../../core/database/app_database.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<(String key, String label, String emoji)> _categories = [
    ('all', 'All', '🛍️'),
    ('pet_accessory', 'Pet Wear', '🎀'),
    ('plant_skin', 'Garden Skins', '🪴'),
    ('adventure_key', 'Keys', '🗝️'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ShopCubit>().loadShop();
  }

  void _showItemPreview(BuildContext context, ShopItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ShopItemPreviewDialog(
          itemId: item.id,
          name: item.name,
          emoji: item.emoji,
          price: item.price,
          category: item.category,
          description: _getItemDescription(item),
          owned: item.owned,
          equipped: item.equipped,
          onBuy: () async {
            final bought = await context.read<ShopCubit>().buyItem(item);
            if (!context.mounted) return;
            if (bought) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🛍️ Purchased ${item.name} successfully!',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: AppColors.primaryPink,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '❌ Not enough Blooms!',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          onEquip: () {
            context.read<ShopCubit>().toggleEquip(item);
          },
        );
      },
    );
  }

  String _getItemDescription(ShopItem item) {
    final effects = AccessoryEffects.getEffects(item.id);
    if (effects.isNotEmpty) {
      return effects.map((e) => e.description).join('\n');
    }
    if (item.category == 'plant_skin') {
      return 'A beautiful cosmetic skin to customize the look of your garden plants.';
    }
    if (item.category == 'adventure_key') {
      return 'Unlock the corresponding adventure land instantly and start exploring new rewards!';
    }
    return 'A special item from the Bloom Boutique.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      appBar: AppBar(
        title: Text(
          'Bloom Boutique',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(SolarIconsOutline.arrowLeft, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Live Bloom balance indicator
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final blooms = state is ProfileLoaded ? state.user.totalBlooms : 0;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFFE896B0).withValues(alpha: 0.1), blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    Text('🌸', style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 4.w),
                    Text(
                      '$blooms',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: AppColors.primaryPink,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ShopCubit, ShopState>(
        builder: (context, state) {
          if (state is ShopLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
          }

          if (state is ShopError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is ShopLoaded) {
            final activeCategory = state.activeCategory;
            final filteredItems = activeCategory == 'all'
                ? state.items
                : state.items.where((i) => i.category == activeCategory).toList();

            return Column(
              children: [
                // Category Selector Row
                Container(
                  height: 48.h,
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = activeCategory == cat.$1;

                      return GestureDetector(
                        onTap: () => context.read<ShopCubit>().changeCategory(cat.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: 10.w),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryPink : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                            border: Border.all(
                              color: isSelected ? AppColors.primaryPink : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(cat.$3, style: TextStyle(fontSize: 14.sp)),
                              SizedBox(width: 6.w),
                              Text(
                                cat.$2,
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                  color: isSelected ? Colors.white : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Shop Grid
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Text(
                            'No items available in this category.',
                            style: GoogleFonts.nunito(color: AppColors.textMuted),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(20.w),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            mainAxisSpacing: 16.h,
                            crossAxisSpacing: 16.w,
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final pastelBg = _pastelColorFor(item.category);

                            return GestureDetector(
                              onTap: () => _showItemPreview(context, item),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Top Colored Section with Emoji
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: pastelBg,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                        ),
                                        child: Center(
                                          child: Text(item.emoji, style: TextStyle(fontSize: 48.sp)),
                                        ),
                                      ),
                                    ),

                                    // Text Detail Section
                                    Padding(
                                      padding: EdgeInsets.all(12.w),
                                      child: Column(
                                        children: [
                                          Text(
                                            item.name,
                                            style: GoogleFonts.baloo2(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                              color: AppColors.textDark,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            _categoryLabel(item.category),
                                            style: GoogleFonts.nunito(
                                              fontSize: 10.sp,
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 10.h),

                                          // Purchase / Equip Status Button
                                          _ActionButton(
                                            item: item,
                                            onBuy: () => _showItemPreview(context, item),
                                            onToggleEquip: () {
                                              context.read<ShopCubit>().toggleEquip(item);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Color _pastelColorFor(String category) {
    switch (category) {
      case 'pet_accessory':
        return const Color(0xFFFFF2E6); // Light orange
      case 'plant_skin':
        return const Color(0xFFEAF9E6); // Light green
      case 'adventure_key':
        return const Color(0xFFF0F0FF); // Light blue/purple
      default:
        return const Color(0xFFFFF0F5); // Light pink
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'pet_accessory':
        return 'Pet Wear';
      case 'plant_skin':
        return 'Garden Skin';
      case 'adventure_key':
        return 'Special Key';
      default:
        return 'Boutique';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final dynamic item;
  final VoidCallback onBuy;
  final VoidCallback onToggleEquip;

  const _ActionButton({required this.item, required this.onBuy, required this.onToggleEquip});

  @override
  Widget build(BuildContext context) {
    if (!item.owned) {
      // Buy Button
      return SizedBox(
        width: double.infinity,
        height: 32.h,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pinkLight,
            foregroundColor: AppColors.primaryPink,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          onPressed: onBuy,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌸', style: TextStyle(fontSize: 12.sp)),
              SizedBox(width: 4.w),
              Text(
                '${item.price}',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      );
    }

    if (item.category == 'adventure_key') {
      // Keys are unlocked instantly and cannot be equipped/unequipped
      return SizedBox(
        width: double.infinity,
        height: 32.h,
        child: Center(
          child: Text(
            'Unlocked 🗝️',
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.green.shade600),
          ),
        ),
      );
    }

    // Equip / Unequip Button
    final isEquipped = item.equipped;

    return SizedBox(
      width: double.infinity,
      height: 32.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEquipped ? Colors.grey.shade100 : AppColors.primaryPink,
          foregroundColor: isEquipped ? AppColors.textDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        onPressed: onToggleEquip,
        child: Text(
          isEquipped ? 'Equipped 🌟' : 'Equip 👕',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
      ),
    );
  }
}
