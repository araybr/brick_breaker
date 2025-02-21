import 'dart:math';

import 'package:brick_breaker/src/config.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../brick_breaker.dart';
import 'ball.dart';
import 'bat.dart';

class PowerUpBall extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  PowerUpBall({required Vector2 position})
      : super(
          radius: 10,
          position: position,
          paint: Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill,
          children: [CircleHitbox()],
        );

  @override
  void update(double dt) {
    super.update(dt);
    position.y += 200 * dt; 
    if(game.playState!=PlayState.playing){
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bat) {
      int valor = Random().nextInt(2) + 1;

      if (valor == 1) {
        game.duplicateBalls();
      } else {
        game.updateBatSize(other.width + 100); 
        Future.delayed(Duration(seconds: 10), () {
          game.updateBatSize(other.width - 100); 
        });
      }

      removeFromParent();
    }
  }
}
