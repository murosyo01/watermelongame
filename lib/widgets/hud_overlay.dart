import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/watermelon_game.dart';
import '../models/fruit_level.dart';

class HudOverlay extends StatelessWidget {
  final WatermelonGame game;
  const HudOverlay({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 48, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 50),
          Expanded(child: _ScoreDisplay(game: game)),
          NextFruitPanel(game: game),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// スコア表示（+Δアニメ付き）
// ──────────────────────────────────────────

class _ScoreDisplay extends StatefulWidget {
  final WatermelonGame game;
  const _ScoreDisplay({required this.game});

  @override
  State<_ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<_ScoreDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _opacityAnim;
  int _lastDelta = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.4),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 150 / 700),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 350 / 700),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 200 / 700),
    ]).animate(_ctrl);
    widget.game.scoreDeltaNotifier.addListener(_onDelta);
  }

  void _onDelta() {
    if (!mounted) return;
    final d = widget.game.scoreDeltaNotifier.value;
    if (d.seq >= 0 && d.delta > 0) {
      setState(() => _lastDelta = d.delta);
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.game.scoreDeltaNotifier.removeListener(_onDelta);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: widget.game.scoreNotifier,
              builder: (_, score, _) => Text(
                _fmt(score),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            // +Δ 浮遊アニメ
            Positioned(
              right: -4,
              top: -10,
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _opacityAnim,
                  child: Text(
                    '+$_lastDelta',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7BE2A6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ValueListenableBuilder<int>(
          valueListenable: widget.game.bestScoreNotifier,
          builder: (_, best, _) => RichText(
            text: TextSpan(
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.5),
              ),
              children: [
                const TextSpan(text: 'BEST '),
                TextSpan(
                  text: _fmt(best),
                  style: const TextStyle(
                    color: Color(0xFFF1C40F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// Next フルーツパネル（右側）
// ──────────────────────────────────────────

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
                  boxShadow: [
                    BoxShadow(
                      color: level.color.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
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

// ──────────────────────────────────────────
// HUD パネル（ガラス形態）
// ──────────────────────────────────────────

class HudPanel extends StatelessWidget {
  final String label;
  final Widget child;
  const HudPanel({required this.label, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
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
                  color: Colors.white.withOpacity(0.45),
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 2),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// リスタートボタン
// ──────────────────────────────────────────

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
          'もう一度',
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

// ──────────────────────────────────────────
// ユーティリティ
// ──────────────────────────────────────────

String _fmt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
