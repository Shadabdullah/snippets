import 'package:flame/components.dart';

class BarrelSpriteComponent extends SpriteComponent {
  BarrelSpriteComponent({required Sprite sprite, required Vector2 size})
    : super(size: size, sprite: sprite, anchor: Anchor.bottomCenter);
}
