import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/watermelon_game.dart';
import '../models/fruit_level.dart';

class EvolutionChainBar extends StatefulWidget {
  final WatermelonGame game;
  const EvolutionChainBar({required this.game, super.key});

  @override
  State<EvolutionChainBar> createState() => _EvolutionChainBarState();
}

class _EvolutionChainBarState extends State<EvolutionChainBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;
  late final Animation<double> _flashOpacity;
  bool _flashTriggered = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 200,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 600,
      ),
    ]).animate(_flashController);
    widget.game.highestUnlockedNotifier.addListener(_onHighestChanged);
  }

  void _onHighestChanged() {
    if (!mounted) return;
    final highest = widget.game.highestUnlockedNotifier.value;
    if (highest == 0) {
      setState(() => _flashTriggered = false);
      return;
    }
    if (highest == FruitLevel.values.length - 1 && !_flashTriggered) {
      setState(() => _flashTriggered = true);
      _flashController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.game.highestUnlockedNotifier.removeListener(_onHighestChanged);
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.game.highestUnlockedNotifier,
      builder: (context, highestUnlocked, _) {
        return AnimatedBuilder(
          animation: _flashOpacity,
          builder: (context, _) {
            final flashVal = _flashOpacity.value;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    color: flashVal > 0.01
                        ? Color.lerp(
                            const Color(0xFF14141C),
                            const Color(0xFFF1C40F).withValues(alpha: 0.35),
                            flashVal,
                          )
                        : const Color(0xFF14141C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: flashVal > 0.01 ? 0.3 : 0.08),
                    ),
                  ),
                  child: Row(
                    children: FruitLevel.values.asMap().entries.map((e) {
                      final index = e.key;
                      final level = e.value;
                      final state = index <= highestUnlocked
                          ? _CellState.unlocked
                          : index == highestUnlocked + 1
                              ? _CellState.next
                              : _CellState.locked;
                      return Expanded(
                        child: _FruitCell(level: level, state: state),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

enum _CellState { unlocked, next, locked }

class _FruitCell extends StatelessWidget {
  final FruitLevel level;
  final _CellState state;
  const _FruitCell({required this.level, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: 14,
          child: CustomPaint(
            painter: _CellPainter(level: level, state: state),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${level.index + 1}',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 7,
            color: Colors.white
                .withValues(alpha: state == _CellState.unlocked ? 0.9 : 0.4),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CellPainter extends CustomPainter {
  final FruitLevel level;
  final _CellState state;
  const _CellPainter({required this.level, required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 0.5;
    final center = Offset(size.width / 2, size.height / 2);

    switch (state) {
      case _CellState.unlocked:
        // グロー効果
        canvas.drawCircle(
          center,
          r + 2,
          Paint()
            ..color = level.color.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
        canvas.drawCircle(center, r, Paint()..color = level.color);
      case _CellState.next:
        canvas.drawCircle(
          center, r,
          Paint()..color = level.color.withValues(alpha: 0.25),
        );
        canvas.drawCircle(
          center, r,
          Paint()
            ..color = level.color.withValues(alpha: 0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      case _CellState.locked:
        canvas.drawCircle(
          center, r,
          Paint()..color = level.color.withValues(alpha: 0.20),
        );
    }
  }

  @override
  bool shouldRepaint(_CellPainter old) =>
      old.level != level || old.state != state;
}
