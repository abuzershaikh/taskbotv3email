import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui' show PathMetrics, PathMetric;

// The main widget for the animated outline
class ClickableOutline extends StatefulWidget {
  final Widget child;
  final Future<void> Function() action;
  final ValueNotifier<String>? captionNotifier;
  final String? caption;

  // The constructor is corrected to handle the key properly.
  const ClickableOutline({
    super.key,
    required this.child,
    required this.action,
    this.captionNotifier,
    this.caption,
  });

  @override
  ClickableOutlineState createState() => ClickableOutlineState();
}

// The State class with advanced animation logic
class ClickableOutlineState extends State<ClickableOutline>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isStateMounted = false;

  // Controllers for different animations
  late AnimationController _drawController;
  late AnimationController _flickerController;

  // Animation objects
  late Animation<double> _drawAnimation;
  late Animation<double> _flickerAnimation;

  // Random properties for each animation instance
  Paint _randomPaint = Paint();
  int _animationType = 0;
  bool _shouldFlicker = false;

  @override
  void initState() {
    super.initState();
    _isStateMounted = true;

    // Controller for drawing the outline
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _drawAnimation =
        CurvedAnimation(parent: _drawController, curve: Curves.easeInOut);

    // Controller for the flicker/blink effect
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _flickerAnimation =
        Tween<double>(begin: 1.0, end: 0.4).animate(_flickerController);
  }

  @override
  void dispose() {
    _isStateMounted = false;
    _drawController.dispose();
    _flickerController.dispose();
    _removeOutline();
    super.dispose();
  }

  /// Generates random properties for the next animation
  void _generateRandomProperties() {
    final random = Random();

    // Color selection with 60% probability for Red
    Color chosenColor;
    if (random.nextDouble() < 0.60) {
      chosenColor = Colors.red;
    } else {
      final otherColors = [Colors.yellow, Colors.green, Colors.pink];
      chosenColor = otherColors[random.nextInt(otherColors.length)];
    }

    _randomPaint = Paint()
      ..color = chosenColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Random animation style
    _animationType = random.nextInt(3);

    // Random flicker
    _shouldFlicker = random.nextBool();
  }

  Future<void> triggerOutlineAndAction({required Duration outlineDuration, String? specificCaption}) async {
    if (!_isStateMounted) return;

    _showOutline();
    _updateCaption(specificCaption ?? widget.caption);

    await Future.delayed(outlineDuration);

    if (_isStateMounted) {
      // Animate out
      await _drawController.reverse();
      _flickerController.stop();

      _removeOutline();
      await widget.action();
    }
  }

  Future<void> triggerOutlineAndExecute(
    Future<void> Function() specificAction, {
    Duration outlineDuration = const Duration(seconds: 2),
    String? specificCaption,
  }) async {
    if (!_isStateMounted) return;

    _showOutline();
    _updateCaption(specificCaption ?? widget.caption);

    await Future.delayed(outlineDuration);

    if (_isStateMounted) {
      // Animate out
      await _drawController.reverse();
      _flickerController.stop();
      _removeOutline();
      await specificAction(); // Execute the custom action
    }
  }

  void _updateCaption(String? text) {
    if (widget.captionNotifier != null && text != null) {
      widget.captionNotifier!.value = text;
    }
  }

  void _showOutline() {
    _removeOutline(); // Clear previous overlay

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Generate new random properties for this animation
    _generateRandomProperties();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy,
        width: size.width,
        height: size.height,
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: Listenable.merge([_drawAnimation, _flickerAnimation]),
            builder: (context, child) {
              Widget painterWidget = CustomPaint(
                painter: _OutlinePainter(
                  progress: _drawAnimation.value,
                  outlinePaint: _randomPaint,
                  animationType: _animationType,
                ),
              );

              // Apply flicker effect if chosen
              if (_shouldFlicker) {
                painterWidget = Opacity(
                  opacity: _flickerAnimation.value,
                  child: painterWidget,
                );
              }

              return painterWidget;
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Start all animations
    _drawController.forward(from: 0.0);
    if (_shouldFlicker) {
      _flickerController.repeat(reverse: true);
    }
  }

  void _removeOutline() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Custom Painter to draw the animated outline
class _OutlinePainter extends CustomPainter {
  final double progress;
  final Paint outlinePaint;
  final int animationType;

  _OutlinePainter(
      {required this.progress,
      required this.outlinePaint,
      required this.animationType});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    // Use a rounded rectangle for a better look
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8.0),
    );
    final Path path = Path()..addRRect(rrect);

    // Choose a random drawing style
    switch (animationType) {
      case 0:
        _drawSinglePath(canvas, path, progress);
        break;
      case 1:
        _drawExpandingSides(canvas, size, progress);
        break;
      case 2:
        _drawDashedPath(canvas, path, progress);
        break;
    }
  }

  void _drawSinglePath(Canvas canvas, Path path, double progress) {
    final PathMetrics pathMetrics = path.computeMetrics();
    for (final PathMetric pathMetric in pathMetrics) {
      final Path extractedPath =
          pathMetric.extractPath(0.0, pathMetric.length * progress);
      canvas.drawPath(extractedPath, outlinePaint);
    }
  }
  
  void _drawExpandingSides(Canvas canvas, Size size, double progress) {
    double halfWidth = size.width / 2;
    double halfHeight = size.height / 2;
    // Draw horizontal lines expanding from the center
    canvas.drawLine(Offset(halfWidth * (1 - progress), 0),
        Offset(halfWidth * (1 + progress), 0), outlinePaint);
    canvas.drawLine(
        Offset(halfWidth * (1 - progress), size.height),
        Offset(halfWidth * (1 + progress), size.height),
        outlinePaint);
    // Draw vertical lines expanding from the center
    canvas.drawLine(Offset(0, halfHeight * (1 - progress)),
        Offset(0, halfHeight * (1 + progress)), outlinePaint);
    canvas.drawLine(Offset(size.width, halfHeight * (1 - progress)),
        Offset(size.width, halfHeight * (1 + progress)), outlinePaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, double progress) {
    final PathMetrics pathMetrics = path.computeMetrics();
    for (final PathMetric pathMetric in pathMetrics) {
      final double totalLength = pathMetric.length;
      final int dashCount = 20;
      final double dashLength = totalLength / dashCount;
      final double gapLength = dashLength * 0.5; // Small gap

      for (int i = 0; i < dashCount; i++) {
        final double start = (dashLength + gapLength) * i;
        final double end = start + (dashLength * progress);
        if (start < totalLength * progress) {
          final Path extractedPath = pathMetric.extractPath(start, end);
          canvas.drawPath(extractedPath, outlinePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OutlinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
