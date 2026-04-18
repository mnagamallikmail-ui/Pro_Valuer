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
    final themeColor = color ?? AppColors.primaryText;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: themeColor, size: 24),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(trend!, style: AppTypography.label.copyWith(color: AppColors.primaryText, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(value, style: AppTypography.heading1.copyWith(fontSize: 28)),
          const SizedBox(height: 4),
          Text(title, style: AppTypography.heading3.copyWith(fontSize: 14, color: AppColors.accent)),
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
      case 'PENDING':
      case 'IN_PROGRESS':
        bg = AppColors.secondary.withOpacity(0.2); // Corn Yellow
        text = AppColors.primaryText;
        break;
      case 'COMPLETED':
      case 'APPROVED':
        bg = AppColors.primaryText.withOpacity(0.1); // Turquoise
        text = AppColors.primaryText;
        break;
      case 'REJECTED':
      case 'ERROR':
        bg = AppColors.primary.withOpacity(0.1); // Salmon Pink
        text = AppColors.primary;
        break;
      default:
        bg = AppColors.surface;
        text = AppColors.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: text.withOpacity(0.3), width: 1),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: AppTypography.label.copyWith(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tag_rounded, size: 12, color: AppColors.primaryText),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.label.copyWith(color: AppColors.primaryText)),
        ],
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
            Icon(icon, size: 80, color: AppColors.border),
            const SizedBox(height: 24),
            Text(title, style: AppTypography.heading2),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.accent),
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
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.heading2),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
