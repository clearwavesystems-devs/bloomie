import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bloomie/features/duo_mode/data/duo_mode_data.dart';
import 'package:bloomie/features/duo_mode/presentation/widgets/bobbing_bunny.dart';
import 'package:bloomie/features/duo_mode/presentation/widgets/floating_petals.dart';

class DuoModeScreen extends StatefulWidget {
  const DuoModeScreen({super.key});

  @override
  State<DuoModeScreen> createState() => _DuoModeScreenState();
}

class _DuoModeScreenState extends State<DuoModeScreen> {
  final List<HabitModel> _habits = DuoModeData.habits;
  int _navIndex = 0;

  void _toggleHabit(int index) {
    setState(() {
      _habits[index] = _habits[index].copyWith(
        isCompleted: !_habits[index].isCompleted,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroSection(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: _ProgressCard(habits: _habits),
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: "Daily Habits",
                  onAction: () {},
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = _habits[index];
                    return _HabitCard(
                      habit: habit,
                      onToggle: () => _toggleHabit(index),
                    );
                  },
                  childCount: _habits.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: _AddHabitButton(),
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: "Weekly Garden Report",
                  actionText: "History",
                  onAction: () {},
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: _WeeklyReportCard(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 100.h),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNavBar(
              currentIndex: _navIndex,
              onTap: (index) => setState(() => _navIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380.h,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFDDBE8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Petals Animation
          Positioned.fill(
            child: FloatingPetals(
              containerWidth: 1.sw,
              containerHeight: 380.h,
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bloomie',
                        style: GoogleFonts.baloo2(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE896B0),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.notifications_outlined, color: const Color(0xFFE896B0), size: 24.sp),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _PartnerBadge(),
                ),
                const Spacer(),
                // Garden Ground
                Container(
                  height: 60.h,
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2B8CC),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
          
          // Bunnies and Plant
          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const BobbingBunny(
                  bodyColor: Colors.white,
                  earColor: Color(0xFFFDDBE8),
                  cheekColor: Color(0xFFFFC8DC),
                  size: 70,
                ),
                SizedBox(width: 20.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🌹', style: TextStyle(fontSize: 40.sp)),
                    SizedBox(height: 5.h),
                    Text(
                      'Our Rose',
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC07AD0),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20.w),
                const BobbingBunny(
                  bodyColor: Color(0xFFF2E8FF),
                  earColor: Color(0xFFE8D4FF),
                  cheekColor: Color(0xFFD4BFFF),
                  size: 70,
                  mirrorX: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE896B0).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Mira is online · 4/5 habits done',
            style: GoogleFonts.nunito(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3A2030),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final List<HabitModel> habits;

  const _ProgressCard({required this.habits});

  @override
  Widget build(BuildContext context) {
    int completed = habits.where((h) => h.isCompleted).length;
    double progress = completed / habits.length;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE896B0), Color(0xFFC07AD0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE896B0).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70.w,
            height: 70.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.baloo2(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great job, duo!',
                  style: GoogleFonts.baloo2(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'You\'ve completed $completed out of ${habits.length} habits today.',
                  style: GoogleFonts.nunito(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    this.actionText = "See all",
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.baloo2(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2030),
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFC07AD0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;

  const _HabitCard({required this.habit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F5),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(habit.emoji, style: TextStyle(fontSize: 24.sp)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: GoogleFonts.baloo2(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3A2030),
                    decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  habit.subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E8FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    habit.partnerBadge,
                    style: GoogleFonts.nunito(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC07AD0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: habit.isCompleted ? const Color(0xFFE896B0) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: habit.isCompleted ? const Color(0xFFE896B0) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: habit.isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 18.sp)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddHabitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFDDBE8).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE896B0).withOpacity(0.5),
          style: BorderStyle.solid,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '+ Add New Habit',
        style: GoogleFonts.baloo2(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFE896B0),
        ),
      ),
    );
  }
}

class _WeeklyReportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reportData = DuoModeData.weeklyReport;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Garden Growth',
                style: GoogleFonts.baloo2(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3A2030),
                ),
              ),
              Text(
                '+12% this week',
                style: GoogleFonts.nunito(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 100.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: reportData.map((day) => _BarChartGroup(day: day)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartGroup extends StatelessWidget {
  final WeeklyReportDay day;

  const _BarChartGroup({required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 8.w,
              height: 60.h * day.myProgress,
              decoration: BoxDecoration(
                color: const Color(0xFFE896B0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              width: 8.w,
              height: 60.h * day.partnerProgress,
              decoration: BoxDecoration(
                color: const Color(0xFFC07AD0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          day.day,
          style: GoogleFonts.nunito(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
      ],
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
      height: 90.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(icon: Icons.home_rounded, label: 'Home', isSelected: currentIndex == 0, onTap: () => onTap(0)),
          _NavBarItem(icon: Icons.favorite_rounded, label: 'Duo', isSelected: currentIndex == 1, onTap: () => onTap(1)),
          _NavBarItem(icon: Icons.add_circle_rounded, label: '', isSelected: false, onTap: () {}, isAction: true),
          _NavBarItem(icon: Icons.bar_chart_rounded, label: 'Stats', isSelected: currentIndex == 3, onTap: () => onTap(3)),
          _NavBarItem(icon: Icons.person_rounded, label: 'Profile', isSelected: currentIndex == 4, onTap: () => onTap(4)),
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
  final bool isAction;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isAction) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: const BoxDecoration(
            color: Color(0xFFE896B0),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28.sp),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFE896B0) : Colors.grey.shade400,
            size: 24.sp,
          ),
          if (label.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? const Color(0xFFE896B0) : Colors.grey.shade400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
