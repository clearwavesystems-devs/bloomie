import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../cubit/task_cubit.dart';
import '../../cubit/task_state.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_sheet.dart';
import '../../../../core/sync/sync_queue_service.dart';
import '../../../../core/sync/data_sync_service.dart';
import '../../../settings/presentation/widgets/sync_status_badge.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool _isCompletedExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddTaskBottomSheet(
          onSave:
              ({
                required String title,
                String? description,
                required int xpReward,
                required int bloomReward,
                DateTime? dueAt,
                int? estimatedMinutes,
              }) {
                context.read<TaskCubit>().addTask(
                  title: title,
                  description: description,
                  xpReward: xpReward,
                  bloomReward: bloomReward,
                  dueAt: dueAt,
                  estimatedMinutes: estimatedMinutes,
                );
              },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            );
          }

          if (state is TaskError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('⚠️', style: TextStyle(fontSize: 48.sp)),
                    SizedBox(height: 12.h),
                    Text(
                      state.message,
                      style: GoogleFonts.nunito(color: AppColors.textDark),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                      ),
                      onPressed: () => context.read<TaskCubit>().loadTasks(),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.baloo2(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is TaskLoaded) {
            final active = state.activeTasks;
            final completed = state.completedTasks;
            final activeTimerId = state.activeTimerTaskId;
            final elapsedSecs = state.timerSeconds;

            // Calculate total XP earned from tasks completed today
            final todayXp = completed
                .where(
                  (t) =>
                      t.completedAt != null &&
                      t.completedAt!.day == DateTime.now().day &&
                      t.completedAt!.month == DateTime.now().month &&
                      t.completedAt!.year == DateTime.now().year,
                )
                .fold(0, (sum, t) => sum + t.xpReward);

            return RefreshIndicator(
              onRefresh: () async {
                final syncQueue = context.read<SyncQueueService>();
                final dataSync = context.read<DataSyncService>();
                try {
                  await syncQueue.forceSync();
                  await dataSync.syncFromSupabase();
                } catch (e) {
                  debugPrint('⚠️ TaskScreen: Manual sync failed: $e');
                }
                if (context.mounted) {
                  context.read<TaskCubit>().loadTasks();
                }
              },
              color: AppColors.primaryPink,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Premium Header / Hero Banner
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        right: 20.w,
                        top: 60.h,
                        bottom: 30.h,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFDDBE8), Color(0xFFFFF0F5)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Task Quest',
                                style: GoogleFonts.baloo2(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Row(
                                children: [
                                  const SyncStatusBadge(),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white),
                                    ),
                                    child: Text(
                                      '✨ $todayXp XP Today',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Complete quests, earn XP rewards, and track your focus time to fuel your garden!',
                            style: GoogleFonts.nunito(
                              fontSize: 13.sp,
                              color: AppColors.textDark.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Active Tasks Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        right: 20.w,
                        top: 20.h,
                        bottom: 8.h,
                      ),
                      child: Text(
                        'Active Quests (${active.length})',
                        style: GoogleFonts.baloo2(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),

                  // Empty State or Active Tasks List
                  if (active.isEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.all(20.w),
                        padding: EdgeInsets.all(24.w),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('📝', style: TextStyle(fontSize: 48.sp)),
                            SizedBox(height: 12.h),
                            Text(
                              'All quests completed!',
                              style: GoogleFonts.baloo2(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'You have no pending tasks. Tap the + button to create a new quest and grow your XP.',
                              style: GoogleFonts.nunito(
                                fontSize: 12.sp,
                                color: AppColors.textMuted,
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
                          final task = active[index];
                          return TaskCard(
                            task: task,
                            isTimerActive: activeTimerId == task.id,
                            elapsedSeconds: activeTimerId == task.id
                                ? elapsedSecs
                                : 0,
                            onComplete: () =>
                                context.read<TaskCubit>().completeTask(task.id),
                            onDelete: () =>
                                context.read<TaskCubit>().deleteTask(task.id),
                            onStartTimer: () =>
                                context.read<TaskCubit>().startTimer(task.id),
                            onPauseTimer: () =>
                                context.read<TaskCubit>().pauseTimer(),
                            onStopTimer: () =>
                                context.read<TaskCubit>().stopTimer(),
                          );
                        }, childCount: active.length),
                      ),
                    ),

                  // Completed Tasks Section
                  if (completed.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20.w,
                          right: 20.w,
                          top: 16.h,
                          bottom: 4.h,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isCompletedExpanded = !_isCompletedExpanded;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Completed Quests (${completed.length})',
                                  style: GoogleFonts.baloo2(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Icon(
                                  _isCompletedExpanded
                                      ? SolarIconsOutline.altArrowUp
                                      : SolarIconsOutline.altArrowDown,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_isCompletedExpanded)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final task = completed[index];
                            return Opacity(
                              opacity: 0.6,
                              child: TaskCard(
                                task: task,
                                onComplete: () {},
                                onDelete: () => context
                                    .read<TaskCubit>()
                                    .deleteTask(task.id),
                                onStartTimer: () {},
                                onPauseTimer: () {},
                                onStopTimer: () {},
                              ),
                            );
                          }, childCount: completed.length),
                        ),
                      ),
                  ],

                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: AppColors.primaryPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        child: const Icon(
          SolarIconsOutline.addSquare,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
