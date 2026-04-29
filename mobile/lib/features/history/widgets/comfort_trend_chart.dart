import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/models/history_models.dart';

class ComfortTrendChart extends StatelessWidget {
  const ComfortTrendChart({super.key, required this.points});

  final List<HistoryTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comfort trend',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(
                key: const Key('comfort-trend-painter'),
                painter: _ComfortTrendPainter(
                  points: points,
                  color: theme.colorScheme.primary,
                  gridColor: theme.dividerColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComfortTrendPainter extends CustomPainter {
  const _ComfortTrendPainter({
    required this.points,
    required this.color,
    required this.gridColor,
  });

  final List<HistoryTrendPoint> points;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty) {
      return;
    }

    final ordered = points.length > 8
        ? points.sublist(points.length - 8)
        : points;
    final path = Path();
    for (var i = 0; i < ordered.length; i++) {
      final x = ordered.length == 1
          ? size.width / 2
          : size.width * i / (ordered.length - 1);
      final normalized = ordered[i].comfortScore.clamp(0, 100) / 100;
      final y = size.height - normalized * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (var i = 0; i < ordered.length; i++) {
      final x = ordered.length == 1
          ? size.width / 2
          : size.width * i / max(1, ordered.length - 1);
      final y =
          size.height -
          (ordered[i].comfortScore.clamp(0, 100) / 100) * size.height;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ComfortTrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.gridColor != gridColor;
  }
}
