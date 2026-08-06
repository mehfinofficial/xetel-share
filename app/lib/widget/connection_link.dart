import 'package:flutter/material.dart';

/// Animated vertical "energy link" shown between the local device tile and
/// the target device tile on [SendPage] — three dots flow downward in a
/// loop to suggest an active, live connection. Replaces the old static
/// down-arrow icon.
class ConnectionLink extends StatefulWidget {
  final double height;

  const ConnectionLink({this.height = 48, super.key});

  @override
  State<ConnectionLink> createState() => _ConnectionLinkState();
}

class _ConnectionLinkState extends State<ConnectionLink> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 32,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Center(
                child: Container(
                  width: 2,
                  height: widget.height,
                  color: color.withValues(alpha: 0.15),
                ),
              ),
              for (var i = 0; i < 3; i++) _flowingDot(color, offset: i / 3),
            ],
          );
        },
      ),
    );
  }

  Widget _flowingDot(Color color, {required double offset}) {
    final t = (_controller.value + offset) % 1.0;
    final y = t * widget.height;
    // Fade in/out near the ends so dots don't pop in/out abruptly.
    final edgeFade = t < 0.15 ? t / 0.15 : (t > 0.85 ? (1 - t) / 0.15 : 1.0);
    return Positioned(
      top: y - 3,
      child: Opacity(
        opacity: edgeFade.clamp(0.0, 1.0),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6, spreadRadius: 1),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small breathing dot used as a "live" indicator next to short status
/// text (e.g. "Waiting for response…").
class PulseDot extends StatefulWidget {
  final double size;
  final Color? color;

  const PulseDot({this.size = 8, this.color, super.key});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = 0.4 + 0.6 * _controller.value;
        return Opacity(
          opacity: t,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1),
              ],
            ),
          ),
        );
      },
    );
  }
}