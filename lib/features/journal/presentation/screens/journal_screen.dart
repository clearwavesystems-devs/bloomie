import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../cubit/journal_cubit.dart';
import '../../cubit/journal_state.dart';
import '../../../../core/sync/sync_queue_service.dart';
import '../../../../core/sync/data_sync_service.dart';
import '../../../settings/presentation/widgets/sync_status_badge.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<(String emoji, String label, int score)> _moods = [
    ('😢', 'Sad', 1),
    ('😐', 'Meh', 2),
    ('🙂', 'Okay', 3),
    ('😊', 'Happy', 4),
    ('😁', 'Joyful', 5),
  ];

  @override
  void initState() {
    super.initState();
    context.read<JournalCubit>().loadJournal();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() async {
    if (_contentController.text.trim().isEmpty) return;

    final success = await context.read<JournalCubit>().completeJournalEntry(
      _contentController.text.trim(),
    );

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✨ Entry saved! +100 XP & +15 Blooms earned.',
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primaryPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      _contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        title: Text(
          'Daily Journal',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            SolarIconsOutline.arrowLeft,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: SyncStatusBadge()),
          ),
        ],
      ),
      body: BlocBuilder<JournalCubit, JournalState>(
        builder: (context, state) {
          if (state is JournalLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            );
          }

          if (state is JournalError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is JournalLoaded) {
            final todayDone = state.todayEntry != null;
            final history = state.history;

            return RefreshIndicator(
              onRefresh: () async {
                final syncQueue = context.read<SyncQueueService>();
                final dataSync = context.read<DataSyncService>();
                try {
                  await syncQueue.forceSync();
                  await dataSync.syncFromSupabase();
                } catch (e) {
                  debugPrint('⚠️ JournalScreen: Manual sync failed: $e');
                }
                if (context.mounted) {
                  context.read<JournalCubit>().loadJournal();
                }
              },
              color: AppColors.primaryPink,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Daily Check-in Card (or Completion indicator)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.all(20.w),
                      padding: EdgeInsets.all(20.w),
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
                      child: todayDone
                          ? _TodayCompletedCard(entry: state.todayEntry!)
                          : Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'How are you feeling today?',
                                    style: GoogleFonts.baloo2(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 14.h),

                                  // Mood selector
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: _moods.map((m) {
                                      final isSelected =
                                          state.selectedMood == m.$1;
                                      return GestureDetector(
                                        onTap: () => context
                                            .read<JournalCubit>()
                                            .selectMood(m.$1, m.$3),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 10.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.pinkLight
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primaryPink
                                                  : Colors.transparent,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                m.$1,
                                                style: TextStyle(
                                                  fontSize: 28.sp,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                m.$2,
                                                style: GoogleFonts.nunito(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? AppColors.primaryPink
                                                      : AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 20.h),

                                  // Thoughts Box
                                  Text(
                                    'Write your thoughts...',
                                    style: GoogleFonts.baloo2(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextFormField(
                                    controller: _contentController,
                                    maxLines: 4,
                                    validator: (v) => v!.trim().isEmpty
                                        ? 'Write a few words'
                                        : null,
                                    style: GoogleFonts.nunito(
                                      color: AppColors.textDark,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'What went well? What is on your mind?',
                                      hintStyle: GoogleFonts.nunito(
                                        color: AppColors.textMuted,
                                        fontSize: 13.sp,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.creamBg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 18.h),

                                  // Save button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48.h,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryPink,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        if (state.selectedMood == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Please pick a mood emoji first!',
                                                style: GoogleFonts.nunito(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                          return;
                                        }
                                        if (_formKey.currentState!.validate()) {
                                          _saveEntry();
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Complete Entry',
                                            style: GoogleFonts.baloo2(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '✨ +100 XP',
                                            style: GoogleFonts.nunito(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
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
                    ),
                  ),

                  // Past Entries Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      child: Text(
                        'Past Reflections (${history.length})',
                        style: GoogleFonts.baloo2(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),

                  // History entries
                  if (history.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40.w),
                        child: Column(
                          children: [
                            Text('📔', style: TextStyle(fontSize: 48.sp)),
                            SizedBox(height: 12.h),
                            Text(
                              'Your memory book is empty',
                              style: GoogleFonts.baloo2(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Log your mood daily to build an emotional journal and track your progress.',
                              style: GoogleFonts.nunito(
                                color: AppColors.textMuted,
                                fontSize: 12.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final entry = history[index];
                          final dateText = DateFormat.yMMMMd().add_jm().format(
                            entry.createdAt,
                          );

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 6.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.01),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.creamBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    entry.mood,
                                    style: TextStyle(fontSize: 24.sp),
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _moodLabelFor(entry.mood),
                                            style: GoogleFonts.baloo2(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          Text(
                                            dateText,
                                            style: GoogleFonts.nunito(
                                              fontSize: 10.sp,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        entry.content,
                                        style: GoogleFonts.nunito(
                                          fontSize: 13.sp,
                                          color: AppColors.textDark.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }, childCount: history.length),
                      ),
                    ),

                  SliverToBoxAdapter(child: SizedBox(height: 60.h)),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  String _moodLabelFor(String emoji) {
    for (final m in _moods) {
      if (m.$1 == emoji) return m.$2;
    }
    return 'Reflective';
  }
}

class _TodayCompletedCard extends StatelessWidget {
  final dynamic entry;

  const _TodayCompletedCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('✨', style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 6.w),
            Text(
              'Reflected Today!',
              style: GoogleFonts.baloo2(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(width: 6.w),
            Text('✨', style: TextStyle(fontSize: 20.sp)),
          ],
        ),
        SizedBox(height: 14.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.creamBg,
            shape: BoxShape.circle,
          ),
          child: Text(entry.mood, style: TextStyle(fontSize: 32.sp)),
        ),
        SizedBox(height: 10.h),
        Text(
          'Your reflection:',
          style: GoogleFonts.nunito(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '"${entry.content}"',
          style: GoogleFonts.nunito(
            fontSize: 14.sp,
            fontStyle: FontStyle.italic,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
