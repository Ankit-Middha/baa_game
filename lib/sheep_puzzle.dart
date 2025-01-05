// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flame/game.dart';
// import 'package:flutter/material.dart';

// class SheepPuzzleGame extends FlameGame {
//   @override
//   Future<void> onLoad() async {
//     super.onLoad();

//     // Add the background
//     add(SpriteComponent()
//       ..sprite = await loadSprite('background.png')
//       ..size = size);

//     // Add the body (static target area)
//     add(SheepPart(
//       spritePath: 'body.png',
//       position: Vector2(size.x / 2 - 100, size.y / 2),
//       isTarget: true,
//     ));

//     // Add the draggable head
//     add(SheepPart(
//       spritePath: 'head.png',
//       position: Vector2(50, 50),
//       targetPosition: Vector2(size.x / 2 - 100, size.y / 2 - 100),
//     ));

//     // Add draggable combined legs
//     add(CombinedLegs(
//       spritePath: 'legs.png',
//       position: Vector2(50, size.y - 150),
//       targetPosition: Vector2(size.x / 2 - 100, size.y / 2 + 50),
//     ));

//     // Add the draggable tail
//     add(SheepPart(
//       spritePath: 'tail.png',
//       position: Vector2(size.x - 100, size.y - 150),
//       targetPosition: Vector2(size.x / 2 + 80, size.y / 2),
//     ));
//   }
// }

// class SheepPart extends SpriteComponent with DragCallbacks {
//   final bool isTarget;
//   final Vector2? targetPosition;

//   SheepPart({
//     required String spritePath,
//     required Vector2 position,
//     this.isTarget = false,
//     this.targetPosition,
//   }) : super(size: Vector2(100, 100), position: position);

//   @override
//   Future<void> onLoad() async {
//     super.onLoad();
//     sprite = await gameRef.loadSprite(spritePath);
//   }

//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     if (!isTarget) {
//       position += event.delta; // Move the part with the drag
//     }
//   }

//   @override
//   void onDragEnd(DragEndEvent event) {
//     super.onDragEnd(event);
//     if (!isTarget && targetPosition != null) {
//       // Snap to the target if within range
//       if ((position - targetPosition!).length < 50) {
//         position = targetPosition!;
//       }
//     }
//   }
// }

// class CombinedLegs extends SpriteComponent with DragCallbacks {
//   final Vector2 targetPosition;

//   CombinedLegs({
//     required String spritePath,
//     required Vector2 position,
//     required this.targetPosition,
//   }) : super(size: Vector2(200, 100), position: position);

//   @override
//   Future<void> onLoad() async {
//     super.onLoad();
//     sprite = await gameRef.loadSprite(spritePath);
//   }

//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     position += event.delta; // Move the legs with the drag
//   }

//   @override
//   void onDragEnd(DragEndEvent event) {
//     super.onDragEnd(event);

//     // Snap to the target if within range
//     if ((position - targetPosition).length < 50) {
//       position = targetPosition;
//     }
//   }
// }

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class SheepPuzzleGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Add the background
    add(SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size);

    // Add the body (static target area)
    add(SheepPart(
      spritePath: 'body.png',
      position: Vector2(size.x / 2 - 100, size.y / 2),
      isTarget: true,
    ));

    // Add the draggable head
    add(SheepPart(
      spritePath: 'head.png',
      position: Vector2(50, 50),
      targetPosition: Vector2(size.x / 2 - 100, size.y / 2 - 100),
    ));

    // Add draggable combined legs
    add(CombinedLegs(
      spritePath: 'legs.png', // Correctly passing spritePath
      position: Vector2(50, size.y - 150),
      targetPosition: Vector2(size.x / 2 - 100, size.y / 2 + 50),
    ));

    // Add the draggable tail
    add(SheepPart(
      spritePath: 'tail.png',
      position: Vector2(size.x - 100, size.y - 150),
      targetPosition: Vector2(size.x / 2 + 80, size.y / 2),
    ));
  }
}

class SheepPart extends SpriteComponent with DragCallbacks {
  final bool isTarget;
  final Vector2? targetPosition;

  SheepPart({
    required String spritePath,
    required Vector2 position,
    this.isTarget = false,
    this.targetPosition,
  }) : super(size: Vector2(100, 100), position: position);

  @override
  Future<void> onLoad(dynamic spritePath) async {
    super.onLoad();
    var gameRef;
    sprite = await gameRef.loadSprite(spritePath); // Load sprite
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isTarget) {
      position += event.delta; // Move the part with the drag
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!isTarget && targetPosition != null) {
      // Snap to the target if within range
      if ((position - targetPosition!).length < 50) {
        position = targetPosition!;
      }
    }
  }
}

class CombinedLegs extends SpriteComponent with DragCallbacks {
  final String spritePath;
  final Vector2 targetPosition;

  CombinedLegs({
    required this.spritePath, // Define the spritePath parameter
    required Vector2 position,
    required this.targetPosition,
  }) : super(size: Vector2(200, 100), position: position);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite(spritePath); // Load the single legs sprite
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.delta; // Move the legs with the drag
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    // Snap to the target if within range
    if ((position - targetPosition).length < 50) {
      position = targetPosition;
    }
  }
}
