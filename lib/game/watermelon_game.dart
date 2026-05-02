import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/drop_indicator.dart';
import '../components/fruit.dart';
import '../components/game_over_line.dart';
import '../components/merge_particles.dart';
import '../components/walls.dart';
import '../models/fruit_level.dart';
import '../systems/merge_contact_listener.dart';

class ScoreDelta {
  final int delta;
  final int seq;
  ScoreDelta(this.delta, this.seq);
}

class WatermelonGame extends Forge2DGame with TapCallbacks, DragCallbacks {
  late final MergeContactListener _contactListener;

  WatermelonGame() : super(gravity: Vector2(0, 30)) {
    _contactListener = MergeContactListener(_enqueueMerge);
  }

  static const double containerLeft = -2.0;
  static const double containerRight = 2.0;
  static const double containerBottom = 4.0;
  static const double containerTop = -3.0;
  static const double gameOverLineY = -1.5;
  static const double dropLineY = -2.0;

  late FruitLevel _nextLevel;
  final List<MergePair> _pendingMerges = [];
  double _dropCooldown = 0.0;
  bool _gameOver = false;
  int score = 0;

  int _bestScore = 0;
  bool _isNewBest = false;
  int _deltaSeq = 0;

  final Set<Fruit> _fruits = {};
  late DropIndicator _dropIndicator;

  final scoreNotifier = ValueNotifier<int>(0);
  final bestScoreNotifier = ValueNotifier<int>(0);
  final scoreDeltaNotifier = ValueNotifier<ScoreDelta>(ScoreDelta(0, -1));
  final highestUnlockedNotifier = ValueNotifier<int>(0);
  late final ValueNotifier<FruitLevel> nextLevelNotifier;

  bool get isNewBest => _isNewBest;

  final _rng = Random();
  final Vector2 _dragCanvasPos = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world.physicsWorld.setContactListener(_contactListener);
    _setupCamera();
    await _setupWorld();
    _setupUI();
    await _loadBestScore();
  }

  void _setupCamera() {
    final gameWidth = containerRight - containerLeft;
    camera.viewfinder.zoom = size.x / gameWidth;
    camera.viewfinder.position =
        Vector2(0, (containerTop + containerBottom) / 2);
  }

  Future<void> _setupWorld() async {
    await world.add(Walls(
      leftX: containerLeft,
      rightX: containerRight,
      topY: containerTop,
      bottomY: containerBottom,
    ));

    world.add(GameOverLine(
      lineY: gameOverLineY,
      leftX: containerLeft,
      rightX: containerRight,
    ));
    _nextLevel = _randomLevel();
    _dropIndicator = DropIndicator(
      worldX: 0,
      topY: dropLineY,
      initialLevel: _nextLevel,
      containerLeft: containerLeft,
      containerRight: containerRight,
    );
    await world.add(_dropIndicator);
  }

  void _setupUI() {
    nextLevelNotifier = ValueNotifier(_nextLevel);
  }

  Future<void> _loadBestScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _bestScore = prefs.getInt('best_score') ?? 0;
      bestScoreNotifier.value = _bestScore;
    } catch (_) {
      // テスト環境など初期化前の場合はデフォルト値 0 を使用
    }
  }

  void _enqueueMerge(MergePair pair) {
    _pendingMerges.add(pair);
  }

  FruitLevel _randomLevel() {
    final spawnLevels = FruitLevel.values.take(5).toList();
    return spawnLevels[_rng.nextInt(spawnLevels.length)];
  }

  void _dropFruit(Vector2 canvasPosition) {
    final worldPos = screenToWorld(canvasPosition);
    final clampedX = worldPos.x.clamp(
      containerLeft + _nextLevel.radius + 0.05,
      containerRight - _nextLevel.radius - 0.05,
    );
    final fruit = Fruit(level: _nextLevel, spawnPosition: Vector2(clampedX, dropLineY));
    world.add(fruit);
    _fruits.add(fruit);
    _dropIndicator.updateX(clampedX);
    _nextLevel = _randomLevel();
    nextLevelNotifier.value = _nextLevel;
    _dropIndicator.updateLevel(_nextLevel);
    _dropCooldown = 0.5;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_gameOver || _dropCooldown > 0) return;
    _dropFruit(event.canvasPosition);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragCanvasPos.setFrom(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _dragCanvasPos.add(event.localDelta);
    if (_gameOver || _dropCooldown > 0) return;
    final worldPos = screenToWorld(_dragCanvasPos);
    final clampedX = worldPos.x.clamp(
      containerLeft + _nextLevel.radius + 0.05,
      containerRight - _nextLevel.radius - 0.05,
    );
    _dropIndicator.updateX(clampedX);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_gameOver || _dropCooldown > 0) return;
    final fruit = Fruit(level: _nextLevel, spawnPosition: Vector2(_dropIndicator.worldX, dropLineY));
    world.add(fruit);
    _fruits.add(fruit);
    _nextLevel = _randomLevel();
    nextLevelNotifier.value = _nextLevel;
    _dropIndicator.updateLevel(_nextLevel);
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
      _checkGameOver();
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

      _fruits.remove(pair.a);
      _fruits.remove(pair.b);
      pair.a.removeFromParent();
      pair.b.removeFromParent();

      if (nextLevel != null) {
        final newFruit = Fruit(level: nextLevel, spawnPosition: midPoint.clone());
        newFruit.hasEnteredField =
            pair.a.hasEnteredField || pair.b.hasEnteredField;
        world.add(newFruit);
        _fruits.add(newFruit);
        world.add(MergeParticles(position: midPoint.clone(), color: pair.a.level.color));
        score += nextLevel.score;
        scoreDeltaNotifier.value = ScoreDelta(nextLevel.score, ++_deltaSeq);
        highestUnlockedNotifier.value = max(highestUnlockedNotifier.value, nextLevel.index);
      } else {
        score += pair.a.level.score;
        scoreDeltaNotifier.value = ScoreDelta(pair.a.level.score, ++_deltaSeq);
      }

      scoreNotifier.value = score;
    }
  }

  static const double _gameOverGrace = 0.5;

  void _checkGameOver() {
    for (final fruit in _fruits) {
      if (fruit.pendingMerge) continue;
      if (!fruit.isMounted) continue;
      final topY = fruit.body.position.y - fruit.level.radius;
      if (!fruit.hasEnteredField && topY > gameOverLineY) {
        fruit.hasEnteredField = true;
      }
      final armed = fruit.hasEnteredField || fruit.timeSinceSpawn > _gameOverGrace;
      if (armed && topY < gameOverLineY) {
        _triggerGameOver();
        break;
      }
    }
  }

  void _triggerGameOver() {
    _gameOver = true;
    _isNewBest = score > _bestScore;
    if (_isNewBest) {
      _bestScore = score;
      bestScoreNotifier.value = _bestScore;
      SharedPreferences.getInstance()
          .then((prefs) => prefs.setInt('best_score', _bestScore))
          .catchError((_) => false);
    }
    overlays.add('GameOver');
  }

  void restart() {
    for (final f in _fruits) {
      f.removeFromParent();
    }
    _fruits.clear();
    _pendingMerges.clear();
    score = 0;
    scoreNotifier.value = 0;
    _gameOver = false;
    _isNewBest = false;
    _dropCooldown = 0;
    _nextLevel = _randomLevel();
    nextLevelNotifier.value = _nextLevel;
    _dropIndicator.updateLevel(_nextLevel);
    highestUnlockedNotifier.value = 0;
    overlays.remove('GameOver');
  }
}
