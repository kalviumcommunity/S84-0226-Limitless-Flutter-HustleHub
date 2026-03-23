import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
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
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0, -1.0),
              end: Alignment(2.0, 2.0),
              stops: [
                _shimmerAnimation.value - 1,
                _shimmerAnimation.value - 0.5,
                _shimmerAnimation.value,
              ],
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class CircularProgressAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final Duration duration;

  const CircularProgressAnimation({
    super.key,
    this.size = 50,
    this.color = const Color(0xFF6200EA),
    this.strokeWidth = 4,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<CircularProgressAnimation> createState() =>
      _CircularProgressAnimationState();
}

class _CircularProgressAnimationState extends State<CircularProgressAnimation>
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
      turns: _controller,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(widget.color),
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );
  }
}

class DotProgressAnimation extends StatefulWidget {
  final int dotCount;
  final double dotSize;
  final Color color;
  final Duration duration;
  final double spacing;

  const DotProgressAnimation({
    super.key,
    this.dotCount = 3,
    this.dotSize = 12,
    this.color = const Color(0xFF6200EA),
    this.duration = const Duration(milliseconds: 1200),
    this.spacing = 8,
  });

  @override
  State<DotProgressAnimation> createState() => _DotProgressAnimationState();
}

class _DotProgressAnimationState extends State<DotProgressAnimation>
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        final delay = (index / widget.dotCount);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value =
                ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = (1 - (value - 0.5).abs() * 2).clamp(0.3, 1.0);

            return Transform.translate(
              offset: Offset(0, -sin(value * pi) * 8),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  margin:
                      EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
