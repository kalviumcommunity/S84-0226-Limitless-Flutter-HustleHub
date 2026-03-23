import 'package:flutter/material.dart';

class TypewriterAnimation extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final Duration delayBetweenCharacters;
  final Curve curve;

  const TypewriterAnimation({
    super.key,
    required this.text,
    this.style = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    this.duration = const Duration(milliseconds: 2000),
    this.delayBetweenCharacters = const Duration(milliseconds: 50),
    this.curve = Curves.linear,
  });

  @override
  State<TypewriterAnimation> createState() => _TypewriterAnimationState();
}

class _TypewriterAnimationState extends State<TypewriterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _displayedCharacters;

  @override
  void initState() {
    super.initState();
    _displayedCharacters = 0;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addListener(_updateDisplayedCharacters);
    _controller.forward();
  }

  void _updateDisplayedCharacters() {
    final progress = (_controller.value * widget.text.length).toInt();
    setState(() => _displayedCharacters = progress);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _displayedCharacters),
      style: widget.style,
    );
  }
}

class AnimatedTextSwitch extends StatefulWidget {
  final List<String> texts;
  final TextStyle style;
  final Duration displayDuration;
  final Duration transitionDuration;
  final TextAlign textAlign;

  const AnimatedTextSwitch({
    super.key,
    required this.texts,
    this.style = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    this.displayDuration = const Duration(seconds: 3),
    this.transitionDuration = const Duration(milliseconds: 500),
    this.textAlign = TextAlign.center,
  });

  @override
  State<AnimatedTextSwitch> createState() => _AnimatedTextSwitchState();
}

class _AnimatedTextSwitchState extends State<AnimatedTextSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _controller = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
    );

    _startTextCycle();
  }

  void _startTextCycle() {
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.forward().then((_) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.texts.length;
          });
          _controller.reset();
          _startTextCycle();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(
        widget.texts[_currentIndex],
        style: widget.style,
        textAlign: widget.textAlign,
      ),
    );
  }
}

class GradientTextAnimation extends StatefulWidget {
  final String text;
  final TextStyle baseStyle;
  final List<Color> gradientColors;
  final Duration duration;

  const GradientTextAnimation({
    super.key,
    required this.text,
    this.baseStyle = const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    this.gradientColors = const [Color(0xFF6200EA), Color(0xFF03DAC6)],
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<GradientTextAnimation> createState() => _GradientTextAnimationState();
}

class _GradientTextAnimationState extends State<GradientTextAnimation>
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              tileMode: TileMode.clamp,
              colors: widget.gradientColors,
              stops: [
                _controller.value,
                _controller.value + 0.5,
              ],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.baseStyle.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}

class CharteredTextAnimation extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final List<Color>? characterColors;

  const CharteredTextAnimation({
    super.key,
    required this.text,
    this.style = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    this.duration = const Duration(milliseconds: 1200),
    this.characterColors,
  });

  @override
  State<CharteredTextAnimation> createState() => _CharteredTextAnimationState();
}

class _CharteredTextAnimationState extends State<CharteredTextAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.text.length,
      (index) => AnimationController(duration: widget.duration, vsync: this),
    );

    Future.doWhile(() async {
      for (final controller in _controllers) {
        if (mounted) {
          controller.forward();
          await Future.delayed(const Duration(milliseconds: 50));
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.text.length, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            final color = widget.characterColors != null
                ? Color.lerp(
                    Colors.grey,
                    widget.characterColors![index %
                        widget.characterColors!.length],
                    _controllers[index].value,
                  )
                : Colors.black;

            return Transform.translate(
              offset: Offset(0, -sin(_controllers[index].value * pi) * 12),
              child: Text(
                widget.text[index],
                style: widget.style.copyWith(color: color),
              ),
            );
          },
        );
      }),
    );
  }
}

class RotatingTextAnimation extends StatefulWidget {
  final List<String> words;
  final TextStyle style;
  final Duration duration;

  const RotatingTextAnimation({
    super.key,
    required this.words,
    this.style = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<RotatingTextAnimation> createState() => _RotatingTextAnimationState();
}

class _RotatingTextAnimationState extends State<RotatingTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _startRotation();
  }

  void _startRotation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.forward().then((_) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.words.length;
          });
          _controller.reset();
          _startRotation();
        });
      }
    });
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
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_controller.value * 3.14159),
          child: _controller.value <= 0.5
              ? Text(
                  widget.words[_currentIndex],
                  style: widget.style,
                )
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(3.14159),
                  child: Text(
                    widget.words[(_currentIndex + 1) % widget.words.length],
                    style: widget.style,
                  ),
                ),
        );
      },
    );
  }
}

class UnderlineAnimation extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color underlineColor;
  final Duration duration;

  const UnderlineAnimation({
    super.key,
    required this.text,
    this.style = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    this.underlineColor = const Color(0xFF6200EA),
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<UnderlineAnimation> createState() => _UnderlineAnimationState();
}

class _UnderlineAnimationState extends State<UnderlineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
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
            border: Border(
              bottom: BorderSide(
                color: widget.underlineColor,
                width: 3,
              ),
            ),
          ),
          child: ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: _controller.value,
              child: Text(
                widget.text,
                style: widget.style,
              ),
            ),
          ),
        );
      },
    );
  }
}
