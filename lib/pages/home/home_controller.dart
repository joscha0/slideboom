import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxList positions = [].obs;
  // horizontal overflow tiles
  RxList hPositions = [].obs;
  // vertical overflow tiles
  RxList vPositions = [].obs;

  // saved tile positions
  RxMap tilePositions = {}.obs;

  double dragDistance = 0;

  double tileWidth = 100;

  int rowCount = 3;

  List isMovingVertically = [];
  List isMovingHorizontally = [];

  get randomColor =>
      Colors.primaries[Random().nextInt(Colors.primaries.length)];

  @override
  void onInit() {
    for (int i = 0; i < rowCount * rowCount; i++) {
      double x = (i % rowCount) * tileWidth;
      double y = (i ~/ rowCount) * tileWidth;
      positions.add([x, y]);

      // horizontal positions
      // first column
      if ((i + 1) % rowCount == 1) {
        x = rowCount * tileWidth;
        hPositions.add([x, y]);
        // last column
      } else if ((i + 1) % rowCount == 0) {
        x = -tileWidth;
        hPositions.add([x, y]);
      } else {
        hPositions.add([]);
      }

      // vertical positions
      // last row
      if (i ~/ rowCount == rowCount - 1) {
        x = (i % rowCount) * tileWidth;
        y = -tileWidth;
        vPositions.add([x, y]);
        // first row
      } else if (i ~/ rowCount == 0) {
        x = (i % rowCount) * tileWidth;
        y = rowCount * tileWidth;
        vPositions.add([x, y]);
      } else {
        vPositions.add([]);
      }

      // save positions
      tilePositions[i] = i;
    }
    super.onInit();
  }

  /*

  Move vertically
  
  */

  void onVerticalDragStart(DragStartDetails details, index) {
    if (isMovingHorizontally.isEmpty) {
      dragDistance = 0;
      isMovingVertically.add(index);
    }
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
      for (int i = 0; i < rowCount * rowCount; i++) {
        if (i % rowCount == index % rowCount) {
          positions[i][1] = (i ~/ rowCount) * tileWidth + dragDistance;
          if (i ~/ rowCount == rowCount - 1) {
            vPositions[i][1] = -tileWidth + dragDistance;
          } else if (i ~/ rowCount == 0) {
            vPositions[i][1] = rowCount * tileWidth + dragDistance;
          }
          update(['tile$i']);
          update(['vtile$i']);
        }
      }
    }
  }

  void onVerticalDragEnd(DragEndDetails details, index) {
    if (isMovingHorizontally.isEmpty) {
      print(dragDistance);
      if (dragDistance > tileWidth ~/ 2) {
        moveDown(index);
      } else if (dragDistance < -tileWidth ~/ 2) {
        moveUp(index);
      }
      // move tiles back
      for (int i = 0; i < rowCount * rowCount; i++) {
        if (i % rowCount == index % rowCount) {
          positions[i][1] = (i ~/ rowCount) * tileWidth;
          if (i ~/ rowCount == rowCount - 1) {
            vPositions[i][1] = -tileWidth;
          } else if (i ~/ rowCount == 0) {
            vPositions[i][1] = rowCount * tileWidth;
          }
          update(['tile$i']);
          update(['vtile$i']);
        }
      }
      isMovingVertically.remove(index);
    }
  }

  List getColumn(index) {
    List<int> tiles = [];
    Map tilePos = {};
    for (int i = 0; i < rowCount * rowCount; i++) {
      if (i % rowCount == index % rowCount) {
        tiles.add(i);
        tilePos[i] = tilePositions[i];
      }
    }
    return [tiles, tilePos];
  }

  void moveUp(index) {
    print('up');
    // get column indexes
    List column = getColumn(index);
    List<int> tiles = column[0];
    Map tilePos = column[1];

    // update tiles
    for (int i = 0; i < tiles.length; i++) {
      if (i == tiles.length - 1) {
        tilePositions[tiles[i]] = tilePos[tiles.first];
      } else {
        tilePositions[tiles[i]] = tilePos[tiles[i + 1]];
      }
    }
  }

  void moveDown(index) {
    // get column indexes
    List column = getColumn(index);
    List<int> tiles = column[0];
    Map tilePos = column[1];
    // update tiles
    for (int i = 0; i < tiles.length; i++) {
      if (i == 0) {
        tilePositions[tiles[i]] = tilePos[tiles.last];
      } else {
        tilePositions[tiles[i]] = tilePos[tiles[i - 1]];
      }
    }
  }

  /* 
  
  Move horizontally 
  
  */

  void onHorizontalDragStart(DragStartDetails details, index) {
    if (isMovingVertically.isEmpty) {
      dragDistance = 0;
      isMovingHorizontally.add(index);
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
      for (int i = 0; i < rowCount * rowCount; i++) {
        if (i ~/ rowCount == index ~/ rowCount) {
          positions[i][0] = (i % rowCount) * tileWidth + dragDistance;
          if ((i + 1) % rowCount == 1) {
            hPositions[i][0] = rowCount * tileWidth + dragDistance;
          } else if ((i + 1) % rowCount == 0) {
            hPositions[i][0] = -tileWidth + dragDistance;
          }
          update(['tile$i']);
          update(['htile$i']);
        }
      }
    }
  }

  void onHorizontalDragEnd(DragEndDetails details, index) {
    if (isMovingVertically.isEmpty) {
      print(dragDistance);
      if (dragDistance > tileWidth ~/ 2) {
        moveRight(index);
      } else if (dragDistance < -tileWidth ~/ 2) {
        moveLeft(index);
      }
      // move tiles back
      for (int i = 0; i < rowCount * rowCount; i++) {
        if (i ~/ rowCount == index ~/ rowCount) {
          positions[i][0] = (i % rowCount) * tileWidth;
          if ((i + 1) % rowCount == 1) {
            hPositions[i][0] = rowCount * tileWidth;
          } else if ((i + 1) % rowCount == 0) {
            hPositions[i][0] = -tileWidth;
          }
          update(['tile$i']);
          update(['htile$i']);
        }
      }
      isMovingHorizontally.remove(index);
    }
  }

  List getRow(index) {
    List<int> tiles = [];
    Map tilePos = {};
    for (int i = 0; i < rowCount * rowCount; i++) {
      if (i ~/ rowCount == index ~/ rowCount) {
        tiles.add(i);
        tilePos[i] = tilePositions[i];
      }
    }
    return [tiles, tilePos];
  }

  void moveLeft(index) {
    print('left');
    // get row indexes
    List row = getRow(index);
    List<int> tiles = row[0];
    Map tilePos = row[1];

    // update tiles
    for (int i = 0; i < tiles.length; i++) {
      if (i == tiles.length - 1) {
        tilePositions[tiles[i]] = tilePos[tiles.first];
      } else {
        tilePositions[tiles[i]] = tilePos[tiles[i + 1]];
      }
    }
  }

  void moveRight(index) {
    print('right');
    // get row indexes
    List row = getRow(index);
    List<int> tiles = row[0];
    Map tilePos = row[1];

    // update tiles
    for (int i = 0; i < tiles.length; i++) {
      if (i == 0) {
        tilePositions[tiles[i]] = tilePos[tiles.last];
      } else {
        tilePositions[tiles[i]] = tilePos[tiles[i - 1]];
      }
    }
  }
}
