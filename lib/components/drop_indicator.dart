import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DropIndicator extends PositionComponent with HasGameRef {
  DropIndicator({required double worldX, required this.topY, required this.bottomY})
      : _worldX = worldX,
        super(priority: 10);

  double _worldX;
  final double topY;
  final double bottomY;

  void updateX(double worldX) {
    _worldX = worldX;
  }

  final Paint _paint = Paint()
    ..color = Colors.white38
    ..strokeWidth = 0.1
    ..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    canvas.drawLine(Offset(_worldX, topY), Offset(_worldX, bottomY), _paint);
  }
}
