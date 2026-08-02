import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable glassmorphism panel — Apple-style "liquid glass":
/// near-colorless, heavy blur, thin hairline border, subtle top highlight.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double opacity;
  final Color? tint;

  const GlassContainer({
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 30,
    this.padding,
    this.margin,
    this.opacity = 0.06,
    this.tint,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = tint ?? Colors.white;

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor.withValues(alpha: opacity + 0.03), // slightly brighter top-left (specular highlight)
                  baseColor.withValues(alpha: opacity),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Full-screen backdrop: near-black neutral base with soft, separated
/// color blobs — the blur reveals these, not a flat color wash.
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Neutral near-black base — NOT teal, so glass stays colorless
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: const Color(0xFF0B0D0F)),
          ),
        ),
        // Soft ambient color blobs, heavily blurred, low opacity, spread apart
        Positioned(top: -120, left: -100, child: _glowBlob(const Color(0xFF2ED9A8), 380)),
        Positioned(bottom: -150, right: -120, child: _glowBlob(const Color(0xFF1B7A6B), 420)),
        Positioned(top: 200, right: -180, child: _glowBlob(const Color(0xFF3B82F6), 320)),
        child,
      ],
    );
  }

  Widget _glowBlob(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}