import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:games/shoots/components/barrel_sprite.dart';

class ShootGame extends FlameGame with PanDetector {
  late BarrelSpriteComponent barrel;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    await Flame.device.fullScreen();
    await Flame.device.setPortrait();

    final barrelSprite = await Sprite.load("barrel.png");
    barrel = BarrelSpriteComponent(sprite: barrelSprite, size: size);
    barrel.position = Vector2(size.x / 2, size.y - 20);
    barrel.size = Vector2(70, 100);

    add(barrel);
  }

  @override
  Color backgroundColor() {
    return Colors.white;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    const sensitivity = 0.01; // radians per pixel
    barrel.angle += info.delta.global.x * sensitivity;
    super.onPanUpdate(info);
  }
}
