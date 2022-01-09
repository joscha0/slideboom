import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  get randomColor =>
      Colors.primaries[Random().nextInt(Colors.primaries.length)];

  int dragDistance = 0;

  void onVerticalDragUpdate(details) {
    dragDistance += details.delta.dy as int;
  }

  void onVerticalDragStart(DragStartDetails details) {
    dragDistance = 0;
  }

  void onVerticalDragEnd(DragEndDetails details) {
    print(dragDistance);
    if (dragDistance > 50) {
      moveDown();
    } else if (dragDistance < -50) {
      moveUp();
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

  void onHorizontalDragEnd(DragEndDetails details) {
    print(dragDistance);
    if (dragDistance > 50) {
      moveRight();
    } else if (dragDistance < -50) {
      moveLeft();
    }
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    dragDistance += details.delta.dx as int;
  }

  void moveLeft() {
    print('left');
  }

  void moveRight() {
    print('right');
  }
}
