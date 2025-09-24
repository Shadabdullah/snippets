import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';

class KlondikeGame extends FlameGame {
  @override
  FutureOr<void> onLoad() async {
    await Flame.images.load("klondike-sprites.png");
  }
}
