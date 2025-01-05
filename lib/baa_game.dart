import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart'; // For enforcing landscape mode

class BaaGame extends FlameGame with TapCallbacks {
  late SpriteComponent background;
  late SpriteComponent cliff;
  late Sheep sheep;

  @override
  Future<void> onLoad() async {
    // Enforce landscape mode
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Load background
    background = SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size;
    add(background);

    // Load cliff
    cliff = SpriteComponent()
      ..sprite = await loadSprite('cliff.png')
      ..size = Vector2(100, 300) // Adjust size as needed
      ..position = Vector2(50, size.y - 300); // Adjust position
    add(cliff);

    // Load sheep
    sheep = Sheep()
      ..position = Vector2(200, size.y - 150); // Adjust position
    add(sheep);
  }
}

class Sheep extends SpriteAnimationComponent with HasGameRef<BaaGame>, TapCallbacks {
  bool isJumping = false;
  double jumpSpeed = -300; // Speed of the jump
  double gravity = 500; // Gravity to bring the sheep down
  late SpriteAnimation idleAnimation;
  late SpriteAnimation jumpAnimation;

  @override
  Future<void> onLoad() async {
    size = Vector2(100, 100); // Adjust size as needed

    // Load idle animation (when sheep is standing)
    idleAnimation = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache('sheep.png'),
      SpriteAnimationData.sequenced(
        amount: 4, // Number of frames in idle animation
        stepTime: 0.2, // Time per frame
        textureSize: Vector2(128, 128), // Frame size
      ),
    );

    // Load jump animation (when sheep is jumping)
    jumpAnimation = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache('sheep_jump.png'),
      SpriteAnimationData.sequenced(
        amount: 4, // Number of frames in jump animation
        stepTime: 0.2, // Time per frame
        textureSize: Vector2(128, 128), // Frame size
      ),
    );

    animation = idleAnimation; // Start with idle animation
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isJumping) {
      isJumping = true;
      animation = jumpAnimation; // Switch to jump animation
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isJumping) {
      position.y += jumpSpeed * dt;
      jumpSpeed += gravity * dt;

      // Stop at ground level
      if (position.y >= gameRef.size.y - size.y) {
        position.y = gameRef.size.y - size.y;
        isJumping = false;
        jumpSpeed = -300; // Reset jump speed
        animation = idleAnimation; // Switch back to idle animation
      }
    }
  }
}
