import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LavaLoader extends StatefulWidget {
  final double size;

  const LavaLoader({this.size = 100, super.key});

  @override
  State<LavaLoader> createState() => _LavaLoaderState();
}

class _LavaLoaderState extends State<LavaLoader> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _roundnessController;

  static const _colorOne = Color(0xFFFFBF48);
  static const _colorTwo = Color(0xFFBE4A1D);

  @override
  void initState() {
    super.initState();
    // 6s master cycle = the full hue-rotate "colorize" loop (3 x 2s rotation loops fit inside it).
    _controller = AnimationController(duration: const Duration(seconds: 6), vsync: this)..repeat();
    // 1s cycle = "roundness" pulse: contrast 15 -> 3 -> 3 -> 15 -> 15 (matches CSS @keyframes roundness).
    _roundnessController = AnimationController(duration: const Duration(seconds: 1), vsync: this)..repeat();
  }

  double _contrastForT(double t) {
    if (t < 0.2) return _lerpD(15, 3, t / 0.2);
    if (t < 0.4) return 3;
    if (t < 0.6) return _lerpD(3, 15, (t - 0.4) / 0.2);
    return 15;
  }

  @override
  void dispose() {
    _controller.dispose();
    _roundnessController.dispose();
    super.dispose();
  }

  Color _hueShift(Color color, double degrees) {
    final hsv = HSVColor.fromColor(color);
    var newHue = (hsv.hue + degrees) % 360;
    if (newHue < 0) newHue += 360;
    return hsv.withHue(newHue).toColor();
  }

  double _lerpD(double a, double b, double t) => a + (b - a) * t;

  double _hueOffset(double t) {
    if (t < 0.2) return _lerpD(0, -30, t / 0.2);
    if (t < 0.4) return _lerpD(-30, -60, (t - 0.2) / 0.2);
    if (t < 0.6) return _lerpD(-60, -90, (t - 0.4) / 0.2);
    if (t < 0.8) return _lerpD(-90, -45, (t - 0.6) / 0.2);
    return _lerpD(-45, 0, (t - 0.8) / 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _roundnessController]),
      builder: (context, _) {
        final t = _controller.value;
        final hueDeg = _hueOffset(t);
        final contrast = _contrastForT(_roundnessController.value);
        final contrastOffset = 127.5 * (1 - contrast);
        final colorOne = _hueShift(_colorOne, hueDeg);
        final colorTwo = _hueShift(_colorTwo, hueDeg);
        final rotPhase = (t * 3) % 1.0; // one "2s" loop = 1/3 of the 6s master cycle

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: colorOne.withOpacity(0.35), blurRadius: widget.size * 0.25),
              BoxShadow(
                color: colorTwo.withOpacity(0.35),
                blurRadius: widget.size * 0.5,
                offset: Offset(0, widget.size * 0.2),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [colorOne.withOpacity(0.2), colorTwo.withOpacity(0.45)],
                    ),
                  ),
                ),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colorOne, colorTwo],
                    stops: const [0.3, 0.7],
                  ).createShader(rect),
                  child: ColorFiltered(
                    // Contrast boost = the "goo" step: turns soft blurred edges into hard-fused blobs.
                    // Lower this value (e.g. 4-6) if blobs disappear; raise it if edges look too soft/blurry.
                    colorFilter: ColorFilter.matrix(<double>[
                      contrast, 0, 0, 0, contrastOffset,
                      0, contrast, 0, 0, contrastOffset,
                      0, 0, contrast, 0, contrastOffset,
                      0, 0, 0, contrast, contrastOffset,
                    ]),
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: widget.size * 0.07,
                        sigmaY: widget.size * 0.07,
                      ),
                      child: CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: _BlobPainter(phase: rotPhase),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Blob {
  final Offset pivot; // fraction of size
  final double orbitRadius; // fraction of size
  final double blobRadius; // fraction of size
  final double phaseOffset; // 0..1
  final bool reverse;

  const _Blob({
    required this.pivot,
    required this.orbitRadius,
    required this.blobRadius,
    required this.phaseOffset,
    required this.reverse,
  });
}

class _BlobPainter extends CustomPainter {
  final double phase; // 0..1, one full loop = "2s" equivalent

  _BlobPainter({required this.phase});

  static const List<_Blob> _blobs = [
    _Blob(pivot: Offset(0.5, 0.5), orbitRadius: 0.14, blobRadius: 0.22, phaseOffset: 0.0, reverse: true),
    _Blob(pivot: Offset(0.5, 0.6), orbitRadius: 0.10, blobRadius: 0.16, phaseOffset: 0.333, reverse: false),
    _Blob(pivot: Offset(0.4, 0.4), orbitRadius: 0.10, blobRadius: 0.16, phaseOffset: 0.0, reverse: true),
    _Blob(pivot: Offset(0.4, 0.4), orbitRadius: 0.10, blobRadius: 0.16, phaseOffset: 0.5, reverse: true),
    _Blob(pivot: Offset(0.6, 0.4), orbitRadius: 0.10, blobRadius: 0.16, phaseOffset: 0.0, reverse: false),
    _Blob(pivot: Offset(0.6, 0.4), orbitRadius: 0.10, blobRadius: 0.16, phaseOffset: 0.667, reverse: false),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    // static base mass (from the non-animated large triangle in the original)
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.42),
      size.width * 0.26,
      paint,
    );

    for (final blob in _blobs) {
      var p = (phase + blob.phaseOffset) % 1.0;
      if (blob.reverse) p = 1.0 - p;
      final angle = p * 2 * math.pi;
      final center = Offset(
        size.width * blob.pivot.dx + math.cos(angle) * size.width * blob.orbitRadius,
        size.height * blob.pivot.dy + math.sin(angle) * size.height * blob.orbitRadius,
      );
      canvas.drawCircle(center, size.width * blob.blobRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) => oldDelegate.phase != phase;
}