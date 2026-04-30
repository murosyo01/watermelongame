import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../models/fruit_level.dart';

class NextFruitPreview extends PositionComponent {
  NextFruitPreview({
    required FruitLevel level,
    required Vector2 center,
  })  : _level = level,
        super(position: center, anchor: Anchor.center);

  FruitLevel _level;

  static const double _scaleFactor = 15.0;

  final Paint _borderPaint = Paint()
    ..color = Colors.black45
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  void updateLevel(FruitLevel level) {
    _level = level;
  }

  double get _displayRadius => _level.radius * _scaleFactor;

  @override
  void render(Canvas canvas) {
    final fillPaint = Paint()..color = _level.color;
    canvas.drawCircle(Offset.zero, _displayRadius, fillPaint);
    canvas.drawCircle(Offset.zero, _displayRadius, _borderPaint);
  }
}
