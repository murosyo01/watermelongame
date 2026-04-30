import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermelongame/models/fruit_level.dart';

void main() {
  group('FruitLevel', () {
    test('has exactly 11 tiers', () {
      expect(FruitLevel.values.length, 11);
    });

    test('tiers are in the correct order', () {
      final names = FruitLevel.values.map((l) => l.name).toList();
      expect(names, [
        'cherry',
        'strawberry',
        'grape',
        'dekopon',
        'persimmon',
        'apple',
        'pear',
        'peach',
        'pineapple',
        'melon',
        'watermelon',
      ]);
    });

    group('next getter', () {
      test('cherry.next is strawberry', () {
        expect(FruitLevel.cherry.next, FruitLevel.strawberry);
      });

      test('melon.next is watermelon', () {
        expect(FruitLevel.melon.next, FruitLevel.watermelon);
      });

      test('watermelon.next is null (no further merge)', () {
        expect(FruitLevel.watermelon.next, isNull);
      });

      test('next chain traverses all 11 tiers', () {
        FruitLevel? current = FruitLevel.cherry;
        int count = 0;
        while (current != null) {
          count++;
          current = current.next;
        }
        expect(count, FruitLevel.values.length);
      });

      test('next returns consecutive tier for every non-final level', () {
        final levels = FruitLevel.values;
        for (int i = 0; i < levels.length - 1; i++) {
          expect(
            levels[i].next,
            levels[i + 1],
            reason: '${levels[i].name}.next should be ${levels[i + 1].name}',
          );
        }
      });
    });

    group('radius', () {
      test('cherry has radius 0.20', () {
        expect(FruitLevel.cherry.radius, 0.20);
      });

      test('watermelon has radius 1.20', () {
        expect(FruitLevel.watermelon.radius, 1.20);
      });

      test('all radii are positive', () {
        for (final level in FruitLevel.values) {
          expect(
            level.radius,
            greaterThan(0),
            reason: '${level.name}.radius must be positive',
          );
        }
      });

      test('radii increase monotonically through the merge chain', () {
        final levels = FruitLevel.values;
        for (int i = 1; i < levels.length; i++) {
          expect(
            levels[i].radius,
            greaterThan(levels[i - 1].radius),
            reason:
                '${levels[i].name} radius should exceed ${levels[i - 1].name}',
          );
        }
      });
    });

    group('score', () {
      test('cherry has score 1', () {
        expect(FruitLevel.cherry.score, 1);
      });

      test('watermelon has score 100', () {
        expect(FruitLevel.watermelon.score, 100);
      });

      test('all scores are positive', () {
        for (final level in FruitLevel.values) {
          expect(
            level.score,
            greaterThan(0),
            reason: '${level.name}.score must be positive',
          );
        }
      });

      test('scores increase monotonically through the merge chain', () {
        final levels = FruitLevel.values;
        for (int i = 1; i < levels.length; i++) {
          expect(
            levels[i].score,
            greaterThan(levels[i - 1].score),
            reason:
                '${levels[i].name} score should exceed ${levels[i - 1].name}',
          );
        }
      });
    });

    group('color', () {
      test('all tiers have a Color value', () {
        for (final level in FruitLevel.values) {
          expect(
            level.color,
            isA<Color>(),
            reason: '${level.name} must have a Color',
          );
        }
      });
    });
  });
}
