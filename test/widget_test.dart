import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermelongame/main.dart';

void main() {
  testWidgets('GameWidget renders without crash', (WidgetTester tester) async {
    await tester.pumpWidget(const WatermelonApp());
    expect(find.byType(GameWidget), findsOneWidget);
  });
}
