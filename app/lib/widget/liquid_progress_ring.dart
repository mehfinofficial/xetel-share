import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular "liquid glass" progress ring: a thick gradient stroke with a
/// soft ambient glow that grows with progress, and an optional [child]
/// centered inside (e.g. a percentage label). Used on [SendPage] (checksum
/// progress) and [ProgressPage] (overall transfer progress) so both screens
/// share the same premium progress motif.
class LiquidProgressRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double strokeWidth;
  final Widget? child;
  final Color? color;

  const LiquidProgressRing({
    required this.value,
    this.size = 120,
    this.strokeWidth = 10,
    this.child,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = color ?? Theme.of(context).colorScheme.primary;
    final trackColor = Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5);
    final clamped = value.clamp(0, 1).toDouble();

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clamped),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ambient glow behind the ring that grows with progress.
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ringColor.withValues(alpha: 0.05 + 0.25 * animatedValue),
                      blurRadius: 28,
                      spreadRadius: -4,
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  value: animatedValue,
                  strokeWidth: strokeWidth,
                  trackColor: trackColor,
                  ringColor: ringColor,
                ),
              ),
              if (child != null) child!,
            ],
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color trackColor;
  final Color ringColor;

  _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.trackColor,
    required this.ringColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (value <= 0) {
      return;
    }

    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [ringColor.withValues(alpha: 0.55), ringColor],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.ringColor != ringColor || oldDelegate.trackColor != trackColor;
  }
}