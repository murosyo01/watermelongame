import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermelongame/game/watermelon_game.dart';

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
  });
}
