import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxList positions = [].obs;
  // horizontal overflow tiles
  RxList hPositions = [].obs;
  // vertical overflow tiles
  RxList vPositions = [].obs;

  get randomColor =>
      Colors.primaries[Random().nextInt(Colors.primaries.length)];

  RxMap tilePositions = {}.obs;

  double dragDistance = 0;

  double tileWidth = 100;

  List isMovingVertically = [];
  List isMovingHorizontally = [];

  @override
  void onInit() {
    for (int i = 0; i < 9; i++) {
      double x = (i % 3) * tileWidth;
      double y = (i ~/ 3) * tileWidth;
      positions.add([x, y]);

      // horizontal positions
      // first column
      if ((i + 1) % 3 == 1) {
        x = 3 * tileWidth;
        hPositions.add([x, y]);
        // last column
      } else if ((i + 1) % 3 == 0) {
        x = -tileWidth;
        hPositions.add([x, y]);
      } else {
        hPositions.add([]);
      }

      // vertical positions
      // last row
      if (i ~/ 3 == 3 - 1) {
        x = (i % 3) * tileWidth;
        y = -tileWidth;
        vPositions.add([x, y]);
        // first row
      } else if (i ~/ 3 == 0) {
        x = (i % 3) * tileWidth;
        y = 3 * tileWidth;
        vPositions.add([x, y]);
      } else {
        vPositions.add([]);
      }
    }
    super.onInit();
  }

  void onVerticalDragUpdate(details, index) {
    if (isMovingHorizontally.isEmpty) {
      dragDistance += details.delta.dy;
      if (dragDistance > tileWidth) {
        dragDistance = tileWidth;
      }
      if (dragDistance < -tileWidth) {
        dragDistance = -tileWidth;
      }
      for (int i = 0; i < 9; i++) {
        if (i % 3 == index % 3) {
          positions[i][1] = (i ~/ 3) * tileWidth + dragDistance;
          if (i ~/ 3 == 3 - 1) {
            vPositions[i][1] = -tileWidth + dragDistance;
          } else if (i ~/ 3 == 0) {
            vPositions[i][1] = 3 * tileWidth + dragDistance;
          }
          update(['tile$i']);
          update(['vtile$i']);
        }
      }
    }
  }

  void onVerticalDragStart(DragStartDetails details, index) {
    if (isMovingHorizontally.isEmpty) {
      dragDistance = 0;
      isMovingVertically.add(index);
    }
  }

  void onVerticalDragEnd(DragEndDetails details, index) {
    if (isMovingHorizontally.isEmpty) {
      print(dragDistance);
      if (dragDistance > 50) {
        moveDown();
      } else if (dragDistance < -50) {
        moveUp();
      }
      for (int i = 0; i < 9; i++) {
        if (i % 3 == index % 3) {
          positions[i][1] = (i ~/ 3) * tileWidth;
          if (i ~/ 3 == 3 - 1) {
            vPositions[i][1] = -tileWidth;
          } else if (i ~/ 3 == 0) {
            vPositions[i][1] = 3 * tileWidth;
          }
          update(['tile$i']);
          update(['vtile$i']);
        }
      }
      isMovingVertically.remove(index);
    }
  }

  void moveUp() {
    print('up');
  }

  void moveDown() {
    print('down');
  }

  void onHorizontalDragStart(DragStartDetails details, index) {
    if (isMovingVertically.isEmpty) {
      dragDistance = 0;
      isMovingHorizontally.add(index);
    }
  }

  void onHorizontalDragEnd(DragEndDetails details, index) {
    if (isMovingVertically.isEmpty) {
      print(dragDistance);
      if (dragDistance > 50) {
        moveRight();
      } else if (dragDistance < -50) {
        moveLeft();
      }
      for (int i = 0; i < 9; i++) {
        if (i ~/ 3 == index ~/ 3) {
          positions[i][0] = (i % 3) * tileWidth;
          if ((i + 1) % 3 == 1) {
            hPositions[i][0] = 3 * tileWidth;
          } else if ((i + 1) % 3 == 0) {
            hPositions[i][0] = -tileWidth;
          }
          update(['tile$i']);
          update(['htile$i']);
        }
      }
      isMovingHorizontally.remove(index);
    }
  }

  void onHorizontalDragUpdate(DragUpdateDetails details, index) {
    if (isMovingVertically.isEmpty) {
      dragDistance += details.delta.dx;

      if (dragDistance > tileWidth) {
        dragDistance = tileWidth;
      }
      if (dragDistance < -tileWidth) {
        dragDistance = -tileWidth;
      }
      for (int i = 0; i < 9; i++) {
        if (i ~/ 3 == index ~/ 3) {
          positions[i][0] = (i % 3) * tileWidth + dragDistance;
          if ((i + 1) % 3 == 1) {
            hPositions[i][0] = 3 * tileWidth + dragDistance;
          } else if ((i + 1) % 3 == 0) {
            hPositions[i][0] = -tileWidth + dragDistance;
          }
          update(['tile$i']);
          update(['htile$i']);
        }
      }
    }
  }

  void moveLeft() {
    print('left');
  }

  void moveRight() {
    print('right');
  }
}
