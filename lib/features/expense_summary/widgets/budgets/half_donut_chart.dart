import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:uangin/core/theme/colors.dart';

class HalfDonutChart extends StatefulWidget {
  final double size;
  final double totalAllocated;
  final double strokeWidth;
  final double spentAmount;
  const HalfDonutChart(
      {required this.size,
      required this.totalAllocated,
      required this.strokeWidth,
      required this.spentAmount,
      super.key});

  @override
  State<HalfDonutChart> createState() => _HalfDonutChartState();
}

class _HalfDonutChartState extends State<HalfDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _curvedAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size / 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _HalfDonutChartPainter(
                context: context,
                strokeWidth: widget.strokeWidth,
                totalAllowance: widget.totalAllocated,
                spentAmount: widget.spentAmount,
                animationController: _curvedAnimation),
          );
        },
      ),
    );
  }
}

class _HalfDonutChartPainter extends CustomPainter {
  final BuildContext context;
  final double strokeWidth;
  final double totalAllowance;
  final double spentAmount;
  final Animation<double> animationController;

  const _HalfDonutChartPainter(
      {required this.context,
      required this.strokeWidth,
      required this.totalAllowance,
      required this.spentAmount,
      required this.animationController});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth - 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = math.pi;
    double sweepAngle = math.pi;

    final unusedOutlinePaint = Paint()
      ..color = MyColors.lightGrey
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 50
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, startAngle, sweepAngle, false, unusedOutlinePaint);

    final unusedbudgetPaint = Paint()
      ..color = MyColors.fillColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, startAngle, sweepAngle, false, unusedbudgetPaint);

    final usedBudgetSweepAngle =
        Tween<double>(begin: 0, end: (spentAmount / totalAllowance).clamp(0.0, 1.0) * math.pi)
            .animate(animationController);

    final usedOutlinePaint = Paint()
      ..color = Color(int.parse('0xFFA0D037'))
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
        rect, startAngle, usedBudgetSweepAngle.value, false, usedOutlinePaint);

    final usedBudgetPaint = Paint()
      ..color = Theme.of(context).colorScheme.primary
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
        rect, startAngle, usedBudgetSweepAngle.value, false, usedBudgetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
