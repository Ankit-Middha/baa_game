import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart'; // For enforcing landscape mode
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 

class BaaGame extends FlameGame with TapCallbacks {
  late SpriteComponent background;
  late SpriteComponent cliff;
  late Sheep sheep;
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  final String _apiSubscriptionKey = 'ef40f987-8455-411d-8d95-2611e364f00d'; 

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

    
    _speechToText = stt.SpeechToText();
    await _speechToText.initialize(onStatus: (status) {
      _isListening = status == 'listening';
    });

    // Start listening to the speech input
    _startListening();

    background = SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size;
    add(background);

    cliff = SpriteComponent()
      ..sprite = await loadSprite('cliff.png')
      ..size = Vector2(300, 200) 
      ..position = Vector2(0, size.y - 200); 
    add(cliff);

    
    sheep = Sheep()
      ..position = Vector2(10, size.y - 250); 
    add(sheep);
  }

  void _startListening() async {
    if (!_isListening) {
      _speechToText.listen(onResult: (result) {
        // Print the recognized words
        print('Recognized Words: ${result.recognizedWords}');

        // Check if the recognized words contain 'Baa'
        if (result.recognizedWords.toLowerCase().contains('ba')) {
          // Send audio data to the API when "Baa" is recognized
          _sendAudioDataToAPI();
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

  Future<void> _sendAudioDataToAPI() async {
    try {
      // API request to send audio data for transcription
      final response = await http.post(
        Uri.parse('https://api.sarvam.ai/speech-to-text'),
        headers: {
          'api-subscription-key': _apiSubscriptionKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'saarika:v2', 
          'language_code': 'en-IN', 
         
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final recognizedText = result['transcript'] ?? '';

        print('Recognized Words: $recognizedText');

        if (recognizedText.toLowerCase().contains('ba')) {
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
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in sending audio to API: $e');
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
