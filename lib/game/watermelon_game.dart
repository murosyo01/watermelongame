import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart' as f2d;

import '../components/drop_indicator.dart';
import '../components/fruit.dart';
import '../components/walls.dart';
import '../models/fruit_level.dart';
import '../systems/merge_contact_listener.dart';

class WatermelonGame extends Forge2DGame with TapCallbacks {
  late final MergeContactListener _contactListener;

  WatermelonGame() : super(gravity: Vector2(0, 30)) {
    _contactListener = MergeContactListener(_enqueueMerge);
  }

  static const double containerLeft = -2.0;
  static const double containerRight = 2.0;
  static const double containerBottom = 8.0;
  static const double containerTop = -7.0;
  static const double gameOverLineY = -5.5;
  static const double dropLineY = -6.5;

  late FruitLevel _nextLevel;
  final List<MergePair> _pendingMerges = [];
  double _dropCooldown = 0.0;
  double _gameOverTimer = 0.0;
  bool _gameOver = false;
  int score = 0;

  late TextComponent _scoreText;
  late TextComponent _nextFruitText;
  late DropIndicator _dropIndicator;

  final _rng = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world.physicsWorld.setContactListener(_contactListener);

    final gameWidth = containerRight - containerLeft;
    final gameHeight = containerBottom - containerTop;
    final screenWidth = size.x;
    final screenHeight = size.y;
    
    final zoomX = screenWidth / gameWidth;
    final zoomY = screenHeight / gameHeight;
    camera.viewfinder.zoom = min(zoomX, zoomY) * 0.9;
    camera.viewfinder.position = Vector2(0, 0);

    world.add(Walls(
      leftX: containerLeft,
      rightX: containerRight,
      topY: containerTop,
      bottomY: containerBottom,
    ));

    _nextLevel = _randomLevel();

    _dropIndicator = DropIndicator(
      worldX: 0,
      topY: dropLineY,
      bottomY: containerBottom,
    );
    world.add(_dropIndicator);

    _scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(4, 8),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
    camera.viewport.add(_scoreText);

    _nextFruitText = TextComponent(
      text: 'Next: ${_getFruitName(_nextLevel)}',
      position: Vector2(4, 28),
      textRenderer: TextPaint(
        style: TextStyle(color: _nextLevel.color, fontSize: 14),
      ),
    );
    camera.viewport.add(_nextFruitText);
  }

  String _getFruitName(FruitLevel level) {
    return level.name[0].toUpperCase() + level.name.substring(1);
  }

  void _enqueueMerge(MergePair pair) {
    _pendingMerges.add(pair);
  }

  FruitLevel _randomLevel() {
    final spawnLevels = FruitLevel.values.take(5).toList();
    return spawnLevels[_rng.nextInt(spawnLevels.length)];
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_gameOver) return;
    if (_dropCooldown > 0) return;

    final worldPos = screenToWorld(event.canvasPosition);
    final clampedX = worldPos.x.clamp(
      containerLeft + _nextLevel.radius + 0.05,
      containerRight - _nextLevel.radius - 0.05,
    );

    final fruit = Fruit(
      level: _nextLevel,
      spawnPosition: Vector2(clampedX, dropLineY),
    );
    world.add(fruit);

    _dropIndicator.updateX(clampedX);
    _nextLevel = _randomLevel();
    _nextFruitText.text = 'Next: ${_getFruitName(_nextLevel)}';
    _nextFruitText.textRenderer = TextPaint(
      style: TextStyle(color: _nextLevel.color, fontSize: 14),
    );
    _dropCooldown = 0.5;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_dropCooldown > 0) {
      _dropCooldown -= dt;
    }

    _processMerges();

    if (!_gameOver) {
      _checkGameOver(dt);
    }
  }

  void _processMerges() {
    if (_pendingMerges.isEmpty) return;

    final merges = List<MergePair>.from(_pendingMerges);
    _pendingMerges.clear();

    for (final pair in merges) {
      final posA = pair.a.body.position;
      final posB = pair.b.body.position;
      final midPoint = (posA + posB) / 2;

      final nextLevel = pair.a.level.next;

      pair.a.removeFromParent();
      pair.b.removeFromParent();

      if (nextLevel != null) {
        final newFruit = Fruit(level: nextLevel, spawnPosition: midPoint.clone());
        world.add(newFruit);
        score += nextLevel.score;
      } else {
        score += pair.a.level.score;
      }

      _scoreText.text = 'Score: $score';
    }
  }

  void _checkGameOver(double dt) {
    final fruits = world.children.whereType<Fruit>();
    bool anyOverLine = false;

    for (final fruit in fruits) {
      if (fruit.pendingMerge) continue;
      final pos = fruit.body.position;
      final vel = fruit.body.linearVelocity;
      if (pos.y < gameOverLineY && vel.length < 0.5) {
        anyOverLine = true;
        break;
      }
    }

    if (anyOverLine) {
      _gameOverTimer += dt;
      if (_gameOverTimer >= 2.0) {
        _gameOver = true;
        overlays.add('GameOver');
      }
    } else {
      _gameOverTimer = 0;
    }
  }

  void restart() {
    final fruits = world.children.whereType<Fruit>().toList();
    for (final f in fruits) {
      f.removeFromParent();
    }
    _pendingMerges.clear();
    score = 0;
    _scoreText.text = 'Score: 0';
    _gameOver = false;
    _gameOverTimer = 0;
    _dropCooldown = 0;
    _nextLevel = _randomLevel();
    overlays.remove('GameOver');
  }
}
