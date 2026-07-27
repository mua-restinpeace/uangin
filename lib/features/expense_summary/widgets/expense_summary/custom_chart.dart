import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:uangin/core/theme/colors.dart';

class CustomChart extends StatefulWidget {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double strokeWidth;
  final double size;
  final double totalAllocated;

  const CustomChart(
      {required this.data,
      required this.colors,
      required this.strokeWidth,
      required this.size,
      required this.totalAllocated,
      super.key});

  @override
  State<CustomChart> createState() => _CustomChartState();
}

class _CustomChartState extends State<CustomChart>
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
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RoundedDonutChartPainter(
                context: context,
                data: widget.data,
                colors: widget.colors,
                totalAllocated: widget.totalAllocated,
                strokeWidth: widget.strokeWidth,
                animationController: _curvedAnimation),
          );
        },
      ),
    );
  }
}

class _RoundedDonutChartPainter extends CustomPainter {
  final BuildContext context;
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double strokeWidth;
  final double totalAllocated;
  final Animation<double> animationController;

  const _RoundedDonutChartPainter(
      {required this.context,
      required this.data,
      required this.colors,
      required this.totalAllocated,
      required this.strokeWidth,
      required this.animationController});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth - 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;
    const gapAngle = 0.36;

    final totalSpent = data.values.fold(
      0.0,
      (previousValue, element) => previousValue + element,
    );
    final unallocated = totalAllocated - totalSpent;

    final sectionCount = data.length + (unallocated > 0 ? 1 : 0);
    final totalGaps = gapAngle * sectionCount;
    final usableCircle = (2 * math.pi) - totalGaps;

    data.forEach(
      (category, value) {
        final sweepAngle = Tween<double>(
                begin: 0, end: (value / totalAllocated) * usableCircle)
            .animate(animationController);
        final color = colors[category] ?? MyColors.grey;

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

        canvas.drawArc(rect, startAngle, sweepAngle.value, false, paint);

        final percentage = (value / totalAllocated * 100);
        if (percentage > 3) {
          final textAngle = startAngle + sweepAngle.value / 2;

          _drawPercentageText(canvas, center, radius, textAngle,
              '${percentage.toStringAsFixed(0)}%');
        }

        startAngle += sweepAngle.value + gapAngle;
      },
    );

    if (unallocated > 0) {
      final unallocatedSweepAngle =
          (unallocated / totalAllocated) * usableCircle;

      final paint = Paint()
        ..color = MyColors.lightGrey.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      canvas.drawArc(rect, startAngle, unallocatedSweepAngle, false, paint);
      // final unallocatedPercentage = (unallocated / totalAllocated * 100);

      // if (unallocatedPercentage > 3) {
      //   final textAngle = startAngle + unallocatedSweepAngle / 2;
      //   _drawPercentageText(canvas, center, radius, textAngle,
      //       '${unallocatedPercentage.toStringAsFixed(0)}%');
      // }
    }
  }

  void _drawPercentageText(
      Canvas canvas, Offset center, double radius, double angle, String text) {
    final textX = center.dx + radius * math.cos(angle);
    final textY = center.dy + radius * math.sin(angle);

    final textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: const TextStyle(
                color: MyColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr);

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            textX - (textPainter.width / 2), textY - (textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
