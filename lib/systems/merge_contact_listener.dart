import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:forge2d/forge2d.dart';
import '../components/fruit.dart';

typedef MergePair = ({Fruit a, Fruit b});

class MergeContactListener extends ContactListener {
  MergeContactListener(this._onMerge);

  final void Function(MergePair) _onMerge;

  @override
  void beginContact(Contact contact) {
    final bodyA = contact.fixtureA.body;
    final bodyB = contact.fixtureB.body;

    final a = bodyA.userData;
    final b = bodyB.userData;

    if (a is! Fruit || b is! Fruit) return;
    if (a.level != b.level) return;
    if (a.pendingMerge || b.pendingMerge) return;

    a.pendingMerge = true;
    b.pendingMerge = true;
    _onMerge((a: a, b: b));
  }
}
