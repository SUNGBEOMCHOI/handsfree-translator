import 'package:flutter/material.dart';

import 'dart:math' as math;

class RecordingIndicator extends StatefulWidget {
  final double size;
  final ValueNotifier<bool> isProcessing;

  const RecordingIndicator({this.size = 200.0, required this.isProcessing});

  @override
  _RecordingIndicatorState createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;
  // late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0 * math.pi,
    ).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(_controller);

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(_controller);

    widget.isProcessing.addListener(_updateAnimation);
  }

  void _updateAnimation() {
    if (widget.isProcessing.value) {
      // Change the animation when processing is happening
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _opacityAnimation = Tween<double>(
        begin: 1.0,
        end: 0.4,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    } else {
      // Restore the original animation when processing is done
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.0,
      ).animate(_controller);
      _opacityAnimation = Tween<double>(
        begin: 1.0,
        end: 1.0,
      ).animate(_controller);
    }
  }

  @override
  void dispose() {
    widget.isProcessing.removeListener(_updateAnimation);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, widget.isProcessing]),
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    width: 2.0, color: Theme.of(context).primaryColorDark),
              ),
              child: Stack(
                children: [
                  Center(
                    child: !widget.isProcessing.value
                        ? Icon(
                            Icons.mic,
                            size: widget.size * 0.6,
                            color: Theme.of(context).primaryColorDark,
                          )
                        : null,
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return ClipPath(
                        clipper: WaveClipper(_waveAnimation.value),
                        child: Center(
                          child: Container(
                            width: widget.size,
                            height: widget.size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double wavePhase;

  WaveClipper(this.wavePhase);

  @override
  Path getClip(Size size) {
    final path = Path();

    final amplitude = size.width / 20;
    final wavelength = size.width / 2;

    final originY = size.height / 2;
    final originX = size.width / 2 - wavelength;

    path.moveTo(originX, originY);

    for (double x = originX; x < size.width; x++) {
      final y = amplitude *
              math.sin((x - originX) * 2 * math.pi / wavelength + wavePhase) +
          originY;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(originX, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => true;
}
