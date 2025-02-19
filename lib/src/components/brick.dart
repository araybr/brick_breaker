import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../brick_breaker.dart';
import '../config.dart';
import 'ball.dart';
import 'bat.dart';
import 'power_ball.dart';

class Brick extends RectangleComponent with CollisionCallbacks {
  final BrickBreaker game; // Referencia explícita al juego
  int health; // Resistencia del ladrillo

  Brick({
    required this.game,
    required super.position,
    required Color color,
    this.health = 1,
  }) : super(
          size: Vector2(brickWidth, brickHeight),
          anchor: Anchor.center,
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.fill,
          children: [RectangleHitbox()],
        );

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Ball) {
      health--;
      if (health <= 0) {
        removeFromParent();
        game.score.value++;

        //20% probabilidad
        if (game.rand.nextDouble() < 0.2) {
          game.world.add(PowerUpBall(position: position.clone()));
        }

        if (game.world.children.query<Brick>().length == 1) {
          game.playState = PlayState.won;
          game.world.removeAll(game.world.children.query<Ball>());
          game.world.removeAll(game.world.children.query<Bat>());
        }
      } else {
        paint.color = paint.color.withOpacity(health / 3);
      }
    }
  }
}

