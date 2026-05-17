import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function({
    required String title,
    String? description,
    required int xpReward,
    required int bloomReward,
    DateTime? dueAt,
    int? estimatedMinutes,
  })
  onSave;

  const AddTaskBottomSheet({super.key, required this.onSave});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _selectedXpIndex = 0; // 20 XP
  int _selectedTimeIndex = 1; // 30m

  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  final List<(int xp, int bloom)> _rewards = [(20, 5), (50, 10), (100, 25)];

  final List<(String label, int? minutes)> _times = [('15m', 15), ('30m', 30), ('45m', 45), ('1h', 60), ('None', null)];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryPink,
                onPrimary: Colors.white,
                onSurface: AppColors.textDark,
              ),
            ),
            child: child!,
          );
        },
      );

      setState(() {
        _dueDate = pickedDate;
        _dueTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDue = _dueDate != null && _dueTime != null;
    final dueFormatted = hasDue
        ? '${DateFormat.yMMMd().format(_dueDate!)} at ${_dueTime!.format(context)}'
        : 'Set Due Date & Time';

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 18.h),

            // Header Title
            Text(
              'Create New Task',
              style: GoogleFonts.baloo2(fontSize: 22.sp, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            SizedBox(height: 16.h),

            // Title Field
            TextField(
              controller: _titleController,
              style: GoogleFonts.nunito(color: AppColors.textDark, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Task Title',
                labelStyle: GoogleFonts.nunito(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.creamBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 12.h),

            // Description Field
            TextField(
              controller: _descController,
              maxLines: 2,
              style: GoogleFonts.nunito(color: AppColors.textDark),
              decoration: InputDecoration(
                labelText: 'Notes / Description (Optional)',
                labelStyle: GoogleFonts.nunito(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.creamBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 18.h),

            // XP Rewards Row
            Text(
              'Difficulty & Rewards',
              style: GoogleFonts.baloo2(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            SizedBox(height: 8.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_rewards.length, (index) {
                  final item = _rewards[index];
                  final isSelected = _selectedXpIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedXpIndex = index),
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.lavLight : AppColors.creamBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppColors.lavender : Colors.transparent, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text(
                            index == 0 ? 'Easy' : (index == 1 ? 'Medium' : 'Hard'),
                            style: GoogleFonts.nunito(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.lavender : AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '✨ ${item.$1} XP / 🌸 ${item.$2}',
                            style: GoogleFonts.nunito(
                              fontSize: 11.sp,
                              color: isSelected ? AppColors.lavender : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 18.h),

            // Estimated Duration Row
            Text(
              'Estimated Time',
              style: GoogleFonts.baloo2(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            SizedBox(height: 8.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_times.length, (index) {
                  final item = _times[index];
                  final isSelected = _selectedTimeIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeIndex = index),
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.pinkLight : AppColors.creamBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSelected ? AppColors.primaryPink : Colors.transparent, width: 1.5),
                      ),
                      child: Text(
                        item.$1,
                        style: GoogleFonts.nunito(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primaryPink : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 18.h),

            // Due Date Picker
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(color: AppColors.creamBg, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          SolarIconsOutline.calendar,
                          size: 18,
                          color: hasDue ? AppColors.primaryPink : AppColors.textMuted,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          dueFormatted,
                          style: GoogleFonts.nunito(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: hasDue ? AppColors.primaryPink : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Icon(SolarIconsOutline.altArrowRight, color: hasDue ? AppColors.primaryPink : AppColors.textMuted),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) return;

                  DateTime? finalDue;
                  if (_dueDate != null && _dueTime != null) {
                    finalDue = DateTime(
                      _dueDate!.year,
                      _dueDate!.month,
                      _dueDate!.day,
                      _dueTime!.hour,
                      _dueTime!.minute,
                    );
                  }

                  final selectedReward = _rewards[_selectedXpIndex];
                  final selectedTime = _times[_selectedTimeIndex];

                  widget.onSave(
                    title: _titleController.text.trim(),
                    description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
                    xpReward: selectedReward.$1,
                    bloomReward: selectedReward.$2,
                    dueAt: finalDue,
                    estimatedMinutes: selectedTime.$2,
                  );

                  Navigator.pop(context);
                },
                child: Text(
                  'Add Task',
                  style: GoogleFonts.baloo2(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
