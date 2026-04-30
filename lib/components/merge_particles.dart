import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MergeParticles extends Component {
  final Vector2 position;
  final Color color;
  final List<_Particle> _particles = [];
  static final _rng = Random();

  MergeParticles({required this.position, required this.color}) {
    for (int i = 0; i < 10; i++) {
      final angle = (pi * 2 / 10) * i + _rng.nextDouble() * 0.5;
      final speed = 1.5 + _rng.nextDouble() * 2.5;
      _particles.add(_Particle(
        pos: position.clone(),
        vel: Vector2(cos(angle) * speed, sin(angle) * speed - 1.5),
        size: 0.04 + _rng.nextDouble() * 0.05,
      ));
    }
  }

  @override
  void update(double dt) {
    for (final p in _particles) {
      p.pos += p.vel * dt * 60;
      p.vel.y += 0.15;
      p.life -= dt * 2.5;
    }
    _particles.removeWhere((p) => p.life <= 0);
    if (_particles.isEmpty) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      canvas.drawCircle(
        p.pos.toOffset(),
        p.size * p.life,
        Paint()..color = color.withOpacity(p.life.clamp(0, 1)),
      );
    }
  }
}

class _Particle {
  Vector2 pos, vel;
  double size;
  double life = 1.0;
  _Particle({required this.pos, required this.vel, required this.size});
}
