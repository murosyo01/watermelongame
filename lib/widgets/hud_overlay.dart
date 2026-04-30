import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/watermelon_game.dart';
import '../models/fruit_level.dart';

class HudOverlay extends StatelessWidget {
  final WatermelonGame game;
  const HudOverlay({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 48, 12, 0),
        child: Row(
          children: [
            HudPanel(
              label: 'SCORE',
              child: ValueListenableBuilder<int>(
                valueListenable: game.scoreNotifier,
                builder: (context, score, _) => Text(
                  '$score',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF1C40F),
                    shadows: const [Shadow(color: Color(0x88F1C40F), blurRadius: 16)],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            NextFruitPanel(game: game),
          ],
        ),
      ),
    );
  }
}

class HudPanel extends StatelessWidget {
  final String label;
  final Widget child;
  const HudPanel({required this.label, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E3A), Color(0xFF2A1A3E)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}

class NextFruitPanel extends StatelessWidget {
  final WatermelonGame game;
  const NextFruitPanel({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FruitLevel>(
      valueListenable: game.nextLevelNotifier,
      builder: (context, level, _) {
        return HudPanel(
          label: 'NEXT',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: level.color,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: level.color.withOpacity(0.5), blurRadius: 8)],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                level.name[0].toUpperCase() + level.name.substring(1),
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: level.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RestartButton extends StatelessWidget {
  final VoidCallback onPressed;
  const RestartButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF1A8F4A)],
        ),
        borderRadius: BorderRadius.circular(9999),
        boxShadow: const [BoxShadow(color: Color(0x882ECC71), blurRadius: 24)],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          shape: const StadiumBorder(),
        ),
        onPressed: onPressed,
        child: Text(
          '▶ Restart',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
