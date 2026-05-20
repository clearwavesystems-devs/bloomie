import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../habits/presentation/widgets/bobbing_bunny.dart';
import '../../../shop/cubit/shop_cubit.dart';
import '../../../shop/cubit/shop_state.dart';
import '../../cubit/profile_cubit.dart';
import '../../cubit/profile_state.dart';
import '../../../auth/cubit/auth_cubit.dart';
import 'package:solar_icons/solar_icons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            final user = state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.pinkLight,
                    child: Text(user.avatarEmoji, style: const TextStyle(fontSize: 50)),
                  ),
                  const SizedBox(height: 16),
                  Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(
                    context.read<ProfileCubit>().getLevelTitle(user.level),
                    style: const TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  _StatGrid(user: user),
                  const SizedBox(height: 30),
                  const _PetCompanionPanel(),
                  const SizedBox(height: 10),
                  const _JournalSection(),
                  const SizedBox(height: 10),
                  const _SettingsSection(),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final dynamic user;
  const _StatGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(label: 'Level', value: '${user.level}', icon: '⭐'),
        _StatCard(label: 'XP', value: '${user.xp}', icon: '✨'),
        _StatCard(label: 'Blooms', value: '${user.totalBlooms}', icon: '🌸'),
        _StatCard(label: 'Streak', value: '${user.streakDays} days', icon: '🔥'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$icon $label', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text(
          'Sign Out? 🌸',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        content: Text(
          'Are you sure you want to sign out of Bloomie?',
          style: GoogleFonts.nunito(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthCubit>().signOut();
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text(
          'Delete Account? ⚠️',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All of your habits, streaks, level, and companion customisations will be permanently deleted.',
          style: GoogleFonts.nunito(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthCubit>().deleteAccount();
            },
            child: Text(
              'Delete Permanently',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountSettingsSheet(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'Not available';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Account Settings ⚙️',
                    style: GoogleFonts.baloo2(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  IconButton(
                    icon: const Icon(SolarIconsOutline.closeCircle, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.creamBg,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Email',
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      email,
                      style: GoogleFonts.nunito(
                        fontSize: 15.sp,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              const Divider(),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFFFD6D6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(SolarIconsOutline.danger, color: Colors.redAccent, size: 20),
                        SizedBox(width: 8.w),
                        Text(
                          'Danger Zone ⚠️',
                          style: GoogleFonts.baloo2(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Permanently delete your companion, gardens, coins, Streaks, XP, and all history. This operation is absolute and cannot be undone.',
                      style: GoogleFonts.nunito(fontSize: 12.sp, color: AppColors.textMuted, height: 1.4),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          _showDeleteAccountDialog(context);
                        },
                        icon: const Icon(SolarIconsOutline.trashBinMinimalistic, size: 18),
                        label: Text(
                          'Delete My Account Permanently',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 13.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(SolarIconsOutline.shop, color: AppColors.primaryPink),
          title: const Text('Bloom Boutique', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Spend earned Blooms on cute accessories & skins'),
          trailing: const Icon(SolarIconsOutline.altArrowRight),
          onTap: () => context.push('/shop'),
        ),
        ListTile(
          leading: const Icon(SolarIconsOutline.compass, color: Color(0xFF9C27B0)),
          title: const Text('Adventure Lands', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Explore worlds & earn XP rewards'),
          trailing: const Icon(SolarIconsOutline.altArrowRight),
          onTap: () => context.push('/adventure'),
        ),
        ListTile(
          leading: const Icon(SolarIconsOutline.bell),
          title: const Text('Notifications'),
          trailing: Switch(value: true, onChanged: (v) {}),
        ),
        ListTile(
          leading: const Icon(SolarIconsOutline.palette),
          title: const Text('App Theme'),
          trailing: const Icon(SolarIconsOutline.altArrowRight),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(SolarIconsOutline.settings),
          title: const Text('Account Settings'),
          subtitle: const Text('View credentials and permanently delete data'),
          trailing: const Icon(SolarIconsOutline.altArrowRight),
          onTap: () => _showAccountSettingsSheet(context),
        ),
        ListTile(leading: const Icon(SolarIconsOutline.questionCircle), title: const Text('Help & Support'), onTap: () {}),
        const Divider(height: 32, thickness: 1),
        ListTile(
          leading: const Icon(SolarIconsOutline.logout, color: AppColors.primaryPink),
          title: const Text(
            'Sign Out',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPink),
          ),
          onTap: () => _showSignOutDialog(context),
        ),
      ],
    );
  }
}

class _JournalSection extends StatelessWidget {
  const _JournalSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.pinkLight, shape: BoxShape.circle),
            child: const Text('📔', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Mood Journal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Text(
                  'Log your daily thoughts to earn +100 XP',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(SolarIconsOutline.altArrowRight, size: 16, color: AppColors.primaryPink),
            onPressed: () => context.push('/journal'),
          ),
        ],
      ),
    );
  }
}

class _PetCompanionPanel extends StatelessWidget {
  const _PetCompanionPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCubit, ShopState>(
      builder: (context, shopState) {
        String? equippedAccessory;
        String accessoryName = 'Nothing equipped';
        String accessoryEmoji = '🐰';

        if (shopState is ShopLoaded) {
          final equipped = shopState.items.where((i) => i.category == 'pet_accessory' && i.equipped);
          if (equipped.isNotEmpty) {
            equippedAccessory = equipped.first.id;
            accessoryName = equipped.first.name;
            accessoryEmoji = equipped.first.emoji;
          }
        }

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '🐰 My Companion',
                    style: GoogleFonts.baloo2(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/shop'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(color: AppColors.pinkLight, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '✨ Boutique',
                        style: GoogleFonts.nunito(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPink,
                        ),
                      ),
                    ),
                  ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () => context.push("/wardrobe"),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(color: AppColors.pinkLight, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          "👗 Wardrobe",
                          style: GoogleFonts.nunito(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPink,
                          ),
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
                          'Blossom',
                          style: GoogleFonts.baloo2(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text('🎭', style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 4.w),
                            Text(
                              'Happy',
                              style: GoogleFonts.nunito(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text(
                              '👗 Wearing: ',
                              style: GoogleFonts.nunito(fontSize: 12.sp, color: AppColors.textMuted),
                            ),
                            Text(
                              '$accessoryEmoji $accessoryName',
                              style: GoogleFonts.nunito(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Complete habits to boost Blossom\'s mood!',
                          style: GoogleFonts.nunito(fontSize: 10.sp, color: AppColors.textMuted),
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
