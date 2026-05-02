import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class Walls extends Component {
  Walls({
    required this.leftX,
    required this.rightX,
    required this.topY,
    required this.bottomY,
  });

  final double leftX;
  final double rightX;
  final double topY;
  final double bottomY;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addAll([
      WallEdge(from: Vector2(leftX, topY), to: Vector2(leftX, bottomY)),
      WallEdge(from: Vector2(rightX, topY), to: Vector2(rightX, bottomY)),
      WallEdge(from: Vector2(leftX, bottomY), to: Vector2(rightX, bottomY)),
    ]);
  }
}

class WallEdge extends BodyComponent {
  WallEdge({required this.from, required this.to});

  final Vector2 from;
  final Vector2 to;

  @override
  Body createBody() {
    final body = world.createBody(BodyDef(type: BodyType.static));
    final shape = EdgeShape()..set(from, to);
    body.createFixture(FixtureDef(shape, friction: 0.3));
    return body;
  }

  @override
  void render(Canvas canvas) {}
}
