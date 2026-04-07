import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Monospace chip that displays a reference number with copy button
class ReferenceChip extends StatelessWidget {
  final String referenceNumber;
  final double? fontSize;

  const ReferenceChip(
      {super.key, required this.referenceNumber, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.chipBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            referenceNumber,
            style: TextStyle(
              fontFamily: 'Courier New',
              fontSize: fontSize ?? 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.accent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: referenceNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reference number copied!'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: const Icon(Icons.copy_rounded,
                size: 14, color: AppTheme.accent),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (config['color'] as Color).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config['color'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.replaceAll('_', ' '),
            style: TextStyle(
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
              color: config['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getConfig(String s) {
    switch (s.toUpperCase()) {
      case 'COMPLETED':
      case 'CONFIRMED':
      case 'ACTIVE':
        return {'color': AppTheme.success, 'bg': AppTheme.chipGreen};
      case 'IN_PROGRESS':
      case 'PARSED':
        return {'color': AppTheme.accent, 'bg': AppTheme.chipBlue};
      case 'DRAFT':
      case 'PENDING':
        return {'color': AppTheme.warning, 'bg': AppTheme.chipAmber};
      case 'ARCHIVED':
      case 'ERROR':
        return {'color': AppTheme.danger, 'bg': AppTheme.chipRed};
      default:
        return {'color': AppTheme.textSecondary, 'bg': const Color(0xFFF3F4F6)};
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
    final cardColor = color ?? AppTheme.accent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: TextStyle(
                          fontSize: 11,
                          color: cardColor,
                          fontWeight: FontWeight.w500)),
                ],
              ],
            ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(icon, size: 36, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(subtitle,
              style:
                  const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );
  }
}
