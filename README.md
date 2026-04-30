# 🍉 Watermelon Game

Flutter × Flame で実装したスイカゲーム（落下 & マージパズル）です。

## ゲーム概要

画面上部からフルーツを落とし、同じ種類のフルーツ同士をぶつけて合体させるパズルゲームです。  
小さいフルーツを合体させて、最終的にスイカを目指してスコアを稼ぎましょう。

### フルーツの進化チェーン

| 段階 | フルーツ | スコア |
|------|----------|--------|
| 1 | さくらんぼ | 1 |
| 2 | いちご | 3 |
| 3 | ぶどう | 6 |
| 4 | デコポン | 10 |
| 5 | かき | 15 |
| 6 | りんご | 21 |
| 7 | なし | 28 |
| 8 | もも | 36 |
| 9 | パイナップル | 45 |
| 10 | メロン | 55 |
| 11 | **スイカ** | 100 |

同じフルーツ同士が接触すると合体し、次の段階のフルーツに進化します。スイカ同士が合体した場合は消滅してボーナスポイントが加算されます。

---

## 技術スタック

| 技術 | 役割 |
|------|------|
| **Flutter** | UI フレームワーク |
| **Flame** | 2D ゲームエンジン |
| **flame_forge2d** | 2D 物理演算（Box2D ラッパー） |
| **Dart** | 言語 |

---

## 実行手順

### 前提条件

- Flutter SDK（`sdk: ^3.11.5`）
- Android Emulator または実機、あるいはブラウザ（Chrome）

### セットアップ

```bash
# 依存パッケージのインストール
flutter pub get

# コードの静的解析
flutter analyze
```

### 起動

```bash
# デバイス/エミュレータで起動
flutter run

# ブラウザ（Chrome）で起動
flutter run -d chrome

# 接続デバイスを一覧表示してから選択
flutter devices
flutter run -d <device_id>
```

### ビルド

```bash
flutter build apk    # Android APK
flutter build web    # Web ビルド
```

### テスト

```bash
flutter test                               # 全テスト
flutter test test/game/                   # ゲームロジックのテスト
flutter test test/models/                 # モデルのテスト
```

---

## こだわりのポイント

### 1. 物理演算による自然な落下と積み上がり

`flame_forge2d`（Box2D）を使ったリジッドボディ物理シミュレーションにより、フルーツが重力に従って落ちて積み重なります。重力は `(0, 30)` に設定し、サクサクした落下感を演出しています。

### 2. マージ処理の安全な設計

Box2D の接触コールバック（`ContactListener.beginContact`）は物理ステップの内側で発火するため、そこでボディを削除・生成するとクラッシュします。  
本実装では `pendingMerge` フラグでマークするだけにとどめ、実際の削除・生成は `game.update()` の物理ステップ後に行う **キューイングパターン**を採用しています。

```
beginContact → MergePair をキューに積む
              ↓
update() → super.update() (物理ステップ) → _processMerges() (安全に削除・生成)
```

### 3. ゲームオーバー判定に 2 秒のグレース期間

フルーツがゲームオーバーラインを超えた瞬間ではなく、**速度がほぼゼロで 2 秒間ラインを超え続けた場合**にゲームオーバーとします。落下中や合体後の一時的なはみ出しで誤判定しないようにしています。

### 4. 座標系をワールド単位で統一

ピクセル座標ではなく物理ワールド単位（幅 4 × 高さ 15）で全コンポーネントを設計し、カメラのズーム計算で画面サイズに追従させています。これにより異なる画面解像度でも一貫した挙動になります。

### 5. FruitLevel enum による型安全な進化チェーン

フルーツの種類・サイズ・色・スコアを `FruitLevel` enum に集約し、`next` ゲッターで進化先を取得します。ハードコーディングなしに 11 段階のチェーンを表現しています。

```dart
FruitLevel? get next =>
    index < FruitLevel.values.length - 1 ? FruitLevel.values[index + 1] : null;
```

---

## プロジェクト構成

```
lib/
├── main.dart                        # エントリーポイント・GameOver オーバーレイ
├── game/
│   └── watermelon_game.dart         # コアゲームループ・タップ処理・スコア管理
├── components/
│   ├── fruit.dart                   # 動的 Box2D 円ボディ
│   ├── walls.dart                   # 静的壁・床ボディ
│   └── drop_indicator.dart          # ドロップ位置インジケーター
├── models/
│   └── fruit_level.dart             # フルーツ 11 段階の定義
└── systems/
    └── merge_contact_listener.dart  # 接触検知・マージキューイング
```
