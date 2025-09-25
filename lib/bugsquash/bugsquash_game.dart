import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:games/bugsquash/bug_sprite.dart';

class BugSquashGame extends FlameGame {
  @override
  Color backgroundColor() {
    return const Color(0xFFEBFBEE);
  }

  @override
  FutureOr<void> onLoad() async {
    final bugComponent = _createBug();
    // Remove the bug 500 ms after tapping
    bugComponent.onTap = () {
      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        if (!bugComponent.isRemoved) {
          remove(bugComponent);
        }
      });
    };
    add(bugComponent);
    return super.onLoad();
  }

  Bug _createBug() {
    final bugComponent = Bug();
    final gameHeight = size.y;
    final randomYPosition = Random().nextDouble() * gameHeight;
    bugComponent.anchor = Anchor.center;
    bugComponent.position = Vector2(0, randomYPosition);
    bugComponent.angle = pi / 2;
    return bugComponent;
  }
}
