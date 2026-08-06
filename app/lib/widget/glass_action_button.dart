import 'package:flutter/material.dart';

/// Premium pill button: filled gradient for a primary/destructive action,
/// glass outline for a secondary one. Matches the liquid-glass design system
/// used across Settings / Progress / Receive pages.
///
/// Self-contained — does not touch [LiquidGlassContainer] or any other
/// shared widget, so it's safe to drop in without regression risk.
class GlassActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final bool isWarning;
  final bool flat;
  final VoidCallback? onTap;

  const GlassActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    this.isWarning = false,
    this.flat = false,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabled = onTap == null;
    final accent = isWarning ? colorScheme.error : colorScheme.primary;

    final Color labelColor;
    if (disabled) {
      labelColor = colorScheme.onSurface.withValues(alpha: 0.35);
    } else if (filled) {
      labelColor = colorScheme.onPrimary;
    } else {
      labelColor = accent;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: filled && !disabled
                ? LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.78)],
                  )
                : null,
            color: !filled
                ? (isWarning ? accent.withValues(alpha: 0.10) : colorScheme.onSurface.withValues(alpha: 0.06))
                : (disabled ? colorScheme.onSurface.withValues(alpha: 0.08) : null),
            border: !filled ? Border.all(color: accent.withValues(alpha: 0.35), width: 1.2) : null,
            boxShadow: filled && !disabled && !flat
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: labelColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w600, color: labelColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}