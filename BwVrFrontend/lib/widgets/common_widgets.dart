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
        color: AppColors.structural,
        borderRadius: BorderRadius.circular(30), // Pill shape
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
        return {'bg': Color(0xFFFEE2E2)};
      default:
        return {'bg': AppColors.structural};
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left accent bar
          Positioned(
            left: -24,
            top: -24,
            bottom: -24,
            width: 4,
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: cardColor, size: 24),
                  ),
                  if (subtitle != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subtitle!,
                        style: AppTypography.label.copyWith(
                          color: cardColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                value,
                style: AppTypography.heading1.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
                color: AppColors.structural,
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
