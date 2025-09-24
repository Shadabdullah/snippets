import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:games/bugsquash/bug_sprite.dart';

class BugsquashGame extends FlameGame {
  @override
  Color backgroundColor() {
    return Colors.white;
  }

  @override
  FutureOr<void> onLoad() async {
    final bugComponent = Bug();
    bugComponent.position = Vector2(size.x / 2, size.y / 2);
    bugComponent.anchor = Anchor.center;
    add(bugComponent);
    return super.onLoad();
  }
}
