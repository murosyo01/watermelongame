import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game/watermelon_game.dart';
import 'widgets/hud_overlay.dart';

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
        backgroundColor: const Color(0xFF0A0A0F),
        body: GameWidget<WatermelonGame>(
          game: game,
          initialActiveOverlays: const ['HUD'],
          overlayBuilderMap: {
            'HUD': (context, game) => HudOverlay(game: game),
            'GameOver': (context, game) => Center(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xED0A0A14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 48),
                    const BoxShadow(color: Color(0x26E74C3C), blurRadius: 40, spreadRadius: 4),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GAME OVER',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: const [Shadow(color: Color(0x99E74C3C), blurRadius: 30)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: ${game.score}',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFFF1C40F),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        shadows: const [Shadow(color: Color(0x88F1C40F), blurRadius: 16)],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RestartButton(onPressed: game.restart),
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
