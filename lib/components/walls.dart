import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class Walls extends Component with HasGameRef {
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
    final forge2dGame = gameRef as Forge2DGame;

    _addEdge(forge2dGame, Vector2(leftX, topY), Vector2(leftX, bottomY));
    _addEdge(forge2dGame, Vector2(rightX, topY), Vector2(rightX, bottomY));
    _addEdge(forge2dGame, Vector2(leftX, bottomY), Vector2(rightX, bottomY));

    add(WallLine(from: Vector2(leftX, topY), to: Vector2(leftX, bottomY)));
    add(WallLine(from: Vector2(rightX, topY), to: Vector2(rightX, bottomY)));
    add(WallLine(from: Vector2(leftX, bottomY), to: Vector2(rightX, bottomY)));
  }

  void _addEdge(Forge2DGame game, Vector2 from, Vector2 to) {
    final bodyDef = BodyDef(type: BodyType.static);
    final body = game.world.createBody(bodyDef);
    final shape = EdgeShape()..set(from, to);
    body.createFixture(FixtureDef(shape, friction: 0.3));
  }
}

class WallLine extends PositionComponent {
  WallLine({required this.from, required this.to});

  final Vector2 from;
  final Vector2 to;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from.toOffset(), to.toOffset(), paint);
  }
}
