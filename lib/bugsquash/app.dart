import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:games/bugsquash/bugsquash_game.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.red,
          body: GameWidget(game: BugSquashGame()),
        ),
      ),
    );
  }
}
