import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../models/fruit_level.dart';

class Fruit extends BodyComponent {
  Fruit({required this.level, required Vector2 spawnPosition})
      : _spawnPosition = spawnPosition;

  final FruitLevel level;
  final Vector2 _spawnPosition;
  bool pendingMerge = false;

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
    final paint = Paint()..color = level.color;
    canvas.drawCircle(Offset.zero, level.radius, paint);

    final borderPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.05;
    canvas.drawCircle(Offset.zero, level.radius, borderPaint);
  }
}
