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
    position.y += 200 * dt; // Velocidad de caída
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bat) {
      int valor = Random().nextInt(2) + 1;

      if (valor == 1) {
        game.duplicateBalls(); // Duplica las bolas
      } else {
        game.updateBatSize(other.width + 100); // Aumenta el tamaño del bat

        // Si quieres que el efecto sea temporal:
        Future.delayed(Duration(seconds: 15), () {
          game.updateBatSize(other.width - 100); // Vuelve al tamaño original
        });
      }

      removeFromParent(); // Elimina el power-up tras la colisión
    }
  }
}
