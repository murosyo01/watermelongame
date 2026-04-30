# Watermelon Game 改善案

作成日: 2026-04-30

---

## 1. バグ修正（優先度: 高）

### `restart()` で `_nextFruitText` が更新されない

**ファイル:** `lib/game/watermelon_game.dart:201-214`

`restart()` 内で `_nextLevel` を更新しているが、`_nextFruitText` のテキストと色が古いままになる。

**現状のコード:**
```dart
void restart() {
  // ...
  _nextLevel = _randomLevel();
  overlays.remove('GameOver');
}
```

**修正後:**
```dart
void restart() {
  // ...
  _nextLevel = _randomLevel();
  _nextFruitText.text = 'Next: ${_getFruitName(_nextLevel)}';
  _nextFruitText.textRenderer = TextPaint(
    style: TextStyle(color: _nextLevel.color, fontSize: 14),
  );
  overlays.remove('GameOver');
}
```

---

## 2. パフォーマンス改善（優先度: 高）

### `Fruit.render` で毎フレーム `Paint` オブジェクトを生成している

**ファイル:** `lib/components/fruit.dart:36-43`

`render()` は毎フレーム呼ばれるため、`Paint` の生成コストが積み重なる。フィールドにキャッシュすべき。

**現状のコード:**
```dart
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
```

**修正後:**
```dart
late final Paint _fillPaint = Paint()..color = level.color;
late final Paint _borderPaint = Paint()
  ..color = Colors.black26
  ..style = PaintingStyle.stroke
  ..strokeWidth = 0.05;

@override
void render(Canvas canvas) {
  canvas.drawCircle(Offset.zero, level.radius, _fillPaint);
  canvas.drawCircle(Offset.zero, level.radius, _borderPaint);
}
```

同様に `lib/components/drop_indicator.dart:19-22` の `DropIndicator.render` も同じ問題あり。

### `_checkGameOver` が毎フレーム `whereType<Fruit>` を実行している

**ファイル:** `lib/game/watermelon_game.dart:177`

毎フレーム全 children を線形探索している。フルーツ追加・削除時に `Set<Fruit>` を管理すれば O(1) に改善できる。

**修正方針:**
```dart
final Set<Fruit> _fruits = {};

// world.add(fruit) の後
_fruits.add(fruit);

// removeFromParent の前
_fruits.remove(pair.a);
_fruits.remove(pair.b);

// _checkGameOver では _fruits を直接使う
```

---

## 3. UX 改善（優先度: 中）

### ドラッグ操作でリアルタイムにドロップ位置を動かせるようにする

**ファイル:** `lib/game/watermelon_game.dart:108-131`

現状は `onTapDown` のみ対応。`DragCallbacks` を追加し `onDragUpdate` でインジケーターを更新、`onDragEnd` でドロップするとより直感的な操作になる。

**修正方針:**
```dart
class WatermelonGame extends Forge2DGame with TapCallbacks, DragCallbacks {
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_gameOver || _dropCooldown > 0) return;
    final worldPos = screenToWorld(event.canvasPosition);
    final clampedX = worldPos.x.clamp(
      containerLeft + _nextLevel.radius + 0.05,
      containerRight - _nextLevel.radius - 0.05,
    );
    _dropIndicator.updateX(clampedX);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    // ドラッグ終了位置でドロップ
    _dropFruit(_dropIndicator.worldX);
  }
}
```

### ゲームオーバーラインを画面に表示する

**ファイル:** `lib/game/watermelon_game.dart:27`

`gameOverLineY = -5.5` の判定ラインが視覚的に存在しない。赤い点線で警告を表示するとプレイヤーが理解しやすい。

**修正方針:** `walls.dart` や専用コンポーネントで `gameOverLineY` の水平線を赤破線で描画する。

### 次のフルーツを円形プレビューで表示する

**ファイル:** `lib/game/watermelon_game.dart:84-91`

現状は `Next: Cherry` のような文字のみ。画面右上に実際の円を小さく描画するとゲームらしくなる。

**修正方針:** `camera.viewport` に `NextFruitPreview` コンポーネントを追加し、`CircleComponent` ベースで描画する。

---

## 4. コード品質（優先度: 低）

### `onLoad` が肥大化している

**ファイル:** `lib/game/watermelon_game.dart:44-92`

カメラ設定・壁生成・UI追加が一か所に混在している。分割すると可読性が上がる。

```dart
@override
Future<void> onLoad() async {
  await super.onLoad();
  world.physicsWorld.setContactListener(_contactListener);
  _setupCamera();
  await _setupWorld();
  _setupUI();
}

void _setupCamera() { ... }
Future<void> _setupWorld() async { ... }
void _setupUI() { ... }
```

### `Walls` の `HasGameRef` + キャスト依存を解消する

**ファイル:** `lib/components/walls.dart:21`

`gameRef as Forge2DGame` のキャストが脆い。壁生成ロジックを `WatermelonGame.onLoad` 内に移動するか、`Walls` を `BodyComponent` ベースにすれば余分な依存が消える。

---

## 優先度まとめ

| # | 内容 | 種別 | 難易度 |
|---|------|------|--------|
| 1 | `restart()` の `_nextFruitText` 更新漏れ | バグ修正 | 小 |
| 2 | `Paint` オブジェクトのキャッシュ | 性能改善 | 小 |
| 3 | フルーツリストの管理最適化 | 性能改善 | 中 |
| 4 | ドラッグ操作対応 | UX改善 | 中 |
| 5 | ゲームオーバーライン表示 | UX改善 | 小 |
| 6 | 次フルーツの円形プレビュー | UX改善 | 中 |
| 7 | `onLoad` の分割 | 可読性 | 小 |
| 8 | `Walls` の依存整理 | 可読性 | 中 |
