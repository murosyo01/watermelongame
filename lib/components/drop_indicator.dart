import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/fruit_level.dart';

class DropIndicator extends PositionComponent {
  DropIndicator({
    required double worldX,
    required this.topY,
    required FruitLevel initialLevel,
    this.containerLeft = -2.0,
    this.containerRight = 2.0,
  }) : _worldX = worldX,
       _level = initialLevel,
       super(priority: 10);

  double _worldX;
  final double topY;
  final double containerLeft;
  final double containerRight;
  FruitLevel _level;

  double get worldX => _worldX;

  void updateX(double worldX) => _worldX = worldX;
  void updateLevel(FruitLevel level) => _level = level;

  bool get _isWarn =>
      _worldX <= containerLeft + _level.radius + 0.06 ||
      _worldX >= containerRight - _level.radius - 0.06;

  @override
  void render(Canvas canvas) {
    final effectiveColor = _isWarn ? const Color(0xFFE74C3C) : _level.color;
    final ghostCy = topY + _level.radius + 0.05;
    final r = _level.radius;
    final center = Offset(_worldX, ghostCy);

    // グロー（Fruit.render と同じアプローチ）
    canvas.drawCircle(
      center,
      r + 0.06,
      Paint()
        ..color = effectiveColor.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // ゴースト塗りつぶし円
    canvas.drawCircle(
      center,
      r,
      Paint()..color = effectiveColor.withValues(alpha: 0.25),
    );
    // 輪郭（少し太めのstrokeでImpellerでも綺麗に出る）
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = effectiveColor.withValues(alpha: 0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.15,
    );
  }
}
