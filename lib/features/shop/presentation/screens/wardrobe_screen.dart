import 'package:bloomie/features/shop/cubit/shop_cubit.dart';
import 'package:bloomie/features/shop/cubit/shop_state.dart';
import 'package:bloomie/features/habits/presentation/widgets/bobbing_bunny.dart';
import 'package:bloomie/core/theme/garden_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      appBar: AppBar(
        title: Text(
          '👗 My Wardrobe',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(SolarIconsOutline.arrowLeft, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Avatar Preview Section
          _AvatarPreviewSection(),
          // Category Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryPink,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primaryPink,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.nunito(),
            tabs: const [
              Tab(text: 'Pet Accessories'),
              Tab(text: 'Garden Skins'),
            ],
          ),
          // Owned Items Grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PetAccessoriesGrid(),
                _GardenSkinsGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPreviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCubit, ShopState>(
      builder: (context, state) {
        String? equippedAccessory;
        String accessoryName = 'Nothing equipped';

        if (state is ShopLoaded) {
          final equipped = state.items
              .where((i) => i.category == 'pet_accessory' && i.equipped);
          if (equipped.isNotEmpty) {
            equippedAccessory = equipped.first.id;
            accessoryName = equipped.first.name;
          }
        }

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    ' Blossom Preview',
                    style: GoogleFonts.baloo2(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.pinkLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🎭 Happy',
                      style: GoogleFonts.nunito(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Pet preview
                  SizedBox(
                    width: 90.w,
                    height: 110.h,
                    child: BobbingBunny(
                      bodyColor: Colors.white,
                      earColor: const Color(0xFFFDDBE8),
                      cheekColor: const Color(0xFFFFC8DC),
                      size: 80,
                      mood: 'happy',
                      equippedAccessory: equippedAccessory,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Outfit',
                          style: GoogleFonts.baloo2(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              '👗 ',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            Text(
                              accessoryName,
                              style: GoogleFonts.nunito(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Tap an accessory below to change outfit!',
                          style: GoogleFonts.nunito(
                            fontSize: 10.sp,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PetAccessoriesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCubit, ShopState>(
      builder: (context, state) {
        if (state is ShopLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ShopError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ShopLoaded) {
          // Show only owned pet accessories
          final ownedAccessories = state.items
              .where((i) => i.category == 'pet_accessory' && i.owned)
              .toList();

          if (ownedAccessories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🛍️ No accessories yet!',
                    style: GoogleFonts.baloo2(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Visit the Bloom Boutique to buy some!',
                    style: GoogleFonts.nunito(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(SolarIconsOutline.shop),
                    label: const Text('Go to Boutique'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(20.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 12.w,
            ),
            itemCount: ownedAccessories.length,
            itemBuilder: (context, index) {
              final item = ownedAccessories[index];
              final isEquipped = item.equipped;

              return _AccessoryCard(
                item: item,
                isEquipped: isEquipped,
                onTap: () {
                  context.read<ShopCubit>().toggleEquip(item);
                },
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _GardenSkinsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCubit, ShopState>(
      builder: (context, state) {
        if (state is ShopLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ShopError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ShopLoaded) {
          // Show only owned garden skins
          final ownedSkins = state.items
              .where((i) => i.category == 'plant_skin' && i.owned)
              .toList();

          if (ownedSkins.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🌻 No garden skins yet!',
                    style: GoogleFonts.baloo2(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Visit the Bloom Boutique to buy some!',
                    style: GoogleFonts.nunito(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(SolarIconsOutline.shop),
                    label: const Text('Go to Boutique'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(20.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 12.w,
            ),
            itemCount: ownedSkins.length,
            itemBuilder: (context, index) {
              final item = ownedSkins[index];
              final isEquipped = item.equipped;
              final theme = GardenThemes.forPlantSkin(item.id);

              return _GardenSkinCard(
                item: item,
                theme: theme,
                isEquipped: isEquipped,
                onTap: () {
                  context.read<ShopCubit>().toggleEquip(item);
                },
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _AccessoryCard extends StatelessWidget {
  final dynamic item;
  final bool isEquipped;
  final VoidCallback onTap;

  const _AccessoryCard({
    required this.item,
    required this.isEquipped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isEquipped ? AppColors.primaryPink : Colors.grey.shade200,
            width: isEquipped ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.emoji,
              style: TextStyle(fontSize: 48.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              item.name,
              style: GoogleFonts.nunito(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isEquipped ? AppColors.primaryPink : AppColors.pinkLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isEquipped ? 'Equipped' : 'Equip',
                style: GoogleFonts.nunito(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: isEquipped ? Colors.white : AppColors.primaryPink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GardenSkinCard extends StatelessWidget {
  final dynamic item;
  final GardenTheme theme;
  final bool isEquipped;
  final VoidCallback onTap;

  const _GardenSkinCard({
    required this.item,
    required this.theme,
    required this.isEquipped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isEquipped ? AppColors.primaryPink : Colors.grey.shade200,
            width: isEquipped ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme preview area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🌸',
                      style: TextStyle(fontSize: 32.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Preview',
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryText,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      theme.name,
                      style: GoogleFonts.nunito(
                        fontSize: 10.sp,
                        color: theme.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isEquipped ? AppColors.primaryPink : AppColors.pinkLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isEquipped ? 'Active' : 'Apply',
                        style: GoogleFonts.nunito(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: isEquipped ? Colors.white : AppColors.primaryPink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}