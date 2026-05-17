import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNavBar(currentIndex: navigationShell.currentIndex, onTap: _onTap),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(icon: SolarIconsOutline.home2, label: 'Home', isSelected: currentIndex == 0, onTap: () => onTap(0)),
          _NavBarItem(icon: SolarIconsOutline.leaf, label: 'Garden', isSelected: currentIndex == 1, onTap: () => onTap(1)),
          _NavBarItem(
            icon: SolarIconsOutline.notes,
            label: 'Quests',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavBarItem(icon: SolarIconsOutline.heart, label: 'Duo', isSelected: currentIndex == 3, onTap: () => onTap(3)),
          _NavBarItem(
            icon: SolarIconsOutline.user,
            label: 'Profile',
            isSelected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryPink : Colors.grey.shade400, size: 24.sp),
            if (label.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primaryPink : Colors.grey.shade400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
