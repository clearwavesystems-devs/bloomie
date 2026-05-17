import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/sync/sync_queue_service.dart';

class SyncStatusBadge extends StatefulWidget {
  final bool showLabel;
  const SyncStatusBadge({super.key, this.showLabel = true});

  @override
  State<SyncStatusBadge> createState() => _SyncStatusBadgeState();
}

class _SyncStatusBadgeState extends State<SyncStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncQueue = context.read<SyncQueueService>();

    return ListenableBuilder(
      listenable: syncQueue,
      builder: (context, child) {
        final isProcessing = syncQueue.isProcessing;
        final isOffline = syncQueue.isOffline;
        final pendingCount = syncQueue.pendingCount;

        // Determine status parameters
        Color bgColor;
        Color textColor;
        IconData icon;
        String label;
        bool shouldSpin = false;

        if (isProcessing) {
          bgColor = const Color(0xFFFDE8F0); // Soft pink
          textColor = const Color(0xFFE896B0); // Darker pink
          icon = SolarIconsOutline.refresh;
          label = 'Syncing...';
          shouldSpin = true;
        } else if (isOffline) {
          bgColor = const Color(0xFFFFE8D6); // Soft peach
          textColor = const Color(0xFFE87E50); // Muted dark orange
          icon = SolarIconsOutline.cloud;
          label = pendingCount > 0 ? 'Offline ($pendingCount)' : 'Offline';
        } else if (pendingCount > 0) {
          bgColor = const Color(0xFFF2E8FF); // Soft lavender
          textColor = const Color(0xFFC07AD0); // Darker lavender
          icon = SolarIconsOutline.cloudUpload;
          label = '$pendingCount pending';
        } else {
          bgColor = const Color(0xFFE8F8F0); // Soft green
          textColor = const Color(0xFF4CAF50); // Leaf green
          icon = SolarIconsOutline.cloudCheck;
          label = 'Synced';
        }

        if (shouldSpin) {
          if (!_rotationController.isAnimating) {
            _rotationController.repeat();
          }
        } else {
          if (_rotationController.isAnimating) {
            _rotationController.stop();
          }
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: widget.showLabel ? 10.w : 6.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: textColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              shouldSpin
                  ? RotationTransition(
                      turns: _rotationController,
                      child: Icon(icon, color: textColor, size: 14.sp),
                    )
                  : Icon(icon, color: textColor, size: 14.sp),
              if (widget.showLabel) ...[
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
