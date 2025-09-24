import 'dart:async';

import 'package:flame/components.dart';

class Bug extends SpriteComponent {
  Bug() : super(size: Vector2(50, 50), anchor: Anchor.center);
  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('bug.png');
    return super.onLoad();
  }
}
