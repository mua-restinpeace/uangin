import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:uangin/core/theme/colors.dart';

class CustomChart extends StatelessWidget {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double strokeWidth;
  final double size;

  const CustomChart(
      {required this.data,
      required this.colors,
      required this.strokeWidth,
      required this.size,
      super.key});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(
      0.0,
      (sum, value) => sum + value,
    );
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RoundedDonutChartPainter(
            context: context,
            data: data,
            colors: colors,
            total: total,
            strokeWidth: strokeWidth),
      ),
    );
  }
}

class _RoundedDonutChartPainter extends CustomPainter {
  final BuildContext context;
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double strokeWidth;
  final double total;

  const _RoundedDonutChartPainter(
      {required this.context,
      required this.data,
      required this.colors,
      required this.total,
      required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth - 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;
    const gapAngle = 0.2;

    data.forEach(
      (category, value) {
        final sweepAngle = (value / total) * 2 * math.pi - gapAngle;
        final color = colors[category] ?? MyColors.grey;

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

        canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

        final textAngle = startAngle + sweepAngle / 2;
        final textPercentage = (value / total * 100).toStringAsFixed(0);

        _drawPercentageText(
            canvas, center, radius, textAngle, '$textPercentage%');

        startAngle += sweepAngle + gapAngle;
      },
    );
  }

  void _drawPercentageText(
      Canvas canvas, Offset center, double radius, double angle, String text) {
    final textX = center.dx + radius * math.cos(angle);
    final textY = center.dy + radius * math.sin(angle);

    final textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: const TextStyle(
                color: MyColors.black,
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
