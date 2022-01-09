import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxList positions = [].obs;
  get randomColor =>
      Colors.primaries[Random().nextInt(Colors.primaries.length)];

  int dragDistance = 0;

  @override
  void onInit() {
    for (int i = 0; i < 9; i++) {
      int x = (i % 3) * 150;
      int y = (i ~/ 3) * 150;
      positions.add([x, y]);
    }
    super.onInit();
  }

  void onVerticalDragUpdate(details, index) {
    dragDistance += details.delta.dy as int;
    if (dragDistance > 150) {
      dragDistance = 150;
    }
    if (dragDistance < -150) {
      dragDistance = -150;
    }
    for (int i = 0; i < 9; i++) {
      if (i % 3 == index % 3) {
        positions[i][1] = (i ~/ 3) * 150 + dragDistance;
        update(['tile$i']);
      }
    }
  }

  void onVerticalDragStart(DragStartDetails details) {
    dragDistance = 0;
  }

  void onVerticalDragEnd(DragEndDetails details, index) {
    print(dragDistance);
    if (dragDistance > 50) {
      moveDown();
    } else if (dragDistance < -50) {
      moveUp();
    }
    for (int i = 0; i < 9; i++) {
      if (i % 3 == index % 3) {
        positions[i][1] = (i ~/ 3) * 150;
        update(['tile$i']);
      }
    }
  }

  void moveUp() {
    print('up');
  }

  void moveDown() {
    print('down');
  }

  void onHorizontalDragStart(DragStartDetails details) {
    dragDistance = 0;
  }

  void onHorizontalDragEnd(DragEndDetails details, index) {
    print(dragDistance);
    if (dragDistance > 50) {
      moveRight();
    } else if (dragDistance < -50) {
      moveLeft();
    }
    for (int i = 0; i < 9; i++) {
      if (i ~/ 3 == index ~/ 3) {
        positions[i][0] = (i % 3) * 150;
        update(['tile$i']);
      }
    }
  }

  void onHorizontalDragUpdate(DragUpdateDetails details, index) {
    dragDistance += details.delta.dx as int;

    if (dragDistance > 150) {
      dragDistance = 150;
    }
    if (dragDistance < -150) {
      dragDistance = -150;
    }
    for (int i = 0; i < 9; i++) {
      if (i ~/ 3 == index ~/ 3) {
        positions[i][0] = (i % 3) * 150 + dragDistance;
        update(['tile$i']);
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
