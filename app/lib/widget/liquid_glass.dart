import 'dart:ui';

import 'package:flutter/material.dart';

/// Shared "liquid glass" background surface used by [GlassBottomNav],
/// [GlassNavRail], and [GlassSegmentedControl]. Replaces the old flat
/// frosted panel with a diagonal depth gradient, a glossy top specular
/// sheen, and a brighter rim, in both light and dark mode.
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;

  const LiquidGlassContainer({
    required this.child,
    required this.borderRadius,
    this.blurSigma = 28,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E1E22) : Colors.white;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withValues(alpha: isDark ? 0.68 : 0.62),
                baseColor.withValues(alpha: isDark ? 0.42 : 0.38),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.16 : 0.80),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              child,
              // Glossy top specular highlight — the "liquid" sheen, drawn
              // above the content but ignoring hit-testing.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.45],
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.12 : 0.45),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}