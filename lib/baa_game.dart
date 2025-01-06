// import 'package:flame/events.dart';
// import 'package:flame/game.dart';
// import 'package:flame/components.dart';
// import 'package:flutter/services.dart'; // For enforcing landscape mode

// class BaaGame extends FlameGame with TapCallbacks {
//   late SpriteComponent background;
//   late SpriteComponent cliff;
//   late Sheep sheep;

//   @override
//   Future<void> onLoad() async {
//     // Enforce landscape mode
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);

//     // Preload images
//     await images.loadAll([
//       'background.png',
//       'cliff.png',
//       'sheep.png',
//       'sheep_jump.png',
//     ]);

//     // Load background
//     background = SpriteComponent()
//       ..sprite = await loadSprite('background.png')
//       ..size = size;
//     add(background);

//     // Load cliff with X-axis set to 0
//     cliff = SpriteComponent()
//       ..sprite = await loadSprite('cliff.png')
//       ..size = Vector2(100, 300) // Adjust size as needed
//       ..position = Vector2(0, size.y - 300); // X-axis at 0, adjust Y for bottom alignment
//     add(cliff);

//     // Load sheep at the top of the cliff
//     sheep = Sheep()
//       ..position = Vector2(25, size.y - 400); // Adjust position to place on the top of the cliff
//     add(sheep);
//   }
// }

// class Sheep extends PositionComponent with HasGameRef<BaaGame>, TapCallbacks {
//   bool isJumping = false;
//   double jumpSpeedY = -300; // Vertical jump speed
//   double jumpSpeedX = 150; // Horizontal speed
//   double gravity = 500; // Gravity to bring the sheep down
//   late SpriteComponent idleSprite;
//   late SpriteAnimationComponent jumpAnimation;

//   @override
//   Future<void> onLoad() async {
//     size = Vector2(100, 100); // Adjust size as needed

//     // Load the idle sprite (sheep.png)
//     idleSprite = SpriteComponent()
//       ..sprite = await gameRef.loadSprite('sheep.png')
//       ..size = size
//       ..position = Vector2.zero();
//     add(idleSprite);

//     // Load the jump animation (sheep_jump.png)
//     jumpAnimation = SpriteAnimationComponent()
//       ..animation = SpriteAnimation.fromFrameData(
//         gameRef.images.fromCache('sheep_jump.png'),
//         SpriteAnimationData.sequenced(
//           amount: 4, // Number of frames in jump animation
//           stepTime: 0.1, // Time per frame for smooth transition
//           textureSize: Vector2(128, 128), // Frame size
//         ),
//       )
//       ..size = size
//       ..position = Vector2.zero()
//       ..opacity = 0; // Initially hidden
//     add(jumpAnimation);
//   }

//   @override
//   void onTapDown(TapDownEvent event) {
//     if (!isJumping) {
//       isJumping = true;
//       idleSprite.opacity = 0; // Hide idle sprite smoothly
//       jumpAnimation.opacity = 1; // Show jump animation smoothly
//     }
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);

//     if (isJumping) {
//       position.y += jumpSpeedY * dt; // Vertical movement
//       position.x += jumpSpeedX * dt; // Horizontal movement
//       jumpSpeedY += gravity * dt; // Apply gravity

//       // Stop at ground level
//       if (position.y >= gameRef.size.y - size.y) {
//         position.y = gameRef.size.y - size.y;
//         isJumping = false;
//         jumpSpeedY = -300; // Reset vertical jump speed

//         // Smoothly transition back to idle sprite
//         jumpAnimation.opacity = 0; // Hide jump animation smoothly
//         idleSprite.opacity = 1; // Show idle sprite smoothly
//       }
//     }
//   }
// }
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart'; // For enforcing landscape mode
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/gestures.dart';

class BaaGame extends FlameGame with TapCallbacks {
  late SpriteComponent background;
  late SpriteComponent cliff;
  late Sheep sheep;
  late stt.SpeechToText _speechToText;
  bool _isListening = false;

  @override
  Future<void> onLoad() async {
    // Enforce landscape mode
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Preload images
    await images.loadAll([
      'background.png',
      'cliff.png',
      'sheep.png',
      'sheep_jump.png',
    ]);

    // Initialize Speech to Text
    _speechToText = stt.SpeechToText();
    await _speechToText.initialize(onStatus: (status) {
      _isListening = status == 'listening';
    });

    // Start listening to the speech input
    _startListening();

    // Load background
    background = SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size;
    add(background);

    // Load cliff with X-axis set to 0
    cliff = SpriteComponent()
      ..sprite = await loadSprite('cliff.png')
      ..size = Vector2(100, 300) // Adjust size as needed
      ..position = Vector2(0, size.y - 300); // X-axis at 0, adjust Y for bottom alignment
    add(cliff);

    // Load sheep at the top of the cliff
    sheep = Sheep()
      ..position = Vector2(25, size.y - 400); // Adjust position to place on the top of the cliff
    add(sheep);
  }

  void _startListening() async {
    if (!_isListening) {
      _speechToText.listen(onResult: (result) {
        // Print the recognized words
        print('Recognized Words: ${result.recognizedWords}');

        if (result.recognizedWords.toLowerCase().contains('Baa')) {
        
          sheep.onTapDown(
            TapDownEvent(
              0, // pointerId
              this, // Reference to the current game
              TapDownDetails(
                globalPosition: Offset.zero, // Mock position (adjust as needed)
                localPosition: Offset.zero, // Mock local position
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    _speechToText.stop(); // Stop listening when the game is removed
  }
}

class Sheep extends PositionComponent with HasGameRef<BaaGame>, TapCallbacks {
  bool isJumping = false;
  double jumpSpeedY = -300; // Vertical jump speed
  double jumpSpeedX = 150; // Horizontal speed
  double gravity = 500; // Gravity to bring the sheep down
  late SpriteComponent idleSprite;
  late SpriteAnimationComponent jumpAnimation;

  @override
  Future<void> onLoad() async {
    size = Vector2(100, 100); // Adjust size as needed

    // Load the idle sprite (sheep.png)
    idleSprite = SpriteComponent()
      ..sprite = await gameRef.loadSprite('sheep.png')
      ..size = size
      ..position = Vector2.zero();
    add(idleSprite);

    // Load the jump animation (sheep_jump.png)
    jumpAnimation = SpriteAnimationComponent()
      ..animation = SpriteAnimation.fromFrameData(
        gameRef.images.fromCache('sheep_jump.png'),
        SpriteAnimationData.sequenced(
          amount: 1, // Number of frames in jump animation
          stepTime: 0.1, // Time per frame for smooth transition
          textureSize: Vector2(128, 128), // Frame size
        ),
      )
      ..size = size
      ..position = Vector2.zero()
      ..opacity = 0; // Initially hidden
    add(jumpAnimation);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isJumping) {
      isJumping = true;
      idleSprite.opacity = 0; // Hide idle sprite smoothly
      jumpAnimation.opacity = 1; // Show jump animation smoothly
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isJumping) {
      position.y += jumpSpeedY * dt; // Vertical movement
      position.x += jumpSpeedX * dt; // Horizontal movement
      jumpSpeedY += gravity * dt; // Apply gravity

      // Stop at ground level
      if (position.y >= gameRef.size.y - size.y) {
        position.y = gameRef.size.y - size.y;
        isJumping = false;
        jumpSpeedY = -300; // Reset vertical jump speed

        // Smoothly transition back to idle sprite
        jumpAnimation.opacity = 0; // Hide jump animation smoothly
        idleSprite.opacity = 1; // Show idle sprite smoothly
      }
    }
  }
}
