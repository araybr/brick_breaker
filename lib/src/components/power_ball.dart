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
    position.y += 100 * dt; // Velocidad de caída
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    var valor;
    if (other is Bat) {
      valor = Random().nextInt(2)+1;
      if(valor==1){
        game.duplicateBalls(); // Duplica las bolas cuando se recoge
        removeFromParent();
      }else{
        batWidth= batWidth+100;
      }
     
      
    }
  }
}
