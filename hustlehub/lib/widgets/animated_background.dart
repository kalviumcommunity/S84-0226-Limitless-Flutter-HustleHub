import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;
  final Random random = Random();
  Timer? _timer;
  Size? _screenSize;

  @override
  void initState() {
    super.initState();
    // Initialize with default particles, will be updated when screen size is available
    particles = List.generate(20, (index) => Particle.random(random));

    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Add new particles periodically
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _screenSize != null) {
        setState(() {
          particles.add(Particle.random(random, screenSize: _screenSize));
          // Remove old particles to maintain performance
          if (particles.length > 25) {
            particles.removeAt(0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Update screen size and regenerate particles if screen size changed significantly
        if (_screenSize == null ||
            (_screenSize!.width - screenSize.width).abs() > 100 ||
            (_screenSize!.height - screenSize.height).abs() > 100) {
          _screenSize = screenSize;
          // Regenerate particles with new screen size
          particles = List.generate(
            20,
            (index) => Particle.random(random, screenSize: _screenSize),
          );
        }

        return SizedBox.expand(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles,
                  _controller.value,
                  constraints,
                ),
                child: Container(),
              );
            },
          ),
        );
      },
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.opacity,
  });

  factory Particle.random(Random random, {Size? screenSize}) {
    final width = screenSize?.width ?? 400;
    final height = screenSize?.height ?? 800;

    return Particle(
      position: Offset(
        random.nextDouble() * width,
        random.nextDouble() * height,
      ),
      velocity: Offset(
        (random.nextDouble() - 0.5) * 0.5,
        (random.nextDouble() - 0.5) * 0.5,
      ),
      size: random.nextDouble() * 6 + 2,
      color: Color.fromRGBO(
        99 + random.nextInt(50), // Purple range
        102 + random.nextInt(50),
        241 + random.nextInt(50),
        1,
      ),
      opacity: random.nextDouble() * 0.3 + 0.1,
    );
  }

  void update(double deltaTime, Size screenSize) {
    position += velocity * deltaTime * 30;

    // Wrap around screen edges with some margin
    final margin = 50.0;
    if (position.dx < -margin) {
      position = Offset(screenSize.width + margin, position.dy);
    }
    if (position.dx > screenSize.width + margin) {
      position = Offset(-margin, position.dy);
    }
    if (position.dy < -margin) {
      position = Offset(position.dx, screenSize.height + margin);
    }
    if (position.dy > screenSize.height + margin) {
      position = Offset(position.dx, -margin);
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final BoxConstraints constraints;

  ParticlePainter(this.particles, this.animationValue, this.constraints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update(0.016, size); // Approximate 60fps delta time

      paint.color = particle.color.withValues(alpha: particle.opacity);

      // Create subtle glow effect
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(particle.position, particle.size * 1.5, glowPaint);
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
