import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';


class StarfieldBackground extends StatefulWidget {
  const StarfieldBackground({
    super.key,
    this.particleCount = 50,
    this.particleColor,
    this.overlayGradient,
    this.minRadius = 0.5,
    this.maxRadius = 2.5,
    this.speed = 0.3,
  });

  final int particleCount;
  final Color? particleColor;
  final Gradient? overlayGradient;
  final double minRadius;
  final double maxRadius;
  final double speed;

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _particles = [];
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initParticles(Size size, double minR, double maxR) {
    if (size == _lastSize && _particles.isNotEmpty) return;
    _lastSize = size;
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        radius: minR + _random.nextDouble() * (maxR - minR),
        opacity: 0.1 + _random.nextDouble() * 0.5,
        speedX: (_random.nextDouble() - 0.5) * widget.speed,
        speedY: (_random.nextDouble() - 0.5) * widget.speed,
        twinklePhase: _random.nextDouble() * pi * 2,
        twinkleSpeed: 0.5 + _random.nextDouble() * 1.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.particleColor ?? AppColors.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initParticles(size, widget.minRadius.r, widget.maxRadius.r);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: size,
              painter: _StarfieldPainter(
                particles: _particles,
                baseColor: baseColor,
                bounds: size,
              ),
              child: widget.overlayGradient != null
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: widget.overlayGradient,
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  final double radius;
  final double opacity;
  final double speedX;
  final double speedY;
  final double twinklePhase;
  final double twinkleSpeed;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.speedX,
    required this.speedY,
    required this.twinklePhase,
    required this.twinkleSpeed,
  });
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({
    required this.particles,
    required this.baseColor,
    required this.bounds,
  });

  final List<_Particle> particles;
  final Color baseColor;
  final Size bounds;

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (final p in particles) {
      p.x += p.speedX;
      p.y += p.speedY;

      final margin = 5.0;
      if (p.x < -margin) p.x = bounds.width + margin;
      if (p.x > bounds.width + margin) p.x = -margin;
      if (p.y < -margin) p.y = bounds.height + margin;
      if (p.y > bounds.height + margin) p.y = -margin;

      final twinkle = 0.5 + 0.5 * sin(now * p.twinkleSpeed + p.twinklePhase);
      final alpha = (p.opacity * twinkle).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius,
        Paint()..color = baseColor.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) => true;
}
