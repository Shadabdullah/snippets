import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:games/bugsquash/bug_sprite.dart';

class BugSquashGame extends FlameGame {
  late Timer _interval;

  BugSquashGame() {
    _interval = Timer(1.0, repeat: true, onTick: _createBug);
  }

  @override
  Color backgroundColor() {
    return const Color(0xFFEBFBEE);
  }

  @override
  void update(double dt) {
    _interval.update(dt);

    super.update(dt);
  }

  void _createBug() {
    final bugComponent = Bug();
    final gameHeight = size.y;
    final randomYPosition = Random().nextDouble() * gameHeight;
    bugComponent.anchor = Anchor.center;
    bugComponent.position = Vector2(0, randomYPosition);
    bugComponent.angle = pi / 2;
    bugComponent.onTap = () {
      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        if (!bugComponent.isRemoved) {
          remove(bugComponent);
        }
      });
    };
    add(bugComponent);
  }
}
