import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:games/breaker/breaker_game.dart';

import 'package:games/breaker/game_constants.dart';
import 'package:get/get.dart';
import 'game_state_controller.dart';
import 'game_state_enum.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key, required this.game});

  final BreakerGame game;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GameStateController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        // Example logo
        Image.asset('assets/images/bug.png', width: 50, height: 50),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: GameConstants.backGroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pause / Play button
              Obx(() {
                return GestureDetector(
                  onTap: () => controller.setGameState(
                    controller.gameState.value == GameState.pause
                        ? GameState.play
                        : GameState.pause,
                  ),
                  child: Icon(
                    controller.gameState.value == GameState.pause
                        ? Icons.play_arrow
                        : Icons.pause,
                    color: GameConstants.whiteColor,
                  ),
                );
              }),

              // Current Score
              Obx(() {
                return Text(
                  controller.score.value.toString(),
                  style: const TextStyle(
                    color: GameConstants.whiteColor,
                    fontSize: 26,
                  ),
                );
              }),

              // Best Score
              Column(
                children: [
                  const Text(
                    'Best',
                    style: TextStyle(
                      color: GameConstants.whiteColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    return Text(
                      controller.highScore.value.toString(),
                      style: const TextStyle(
                        color: GameConstants.whiteColor,
                        fontSize: 22,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
        Expanded(child: GameWidget(game: game)),
        const SizedBox(height: 100),
      ],
    );
  }
}
