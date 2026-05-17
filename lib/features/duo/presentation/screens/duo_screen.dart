import 'package:bloomie/features/duo/cubit/duo_cubit.dart';
import 'package:bloomie/features/duo/cubit/duo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';

class DuoScreen extends StatefulWidget {
  const DuoScreen({super.key});

  @override
  State<DuoScreen> createState() => _DuoScreenState();
}

class _DuoScreenState extends State<DuoScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isJoiningMode = false;

  @override
  void initState() {
    super.initState();
    context.read<DuoCubit>().loadDuoData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Duo Mode 🌸',
          style: GoogleFonts.baloo2(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        actions: [
          IconButton(
            icon: Icon(SolarIconsOutline.restart, color: AppColors.textDark, size: 24.sp),
            onPressed: () => context.read<DuoCubit>().loadDuoData(),
          ),
        ],
      ),
      body: BlocConsumer<DuoCubit, DuoState>(
        listener: (context, state) {
          if (state is DuoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DuoLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryPink),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading Duo connection...',
                    style: GoogleFonts.nunito(color: AppColors.textMuted, fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }

          if (state is DuoLoaded) {
            final session = state.session;
            final partner = state.partner;

            // Scenario 1: No active session
            if (session == null) {
              return _buildNoSessionUI();
            }

            // Scenario 2: Fully connected OR waiting with Mira fallback!
            return _buildConnectedUI(partner!, state.weeklyReport, state.isWaitingForPartner, state.inviteCode);
          }

          return Center(
            child: Text('Failed to load. Tap refresh to retry!', style: GoogleFonts.nunito(color: AppColors.textMuted)),
          );
        },
      ),
    );
  }

  // ── Sub-UI Builders ──────────────────────────

  Widget _buildNoSessionUI() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Splash Banner Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF2FA), Color(0xFFFBE6F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFF5E1EE), width: 1.5),
            ),
            child: Column(
              children: [
                Text('🌱✨', style: TextStyle(fontSize: 48.sp)),
                SizedBox(height: 12.h),
                Text(
                  'Bloom Together!',
                  style: GoogleFonts.baloo2(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Duo Mode lets you link up with a friend in real time. Share a plant in your garden, send interactive drifting petals to their screen, and keep each other motivated with friendly habit streaks!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 14.sp, color: AppColors.textMuted, height: 1.5),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),

          if (!_isJoiningMode) ...[
            // Host Session Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                onPressed: () => context.read<DuoCubit>().createDuoSession(),
                child: Text(
                  'Generate Invite Code 🔑',
                  style: GoogleFonts.baloo2(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Toggle to Join Input
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryPink, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                onPressed: () => setState(() => _isJoiningMode = true),
                child: Text(
                  'Enter Friend\'s Code 🌸',
                  style: GoogleFonts.baloo2(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primaryPink),
                ),
              ),
            ),
          ] else ...[
            // Enter Invite Code Input Form
            Text(
              'Enter Invite Code',
              style: GoogleFonts.baloo2(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.baloo2(fontSize: 18.sp, fontWeight: FontWeight.bold, letterSpacing: 2),
                    decoration: InputDecoration(
                      hintText: 'e.g. BLOOM1234',
                      hintStyle: GoogleFonts.nunito(color: AppColors.textMuted, letterSpacing: 0, fontSize: 14.sp),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lavender,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_codeController.text.trim().isNotEmpty) {
                        context.read<DuoCubit>().joinDuoSession(_codeController.text.trim());
                      }
                    },
                    child: Text(
                      'Join',
                      style: GoogleFonts.baloo2(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => setState(() => _isJoiningMode = false),
              child: Text(
                '← Go Back',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectedUI(
    dynamic partner,
    Map<String, List<double>> report,
    bool isWaitingForPartner,
    String? inviteCode,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          if (isWaitingForPartner && inviteCode != null) ...[
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF2FA), Color(0xFFFBE6F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFF5E1EE), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('🌸', style: TextStyle(fontSize: 22.sp)),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Waiting for your partner...',
                          style: GoogleFonts.baloo2(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '24h Limit',
                          style: GoogleFonts.nunito(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'In the meantime, you are playing with Mira! Share this code with a friend to connect gardens:',
                    style: GoogleFonts.nunito(fontSize: 12.sp, color: AppColors.textMuted, height: 1.4),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFF0D6E6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          inviteCode,
                          style: GoogleFonts.baloo2(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPink,
                            letterSpacing: 1.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: inviteCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Invite code copied! 📋',
                                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.lavender,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                'Copy',
                                style: GoogleFonts.nunito(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lavender,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(SolarIconsOutline.copy, color: AppColors.lavender, size: 14.sp),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Premium Partner Identity Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: AppColors.pinkLight,
                  child: Text(partner.avatarEmoji, style: TextStyle(fontSize: 32.sp)),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.name,
                        style: GoogleFonts.baloo2(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(SolarIconsOutline.bolt, color: Colors.orange, size: 16),
                          SizedBox(width: 4.w),
                          Text(
                            'Streak: ${partner.currentStreak} days',
                            style: GoogleFonts.nunito(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today\'s habits:',
                            style: GoogleFonts.nunito(fontSize: 12.sp, color: AppColors.textMuted),
                          ),
                          Text(
                            '${partner.todayHabitsDone}/${partner.todayHabitsTotal}',
                            style: GoogleFonts.nunito(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPink,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: LinearProgressIndicator(
                          value: partner.todayHabitsTotal > 0
                              ? (partner.todayHabitsDone / partner.todayHabitsTotal)
                              : 0,
                          minHeight: 8.h,
                          backgroundColor: AppColors.pinkLight,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primaryPink),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Weekly Progress comparison
          _WeeklyComparison(report: report),
          SizedBox(height: 36.h),

          // Interactive send petal button!
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
              ),
              onPressed: () {
                context.read<DuoCubit>().sendPetal();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cherry blossom sent to ${partner.name}! 🌸',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.primaryPink,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Text('🌸', style: TextStyle(fontSize: 18.sp)),
              label: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryPink, AppColors.lavender]),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Send a Blossom to ${partner.name}',
                    style: GoogleFonts.baloo2(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting Widget: WeeklyComparison ────────────────

class _WeeklyComparison extends StatelessWidget {
  final Map<String, List<double>> report;

  const _WeeklyComparison({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Completion Rates 📈',
            style: GoogleFonts.baloo2(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.h,
                decoration: const BoxDecoration(color: AppColors.primaryPink, shape: BoxShape.circle),
              ),
              SizedBox(width: 6.w),
              Text(
                'You',
                style: GoogleFonts.nunito(fontSize: 12.sp, color: AppColors.textMuted),
              ),
              SizedBox(width: 16.w),
              Container(
                width: 10.w,
                height: 10.h,
                decoration: const BoxDecoration(color: AppColors.lavender, shape: BoxShape.circle),
              ),
              SizedBox(width: 6.w),
              Text(
                'Partner',
                style: GoogleFonts.nunito(fontSize: 12.sp, color: AppColors.textMuted),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 8.w,
                        height: ((report['you']?[i] ?? 0.0) * 60.h).clamp(4.h, 60.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Container(
                        width: 8.w,
                        height: ((report['partner']?[i] ?? 0.0) * 60.h).clamp(4.h, 60.h),
                        decoration: BoxDecoration(
                          color: AppColors.lavender,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                    style: GoogleFonts.nunito(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
