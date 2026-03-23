import 'package:flutter/material.dart';

class FlipAnimation extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  final bool autoFlip;

  const FlipAnimation({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 600),
    this.autoFlip = false,
  });

  @override
  State<FlipAnimation> createState() => _FlipAnimationState();
}

class _FlipAnimationState extends State<FlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.autoFlip) {
      _startAutoFlip();
    }
  }

  void _startAutoFlip() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _toggleFlip();
        _startAutoFlip();
      }
    });
  }

  void _toggleFlip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 3.14159;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: angle <= 1.5708
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}

class HoverAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scaleAmount;
  final double elevationAmount;

  const HoverAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.scaleAmount = 1.05,
    this.elevationAmount = 8,
  });

  @override
  State<HoverAnimation> createState() => _HoverAnimationState();
}

class _HoverAnimationState extends State<HoverAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleAmount)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _elevationAnimation =
        Tween<double>(begin: 0, end: widget.elevationAmount).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() => _controller.forward();
  void _onExit() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: _elevationAnimation.value,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class WaveAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double amplitude;
  final double frequency;

  const WaveAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.amplitude = 10,
    this.frequency = 2,
  });

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final wave = sin(_controller.value * 2 * pi * widget.frequency) *
            widget.amplitude;
        return Transform.translate(
          offset: Offset(wave, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class RotateOnHoverAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double rotationAmount;

  const RotateOnHoverAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.rotationAmount = 0.25,
  });

  @override
  State<RotateOnHoverAnimation> createState() => _RotateOnHoverAnimationState();
}

class _RotateOnHoverAnimationState extends State<RotateOnHoverAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() => _controller.forward();
  void _onExit() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: RotationTransition(
        turns: Tween<double>(begin: 0, end: widget.rotationAmount)
            .animate(_controller),
        child: widget.child,
      ),
    );
  }
}

class GlowAnimation extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final Duration duration;
  final double maxBlur;

  const GlowAnimation({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF6200EA),
    this.duration = const Duration(milliseconds: 1500),
    this.maxBlur = 20,
  });

  @override
  State<GlowAnimation> createState() => _GlowAnimationState();
}

class _GlowAnimationState extends State<GlowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _glowAnimation =
        Tween<double>(begin: 0, end: widget.maxBlur).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.5),
                blurRadius: _glowAnimation.value,
                spreadRadius: _glowAnimation.value / 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
