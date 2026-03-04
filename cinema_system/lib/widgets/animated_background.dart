import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
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
      builder: (_, __) {
        final t = _controller.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                cos(2 * pi * t),
                sin(2 * pi * t),
              ),
              end: Alignment(
                -cos(2 * pi * t),
                -sin(2 * pi * t),
              ),
              colors: const [
                Color.fromARGB(255, 3, 7, 43),
                Color.fromARGB(255, 27, 32, 125),
                Color.fromARGB(255, 79, 74, 208),
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
