import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermelongame/main.dart';
import 'package:watermelongame/game/watermelon_game.dart';

void main() {
  testWidgets('GameWidget renders without crash', (WidgetTester tester) async {
    await tester.pumpWidget(const WatermelonApp());
    // find.byType cannot express GameWidget<WatermelonGame> as a Type literal,
    // so use a predicate to match the parameterized widget type.
    expect(
      find.byWidgetPredicate((w) => w is GameWidget<WatermelonGame>),
      findsOneWidget,
    );
  });
}
