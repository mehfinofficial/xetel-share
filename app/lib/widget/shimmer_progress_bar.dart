import 'package:flutter/material.dart';

/// A slim progress bar with a soft moving highlight sweep across the filled
/// portion — used on [ProgressPage] to visually distinguish the file that
/// is actively transferring right now from ones that are only queued or
/// already finished.
class ShimmerProgressBar extends StatefulWidget {
  final double progress;
  final double borderRadius;
  final Color? color;
  final double height;

  const ShimmerProgressBar({
    required this.progress,
    this.borderRadius = 10,
    this.color,
    this.height = 8,
    super.key,
  });

  @override
  State<ShimmerProgressBar> createState() => _ShimmerProgressBarState();
}

class _ShimmerProgressBarState extends State<ShimmerProgressBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final trackColor = Theme.of(context).colorScheme.secondaryContainer;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            Container(color: trackColor),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: widget.progress.clamp(0, 1)),
              duration: const Duration(milliseconds: 250),
              builder: (context, value, _) {
                return FractionallySizedBox(
                  widthFactor: value,
                  alignment: Alignment.centerLeft,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (rect) {
                          final t = _controller.value;
                          return LinearGradient(
                            begin: Alignment(-1 - t * 2, 0),
                            end: Alignment(1 - t * 2, 0),
                            colors: [color, Colors.white.withValues(alpha: 0.9), color],
                            stops: const [0.35, 0.5, 0.65],
                          ).createShader(rect);
                        },
                        child: Container(color: color),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}