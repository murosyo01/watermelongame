import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../models/fruit_level.dart';

class Fruit extends BodyComponent {
  Fruit({required this.level, required Vector2 spawnPosition})
      : _spawnPosition = spawnPosition;

  final FruitLevel level;
  final Vector2 _spawnPosition;
  bool pendingMerge = false;
  bool hasEnteredField = false;
  double timeSinceSpawn = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    timeSinceSpawn += dt;
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: _spawnPosition,
    );
    final body = world.createBody(bodyDef);
    final shape = CircleShape()..radius = level.radius;
    final fixtureDef = FixtureDef(
      shape,
      density: 1.0,
      friction: 0.3,
      restitution: 0.2,
    );
    body.createFixture(fixtureDef);
    body.userData = this;
    return body;
  }

  @override
  void render(Canvas canvas) {
    final r = level.radius;
    final color = level.color;

    canvas.drawCircle(
      Offset.zero,
      r + 0.06,
      Paint()
        ..color = color.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.95,
          colors: [
            Color.lerp(color, Colors.white, 0.55)!,
            color,
            Color.lerp(color, Colors.black, 0.35)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.04,
    );

    canvas.drawCircle(
      Offset(-r * 0.28, -r * 0.3),
      r * 0.22,
      Paint()..color = Colors.white.withOpacity(0.22),
    );
  }
}
