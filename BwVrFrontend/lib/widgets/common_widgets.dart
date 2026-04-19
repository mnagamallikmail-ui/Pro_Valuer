import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Monospace chip that displays a reference number with copy button
class ReferenceChip extends StatelessWidget {
  final String referenceNumber;
  final double? fontSize;

  const ReferenceChip(
      {super.key, required this.referenceNumber, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            referenceNumber,
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: referenceNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied!'),
                  duration: Duration(seconds: 1),
                  width: 150,
                ),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: const Icon(Icons.copy_rounded,
                size: 14, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// Status chip for report/template status display
class StatusChip extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusChip({super.key, required this.status, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: AppTypography.label.copyWith(
          fontSize: fontSize ?? 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig(String s) {
    switch (s.toUpperCase()) {
      case 'COMPLETED':
      case 'CONFIRMED':
      case 'ACTIVE':
        return {'bg': AppColors.secondary};
      case 'IN_PROGRESS':
      case 'PARSED':
        return {'bg': AppColors.accent};
      case 'DRAFT':
      case 'PENDING':
        return {'bg': AppColors.primary};
      case 'ARCHIVED':
      case 'ERROR':
        return {'bg': AppColors.error};
      default:
        return {'bg': AppColors.surface};
    }
  }
}

/// Stats card for dashboard
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: AppTypography.heading2,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, size: 40, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Text(title, style: AppTypography.heading3),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 32),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
