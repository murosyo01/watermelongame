import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game/watermelon_game.dart';
import 'models/fruit_level.dart';
import 'widgets/evolution_chain_bar.dart';
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
        body: Column(
          children: [
            Expanded(
              child: GameWidget<WatermelonGame>(
                game: game,
                initialActiveOverlays: const ['HUD'],
                overlayBuilderMap: {
                  'HUD': (context, game) => HudOverlay(game: game),
                  'GameOver': (context, game) => _GameOverOverlay(game: game),
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: EvolutionChainBar(game: game),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final WatermelonGame game;
  const _GameOverOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    final highestLevel = FruitLevel.values[game.highestUnlockedNotifier.value];
    final isNewBest = game.isNewBest;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xED0A0A14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isNewBest
                ? const Color(0xFFF1C40F).withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: isNewBest ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 48),
            if (isNewBest)
              const BoxShadow(
                color: Color(0x33F1C40F),
                blurRadius: 40,
                spreadRadius: 4,
              )
            else
              const BoxShadow(
                color: Color(0x26E74C3C),
                blurRadius: 40,
                spreadRadius: 4,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // NEW BEST バナー
            if (isNewBest) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFFF1C40F), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'NEW BEST!',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFFF1C40F),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // タイトル
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
            const SizedBox(height: 12),
            // 到達フルーツ
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: highestLevel.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: highestLevel.color.withOpacity(0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  highestLevel.name[0].toUpperCase() +
                      highestLevel.name.substring(1),
                  style: GoogleFonts.nunito(
                    color: highestLevel.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // スコア
            Text(
              _fmt(game.score),
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFFF1C40F),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                shadows: const [Shadow(color: Color(0x88F1C40F), blurRadius: 16)],
              ),
            ),
            const SizedBox(height: 4),
            // BEST スコア
            ValueListenableBuilder<int>(
              valueListenable: game.bestScoreNotifier,
              builder: (_, best, _) => RichText(
                text: TextSpan(
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  children: [
                    const TextSpan(text: 'BEST '),
                    TextSpan(
                      text: _fmt(best),
                      style: const TextStyle(color: Color(0xFFF1C40F)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            RestartButton(onPressed: game.restart),
          ],
        ),
      ),
    );
  }
}

String _fmt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
