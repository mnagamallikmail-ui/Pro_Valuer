import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? trend;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.primary;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: themeColor, size: 20),
              ),
              if (trend != null)
                Text(
                  trend!, 
                  style: AppTypography.label.copyWith(
                    color: AppColors.success, 
                    fontSize: 10,
                    fontWeight: FontWeight.w600
                  )
                ),
            ],
          ),
          const Spacer(),
          Text(value, style: AppTypography.heading1.copyWith(fontSize: 28, color: AppColors.primaryText)),
          const SizedBox(height: 4),
          Text(title, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (status.toUpperCase()) {
      case 'DRAFT':
      case 'PENDING':
      case 'IN_PROGRESS':
        bg = AppColors.warning.withOpacity(0.1);
        text = AppColors.warning;
        break;
      case 'COMPLETED':
      case 'APPROVED':
      case 'PARSED':
      case 'CONFIRMED':
        bg = AppColors.success.withOpacity(0.1);
        text = AppColors.success;
        break;
      case 'REJECTED':
      case 'ERROR':
        bg = AppColors.error.withOpacity(0.1);
        text = AppColors.error;
        break;
      default:
        bg = AppColors.surface;
        text = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: AppTypography.label.copyWith(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ReferenceChip extends StatelessWidget {
  final String label;
  const ReferenceChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(
        label, 
        style: AppTypography.label.copyWith(
          color: AppColors.primaryText,
          fontSize: 10,
          fontWeight: FontWeight.w600
        )
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: AppColors.border),
            const SizedBox(height: 24),
            Text(title, style: AppTypography.heading3),
            const SizedBox(height: 8),
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

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.heading3.copyWith(fontWeight: FontWeight.w600)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

