import 'package:baa_game/baa_game.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sheep jump test', (WidgetTester tester) async {
    // Create the game instance
    final baaGame = BaaGame();

    // Attach the game to the widget tester
    await tester.pumpWidget(GameWidget(game: baaGame));

    // Wait for the game to load
    await tester.pump();

    // Ensure the game has loaded the sheep
    expect(baaGame.children.whereType<Sheep>().isNotEmpty, true);

    // Simulate a tap on the sheep
    final sheep = baaGame.children.whereType<Sheep>().first;
    final positionBeforeJump = sheep.position.y;

    await tester.tapAt(Offset(sheep.position.x + sheep.size.x / 2, sheep.position.y + sheep.size.y / 2));
    await tester.pump();

    // Check if the sheep's position changes due to the jump
    expect(sheep.position.y < positionBeforeJump, true);
  });
}
