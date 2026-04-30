import 'package:flutter/material.dart';

enum FruitLevel {
  cherry(radius: 0.20, color: Color(0xFFFF3FA0), score: 1),      // ホットピンク
  strawberry(radius: 0.27, color: Color(0xFFFF6B9D), score: 3),  // 変更なし
  grape(radius: 0.36, color: Color(0xFF9B59B6), score: 6),       // 変更なし
  dekopon(radius: 0.46, color: Color(0xFFE67E22), score: 10),    // 変更なし
  persimmon(radius: 0.55, color: Color(0xFFF05C00), score: 15),  // 深オレンジ
  apple(radius: 0.65, color: Color(0xFFE03030), score: 21),      // 純赤
  pear(radius: 0.75, color: Color(0xFFF1C40F), score: 28),       // 変更なし
  peach(radius: 0.88, color: Color(0xFFFFB6C1), score: 36),      // 変更なし
  pineapple(radius: 1.00, color: Color(0xFFF39C12), score: 45),  // 変更なし
  melon(radius: 1.10, color: Color(0xFF5DD65D), score: 55),      // ライムグリーン
  watermelon(radius: 1.20, color: Color(0xFF1A5C30), score: 100);// フォレストグリーン

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