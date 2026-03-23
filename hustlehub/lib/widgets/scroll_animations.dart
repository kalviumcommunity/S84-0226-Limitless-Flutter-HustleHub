import 'package:flutter/material.dart';

class ParallaxFlowDelegate extends FlowDelegate {
  final ScrollOffset scrollOffset;

  ParallaxFlowDelegate({required this.scrollOffset});

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; i++) {
      final isMainContent = i == 0;
      final parallaxAmount = scrollOffset.pixels * (isMainContent ? 0.0 : 0.2);
      context.paintChild(
        i,
        transform: Matrix4.identity()
          ..translate(0.0, parallaxAmount),
      );
    }
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) =>
      scrollOffset != oldDelegate.scrollOffset;
}

class ScrollOffset {
  final double pixels;
  const ScrollOffset(this.pixels);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScrollOffset &&
          runtimeType == other.runtimeType &&
          pixels == other.pixels;

  @override
  int get hashCode => pixels.hashCode;
}

class FadeOnScrollAnimation extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final double fadeStartOffset;
  final double fadeEndOffset;

  const FadeOnScrollAnimation({
    super.key,
    required this.child,
    required this.scrollController,
    this.fadeStartOffset = 0,
    this.fadeEndOffset = 200,
  });

  @override
  State<FadeOnScrollAnimation> createState() => _FadeOnScrollAnimationState();
}

class _FadeOnScrollAnimationState extends State<FadeOnScrollAnimation> {
  late double _opacity;

  @override
  void initState() {
    super.initState();
    _opacity = 1.0;
    widget.scrollController.addListener(_updateOpacity);
  }

  void _updateOpacity() {
    final scrollPosition = widget.scrollController.position.pixels;
    double newOpacity = 1.0 -
        ((scrollPosition - widget.fadeStartOffset) /
                (widget.fadeEndOffset - widget.fadeStartOffset))
            .clamp(0.0, 1.0);

    setState(() => _opacity = newOpacity);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateOpacity);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: _opacity, child: widget.child);
  }
}

class ScaleOnScrollAnimation extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final double minScale;
  final double scrollThreshold;

  const ScaleOnScrollAnimation({
    super.key,
    required this.child,
    required this.scrollController,
    this.minScale = 0.8,
    this.scrollThreshold = 100,
  });

  @override
  State<ScaleOnScrollAnimation> createState() => _ScaleOnScrollAnimationState();
}

class _ScaleOnScrollAnimationState extends State<ScaleOnScrollAnimation> {
  late double _scale;

  @override
  void initState() {
    super.initState();
    _scale = 1.0;
    widget.scrollController.addListener(_updateScale);
  }

  void _updateScale() {
    final scrollPosition = widget.scrollController.position.pixels;
    double newScale = 1.0 -
        ((scrollPosition / widget.scrollThreshold) * (1 - widget.minScale))
            .clamp(0.0, 1 - widget.minScale);

    setState(() => _scale = newScale);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateScale);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(scale: _scale, child: widget.child);
  }
}

class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;
  final Curve curve;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(duration: widget.itemDuration, vsync: this),
    );

    Future.doWhile(() async {
      for (final controller in _controllers) {
        if (mounted) {
          controller.forward();
          await Future.delayed(widget.itemDelay);
        }
      }
      return false;
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: _controllers[index], curve: widget.curve),
            ),
            child: FadeTransition(
              opacity: _controllers[index],
              child: widget.children[index],
            ),
          );
        },
      ),
    );
  }
}

class BouncyScrollAnimation extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;

  const BouncyScrollAnimation({
    super.key,
    required this.child,
    required this.scrollController,
  });

  @override
  State<BouncyScrollAnimation> createState() => _BouncyScrollAnimationState();
}

class _BouncyScrollAnimationState extends State<BouncyScrollAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _bounceFactor;

  @override
  void initState() {
    super.initState();
    _bounceFactor = 1.0;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    widget.scrollController.addListener(_updateBounce);
  }

  void _updateBounce() {
    final scrollVelocity =
        widget.scrollController.position.activity?.velocity ?? 0;
    if (scrollVelocity.abs() > 100) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateBounce);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.02),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
