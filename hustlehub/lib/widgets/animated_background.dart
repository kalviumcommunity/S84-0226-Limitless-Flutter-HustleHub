import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final List<Color> colors;
  final Widget child;
  final Duration duration;

  const AnimatedBackground({
    super.key,
    this.colors = const [Color(0xFF6200EA), Color(0xFF03DAC6)],
    required this.child,
    this.duration = const Duration(seconds: 6),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _colors = widget.colors;
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  _colors[0],
                  _colors[1],
                  _controller.value,
                )!,
                Color.lerp(
                  _colors[1],
                  _colors[0],
                  _controller.value,
                )!,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
