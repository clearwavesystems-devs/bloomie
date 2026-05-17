import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PartnerBadge extends StatelessWidget {
  final String partnerName;
  final bool isOnline;
  final String statusText;

  const PartnerBadge({super.key, required this.partnerName, this.isOnline = true, required this.statusText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryPink.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: isOnline
                  ? [BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 2)]
                  : [],
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: AppColors.textDark),
              children: [
                TextSpan(
                  text: partnerName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: ' $statusText'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
