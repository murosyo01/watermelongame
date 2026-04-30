import 'package:flutter/material.dart';

enum FruitLevel {
  cherry(radius: 0.20, color: Color(0xFFE74C3C), score: 1),
  strawberry(radius: 0.27, color: Color(0xFFFF6B9D), score: 3),
  grape(radius: 0.36, color: Color(0xFF9B59B6), score: 6),
  dekopon(radius: 0.46, color: Color(0xFFE67E22), score: 10),
  persimmon(radius: 0.55, color: Color(0xFFE74C3C), score: 15),
  apple(radius: 0.65, color: Color(0xFFE74C3C), score: 21),
  pear(radius: 0.75, color: Color(0xFFF1C40F), score: 28),
  peach(radius: 0.88, color: Color(0xFFFFB6C1), score: 36),
  pineapple(radius: 1.00, color: Color(0xFFF39C12), score: 45),
  melon(radius: 1.10, color: Color(0xFF2ECC71), score: 55),
  watermelon(radius: 1.20, color: Color(0xFF27AE60), score: 100);

  const FruitLevel({
    required this.radius,
    required this.color,
    required this.score,
  });

  final double radius;
  final Color color;
  final int score;

  FruitLevel? get next =>
      index < FruitLevel.values.length - 1 ? FruitLevel.values[index + 1] : null;
}
