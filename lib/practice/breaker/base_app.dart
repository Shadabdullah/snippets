import 'package:flutter/material.dart';
import 'package:games/breaker/breaker_game.dart';
import 'package:games/breaker/game_board.dart';
import 'package:games/breaker/game_state_controller.dart';
import 'package:games/breaker/game_state_enum.dart';
import 'package:games/breaker/screens.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ShootApp extends GetView<GameStateController> {
  const ShootApp({super.key});

  @override
  Widget build(BuildContext context) {
    var game = BreakerGame();

    return Obx(() {
      switch (controller.gameState.value) {
        case GameState.launch:
          return const LaunchScreen();

        case GameState.play:
          if (controller.doGameRestart.value) {
            game = BreakerGame();
            controller.doGameRestart.value = false;
            controller.resetScore();
          }
          return GameBoard(game: game);

        case GameState.pause:
          return const PauseScreen();

        case GameState.gameOver:
          return const GameOverScreen();
      }
    });
  }
}
