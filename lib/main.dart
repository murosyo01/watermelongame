import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/watermelon_game.dart';

void main() {
  runApp(const WatermelonApp());
}

class WatermelonApp extends StatelessWidget {
  const WatermelonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = WatermelonGame();
    return MaterialApp(
      title: 'Suika Game',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget<WatermelonGame>(
          game: game,
          overlayBuilderMap: {
            'GameOver': (context, game) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'GAME OVER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Score: ${game.score}',
                          style: const TextStyle(color: Colors.white70, fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: game.restart,
                          child: const Text('Restart'),
                        ),
                      ],
                    ),
                  ),
                ),
          },
        ),
      ),
    );
  }
}
