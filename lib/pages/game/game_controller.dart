import 'package:fixmymaze/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameController extends GetxController {
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

  Rx<Duration> animationDuration = const Duration(milliseconds: 0).obs;

  String colorMode = 'color';

  bool bordersEnabled = false; // 'gray', 'color', 'white'

  bool solved = false;

  getColor(int index) {
    if (solved) {
      return Colors.green;
    }

    if (colorMode == 'gray') {
      return Color.fromRGBO(255 - index * (10 - rowCount),
          255 - index * (10 - rowCount), 255 - index * (10 - rowCount), 1);
    } else if (colorMode == 'color') {
      // TODO implement own color list
      if (rowCount * rowCount * 3 <= Colors.primaries.length) {
        return Colors.primaries[tilePositions[index] * 3];
      } else if (rowCount * rowCount * 2 <= Colors.primaries.length) {
        return Colors.primaries[tilePositions[index] * 2];
      } else if (rowCount * rowCount <= Colors.primaries.length) {
        return Colors.primaries[tilePositions[index]];
      } else if (tilePositions[index] < Colors.primaries.length) {
        return Colors.primaries[tilePositions[index]];
      } else {
        return Colors.primaries[tilePositions[index] % Colors.primaries.length];
      }
    } else {
      return Colors.white;
    }
  }

  @override
  void onInit() {
    rowCount = Get.arguments;
    setTileWidth();
    setPositions();
    super.onInit();
  }

  void setTileWidth() {
    if (Get.size.aspectRatio < 1) {
      tileWidth = (Get.size.width - Get.size.width * 0.25) / rowCount;
    } else {
      tileWidth = (Get.size.height - Get.size.height * 0.25) / rowCount;
    }
  }

  void setPositions() {
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
    }

    // starting position
    shuffleStartingPosition();
  }

  void shuffleStartingPosition() {
    // TODO make move shuffle (this results in unsolvable parity)
    List valueOptions = List.generate(rowCount * rowCount, (index) => index);
    valueOptions.shuffle();
    for (int i = 0; i < rowCount * rowCount; i++) {
      tilePositions[i] = valueOptions[i];
    }
    if (checkSolved()) {
      shuffleStartingPosition();
    }
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

  void onVerticalDragUpdate(DragUpdateDetails details, index) {
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
      bool isMoving = false;

      if (dragDistance > tileWidth ~/ 2) {
        moveDown(index);
        isMoving = true;
      } else if (dragDistance < -tileWidth ~/ 2) {
        moveUp(index);
        isMoving = true;
      }

      if (isMoving) {
        animationDuration.value = const Duration(milliseconds: 0);
      } else {
        animationDuration.value = const Duration(milliseconds: 100);
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
      if (checkSolved()) {
        // disable movement
        isMovingHorizontally.add(-1);
        isMovingVertically.add(-1);
        solved = true;
        updateAllTiles();
        Get.defaultDialog(
          title: 'solved!',
          middleText: '',
          onConfirm: () => Get.offAll(const HomePage()),
        );
      }
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
      bool isMoving = false;
      if (dragDistance > tileWidth ~/ 2) {
        moveRight(index);
        isMoving = true;
      } else if (dragDistance < -tileWidth ~/ 2) {
        moveLeft(index);
        isMoving = true;
      }

      if (isMoving) {
        animationDuration.value = const Duration(milliseconds: 0);
      } else {
        animationDuration.value = const Duration(milliseconds: 100);
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
      if (checkSolved()) {
        // disable movement
        isMovingHorizontally.add(-1);
        isMovingVertically.add(-1);
        solved = true;
        updateAllTiles();
        Get.defaultDialog(
          title: 'solved!',
          middleText: '',
          onConfirm: () => Get.offAll(const HomePage()),
        );
      }
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

  bool checkSolved() {
    for (int i = 0; i < rowCount * rowCount; i++) {
      if (i != tilePositions[i]) {
        return false;
      }
    }

    return true;
  }

  void updateAllTiles() {
    for (int i = 0; i < rowCount * rowCount; i++) {
      update(['tile$i']);
    }
  }

  showPause() {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Paused',
                style: Get.textTheme.headline4?.copyWith(color: Colors.white),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  )),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    Get.back();
                    onInit();
                    updateAllTiles();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Restart',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  )),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => const HomePage(),
                        transition: Transition.fadeIn);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black87,
    );
  }
}
