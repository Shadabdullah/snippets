import 'package:games/breaker/game_state_enum.dart';
import 'package:get/get.dart';

class GameStateController extends GetxController {
  final Rx<GameState> gameState = GameState.play.obs;

  // Restart flag
  final RxBool doGameRestart = false.obs;

  // Score
  final RxInt score = 0.obs;
  final RxInt highScore = 0.obs;

  void resetScore() {
    score.value = 0;
  }

  void setGameState(GameState state) {
    gameState.value = state;
  }

  void requestRestart() {
    doGameRestart.value = true;
  }
}
