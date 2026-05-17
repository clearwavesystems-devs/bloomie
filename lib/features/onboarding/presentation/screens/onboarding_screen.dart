import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      emoji: '🌱',
      title: 'Plant Your Habits',
      subtitle: 'Nurture Consistency',
      description: 'Set simple daily habits like stretching, journaling, or drinking water. Every completion fuels your growth and keeps your streak alive.',
      bgGradient: [const Color(0xFFFFF6F0), const Color(0xFFFFF0FA)],
      features: [
        ('🧘', 'Custom Routine Building'),
        ('💧', 'Streak Count Tracking'),
      ],
    ),
    OnboardingPageData(
      emoji: '🌹',
      title: 'Grow Together',
      subtitle: 'Accountability & Companionship',
      description: 'Invite a partner, couple, or best friend in Duo Mode. Work together on shared goals to nurture and raise an Eternal Rose in real-time.',
      bgGradient: [const Color(0xFFFFF0F5), const Color(0xFFFFF5FB)],
      features: [
        ('🤝', 'Real-time Partner Syncing'),
        ('💬', 'Shared Daily Affirmations'),
      ],
    ),
    OnboardingPageData(
      emoji: '🛍️',
      title: 'Your Boutique Sanctuary',
      subtitle: 'Collect & Customize',
      description: 'Earn Blooms from your real-life dedication. Visit the Bloom Boutique to unlock magical plant seeds, accessories, and gorgeous shop decorations.',
      bgGradient: [const Color(0xFFFFF2FA), const Color(0xFFFFF8F9)],
      features: [
        ('✨', 'Earn Blooms for Daily Growth'),
        ('🌸', 'Boutique Shopping & Customization'),
      ],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentIndex];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: currentPage.bgGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header (Skip Button) ─────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentIndex < _pages.length - 1)
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.nunito(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Onboarding Content ────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pulsing Emoji Hero Icon
                          Container(
                            width: 140.w,
                            height: 140.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPink.withValues(alpha: 0.1),
                                  blurRadius: 32,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              page.emoji,
                              style: TextStyle(fontSize: 64.sp),
                            ),
                          )
                              .animate(key: ValueKey(index))
                              .scale(
                                begin: const Offset(0.7, 0.7),
                                end: const Offset(1.0, 1.0),
                                duration: 800.ms,
                                curve: Curves.elasticOut,
                              )
                              .shimmer(delay: 500.ms, duration: 1500.ms),

                          SizedBox(height: 36.h),

                          // Subtitle (Cozy/Pastel Label)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.pinkLight,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              page.subtitle.toUpperCase(),
                              style: GoogleFonts.nunito(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryPink,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0.0),

                          SizedBox(height: 16.h),

                          // Title
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.baloo2(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              height: 1.2,
                            ),
                          ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0.0),

                          SizedBox(height: 14.h),

                          // Description
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 14.sp,
                              color: AppColors.textDark.withValues(alpha: 0.7),
                              height: 1.6,
                            ),
                          ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0.0),

                          SizedBox(height: 28.h),

                          // Key Features
                          Column(
                            children: page.features.map((feat) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 8.h),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Text(feat.$1, style: TextStyle(fontSize: 18.sp)),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        feat.$2,
                                        style: GoogleFonts.nunito(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      SolarIconsOutline.checkCircle,
                                      size: 16.w,
                                      color: AppColors.primaryPink,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0.0),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Bottom Bar (Indicators & CTA Button) ──────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 28.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot Indicators
                    Row(
                      children: List.generate(_pages.length, (index) {
                        final isSelected = index == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(right: 6.w),
                          width: isSelected ? 24.w : 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryPink
                                : AppColors.primaryPink.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        );
                      }),
                    ),

                    // Next/Start Button
                    SizedBox(
                      height: 52.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                        ),
                        onPressed: () {
                          if (_currentIndex < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _completeOnboarding();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentIndex == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: GoogleFonts.baloo2(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              _currentIndex == _pages.length - 1
                                  ? SolarIconsOutline.checkCircle
                                  : SolarIconsOutline.altArrowRight,
                              size: 18.w,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> bgGradient;
  final List<(String, String)> features;

  OnboardingPageData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bgGradient,
    required this.features,
  });
}
