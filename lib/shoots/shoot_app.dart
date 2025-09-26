import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:games/shoots/shoot_game.dart';

class ShootApp extends StatelessWidget {
  const ShootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: ShootGame());
  }
}
