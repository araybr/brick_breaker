import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  BrickBreaker()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );
  final ValueNotifier<int> score = ValueNotifier(0);
  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;
  late PlayState _playState;
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(PlayArea());
    playState = PlayState.welcome;
  }

  void startGame() {
    if (playState == PlayState.playing) return;
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());
    playState = PlayState.playing;
    score.value = 0;
    world.add(Ball(
        difficultyModifier: difficultyModifier,
        radius: ballRadius,
        position: size / 2,
        velocity: Vector2((rand.nextDouble() - 0.5) * width, height * 0.2)
            .normalized()
          ..scale(height / 4)));
    world.add(Bat(
        size: Vector2(batWidth, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position: Vector2(width / 2, height * 0.95)));
    world.addAll([
      for (var i = 0; i < brickColors.length; i++)
        for (var j = 1; j <= 5; j++)
          Brick(
            game: this,
            position: Vector2(
              (i + 0.5) * brickWidth + (i + 1) * brickGutter,
              (j + 2.0) * brickHeight + j * brickGutter,
            ),
            color: brickColors[i],
            health: rand.nextInt(3) + 1,
          ),
    ]);
  }

  void duplicateBalls() {
    final existingBalls = world.children.query<Ball>().toList();
    for (var ball in existingBalls) {
      final newBall = Ball(
        difficultyModifier: difficultyModifier,
        radius: ballRadius,
        position: ball.position.clone(),
        velocity: ball.velocity.clone()
          ..rotate(math.pi / 6),
      );
      world.add(newBall);
    }
  }

  void updateBatSize(double newWidth) {
    final bat = world.children.query<Bat>().firstOrNull;
    if (bat != null) {
      bat.width = newWidth;
    }
  }

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-batStep);
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(batStep);
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        startGame();
    }
    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
