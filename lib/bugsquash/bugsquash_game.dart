import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BugsquashGame extends FlameGame {
  @override
  Color backgroundColor() {
    return Colors.white;
  }

  @override
  FutureOr<void> onLoad() async {
    final bugSprite = await Sprite.load("bug.png");
    final bugComponent = SpriteComponent(
      sprite: bugSprite,
      size: Vector2(50, 50),
    );
    bugComponent.position = Vector2(100, 300);
    bugComponent.anchor = Anchor.topLeft;
    add(bugComponent);
    return super.onLoad();
  }
}
