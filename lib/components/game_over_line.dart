import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameOverLine extends PositionComponent {
  GameOverLine({
    required this.lineY,
    required this.leftX,
    required this.rightX,
  });

  final double lineY;
  final double leftX;
  final double rightX;

  final Paint _paint = Paint()
    ..color = const Color(0x55E74C3C)
    ..strokeWidth = 0.03
    ..style = PaintingStyle.stroke;

  static const double _dashLen = 0.15;
  static const double _gapLen = 0.10;

  @override
  void render(Canvas canvas) {
    double x = leftX;
    while (x < rightX) {
      final end = (x + _dashLen).clamp(leftX, rightX);
      canvas.drawLine(Offset(x, lineY), Offset(end, lineY), _paint);
      x += _dashLen + _gapLen;
    }
  }
}
