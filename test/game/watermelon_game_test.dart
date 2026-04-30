import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermelongame/components/fruit.dart';
import 'package:watermelongame/game/watermelon_game.dart';
import 'package:watermelongame/models/fruit_level.dart';

void main() {
  group('WatermelonGame', () {
    testWithGame<WatermelonGame>(
      'score initializes to zero on load',
      WatermelonGame.new,
      (game) async {
        expect(game.score, 0);
      },
    );

    testWithGame<WatermelonGame>(
      'restart resets score to zero',
      WatermelonGame.new,
      (game) async {
        game.score = 99;
        game.restart();
        expect(game.score, 0);
      },
    );

    testWithGame<WatermelonGame>(
      'restart can be called multiple times without error',
      WatermelonGame.new,
      (game) async {
        game.restart();
        game.score = 50;
        game.restart();
        expect(game.score, 0);
      },
    );

    testWithGame<WatermelonGame>(
      'score does not change without a merge',
      WatermelonGame.new,
      (game) async {
        // Advance several frames with no fruit in the world
        game.update(0.016);
        game.update(0.016);
        expect(game.score, 0);
      },
    );

    testWithGame<WatermelonGame>(
      'does not crash when merge creates unmounted fruit on same update frame',
      WatermelonGame.new,
      (game) async {
        // Two cherries placed slightly overlapping so physics triggers contact immediately
        final fruitA = Fruit(
          level: FruitLevel.cherry,
          spawnPosition: Vector2(-0.19, 0.0),
        );
        final fruitB = Fruit(
          level: FruitLevel.cherry,
          spawnPosition: Vector2(0.19, 0.0),
        );
        game.world.add(fruitA);
        game.world.add(fruitB);
        game.update(0); // mount both fruits so their bodies are created
        // Physics step fires contact → merge queued → _processMerges adds new
        // unmounted fruit to _fruits → _checkGameOver must not crash on it
        game.update(0.016);
      },
    );
  });
}
