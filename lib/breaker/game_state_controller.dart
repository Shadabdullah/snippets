import 'package:games/breaker/game_state_enum.dart';
import 'package:get/get.dart';

class GameStateController extends GetxController {
  final Rx<GameState> gameState = GameState.launch.obs;

  void setGameState(GameState state) {
    gameState.value = state;
  }
}
