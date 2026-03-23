import 'package:flutter/material.dart';

class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double intensity;
  final bool autoPlay;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.intensity = 10,
    this.autoPlay = false,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _offset = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );

    if (widget.autoPlay) {
      _startShake();
    }
  }

  void _startShake() {
    _controller.forward().then((_) {
      _controller.reset();
    });
  }

  void shake() {
    _startShake();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: shake,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) {
          final progress = _controller.value;
          final offset = sin(progress * 6 * pi) * widget.intensity;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class BouncyAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double bouncePower;

  const BouncyAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.bouncePower = 0.3,
  });

  @override
  State<BouncyAnimation> createState() => _BouncyAnimationState();
}

class _BouncyAnimationState extends State<BouncyAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _bounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounce,
      child: widget.child,
    );
  }
}

class JelloAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const JelloAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<JelloAnimation> createState() => _JelloAnimationState();
}

class _JelloAnimationState extends State<JelloAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.forward();
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
        final progress = _controller.value;
        final skewX = sin(progress * pi * 2) * 0.02;
        final skewY = cos(progress * pi * 2) * 0.02;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(1, 0, skewX)
            ..setEntry(0, 1, skewY),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class HeartbeatAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const HeartbeatAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1300),
  });

  @override
  State<HeartbeatAnimation> createState() => _HeartbeatAnimationState();
}

class _HeartbeatAnimationState extends State<HeartbeatAnimation>
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
        final progress = _controller.value;
        double scale = 1.0;

        if (progress < 0.25) {
          scale = 1.0 + (progress / 0.25) * 0.15;
        } else if (progress < 0.35) {
          scale = 1.15 - ((progress - 0.25) / 0.1) * 0.15;
        } else if (progress < 0.6) {
          scale = 1.0 + ((progress - 0.35) / 0.25) * 0.15;
        } else {
          scale = 1.15 - ((progress - 0.6) / 0.4) * 0.15;
        }

        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

class SlideInFromBottomAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const SlideInFromBottomAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
  });

  @override
  State<SlideInFromBottomAnimation> createState() =>
      _SlideInFromBottomAnimationState();
}

class _SlideInFromBottomAnimationState extends State<SlideInFromBottomAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: widget.child);
  }
}

class ZoomInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const ZoomInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
  });

  @override
  State<ZoomInAnimation> createState() => _ZoomInAnimationState();
}

class _ZoomInAnimationState extends State<ZoomInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}

class InfiniteRotationAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double rotations;

  const InfiniteRotationAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.rotations = 1.0,
  });

  @override
  State<InfiniteRotationAnimation> createState() =>
      _InfiniteRotationAnimationState();
}

class _InfiniteRotationAnimationState extends State<InfiniteRotationAnimation>
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
    return RotationTransition(
      turns: Tween<double>(begin: 0, end: widget.rotations)
          .animate(_controller),
      child: widget.child,
    );
  }
}
