//import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpinningWheel extends StatefulWidget {
  const SpinningWheel({super.key});

  @override
  State<SpinningWheel> createState() => _SpinningWheelState();
}

double pageNum = 0.0;
double rotationAngle = 0.0;

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int check = 0;
  double startPosition = 0.0;
  double endPosition = 0.0;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0.0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void rotationleft() {
    _animation =
        Tween(begin: 0.0, end: 60.0 / 360.0).animate(_animationController);
    _animationController.reset();
    _animationController.forward();
  }

  void rotationright() {
    _animation = Tween(begin: 120.0 / 360.0, end: 60.0 / 360.0)
        .animate(_animationController);
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        startPosition = details.localPosition.dx;
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        endPosition = details.localPosition.dx;
        if ((startPosition - endPosition) > 20 &&
            !_animationController.isAnimating) {
          if (pageNum == 0) {
            pageNum = 5;
          } else {
            pageNum--;
          }
          print(pageNum);
          rotationright();
        }
        if ((endPosition - startPosition) > 20 &&
            !_animationController.isAnimating) {
          if (pageNum == 5) {
            pageNum = 0;
          } else {
            pageNum++;
          }
          print(pageNum);
          rotationleft();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          if (_animationController.isAnimating) {
            rotationAngle = _animation.value * 2.0 * math.pi;
          }
          return Transform.translate(
            offset: const Offset(0, 550),
            child: Column(
              children: [
                Transform.rotate(
                  angle: rotationAngle,
                  child: CustomPaint(
                    painter: HalfCirclePainter(),
                    child: const SizedBox(
                      width: 225,
                      height: 200,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ));
  }
}

class HalfCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final paint4 = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;

    final paint5 = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.fill;

    final paint6 = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final radius = size.width / 1.5;
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    double startAngle1 = 0 + pageNum * math.pi / 3;
    double startAngle2 = math.pi / 3 + pageNum * math.pi / 3;
    double startAngle3 = math.pi / 3 * 2 + pageNum * math.pi / 3;
    double startAngle4 = math.pi + pageNum * math.pi / 3;
    double startAngle5 = math.pi / 3 * 4 + pageNum * math.pi / 3;
    double startAngle6 = math.pi / 3 * 5 + pageNum * math.pi / 3;
    double sweepAngle = math.pi / 3;
    canvas.drawCircle(center, radius, shadowPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle1,
      sweepAngle,
      true,
      paint1,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle2,
      sweepAngle,
      true,
      paint2,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle3,
      sweepAngle,
      true,
      paint3,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle4,
      sweepAngle,
      true,
      paint4,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle5,
      sweepAngle,
      true,
      paint5,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle6,
      sweepAngle,
      true,
      paint6,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
