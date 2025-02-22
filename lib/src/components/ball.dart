import 'package:brick_breaker/src/config.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';

import 'package:flutter/material.dart';
import '../brick_breaker.dart';
import 'bat.dart';
import 'brick.dart';
import 'play_area.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
            radius: radius,
            anchor: Anchor.center,
            paint: Paint()
              ..color = const Color.fromARGB(255, 255, 255, 255)
              ..style = PaintingStyle.fill,
            children: [CircleHitbox()]);

  final Vector2 velocity;
  final double difficultyModifier;

  @override
  void update(double dt) {
    super.update(dt);
     final adjustedVelocity = (velocity.length > limiteVelocidad)
      ? velocity.normalized() * limiteVelocidad
      : velocity;
    position += adjustedVelocity * dt;
    final particle = ParticleSystemComponent(
      position: position.clone(),
      priority: 1,
      particle: Particle.generate(
        count: 8, // Cantidad de Partículas
        lifespan: 0.8, // Duración de cada partícula
        generator: (i) {
          return ComputedParticle(
            lifespan: 0.4,
            renderer: (canvas, particle) {
              final progress = 1 - particle.progress; 
              final paint = Paint()
                ..color = const Color.fromARGB(255, 248, 232, 232).withOpacity(
                    progress * 0.5);

              final size =
                  radius * 0.3 * progress;

              canvas.drawCircle(Offset.zero, size, paint);
            },
          );
        },
      ),
    );
    game.world.add(particle);
    priority = 1;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        if (game.world.children.query<Ball>().length == 1) {
          add(RemoveEffect(
              delay: 0.35,
              onComplete: () {
                game.playState = PlayState.gameOver;
              }));
        } else {
          removeFromParent();
        }
      }
    } else if (other is Bat) {
      velocity.y = -velocity.y;
      velocity.x = velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
    } else if (other is Brick) {
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
      velocity.setFrom(velocity * difficultyModifier);
    }
  }
}
