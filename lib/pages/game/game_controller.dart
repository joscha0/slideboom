import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slideboom/routes/app_pages.dart';
import 'package:slideboom/storage/storage.dart';

class GameController extends GetxController {
  RxList positions = [].obs;
  // horizontal overflow tiles
  RxList hPositions = [].obs;
  // vertical overflow tiles
  RxList vPositions = [].obs;

  int bombIndex = -1;

  RxInt bombImage = 0.obs;

  RxInt explosionImage = 0.obs;
  RxBool isExplosion = false.obs;

  // saved tile positions
  RxMap tilePositions = {}.obs;
  Map startPosition = {};

  double dragDistance = 0;

  double tileWidth = 100;

  int rowCount = 3;
  bool bombEnabled = false;

  List isMovingVertically = [];
  List isMovingHorizontally = [];

  Rx<Duration> animationDuration = const Duration(milliseconds: 0).obs;

  String colorMode = 'color';

  bool bordersEnabled = false; // 'gray', 'color', 'white'

  bool solved = false;
  RxBool isEnded = false.obs;

  late Timer timer;
  late Timer bombTimer;
  late Timer explosionTimer;

  RxInt timePassed = 0.obs;

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
    rowCount = Get.arguments['rowCount'];
    bombEnabled = Get.arguments['bombEnabled'];
    setTileWidth();
    setPositions();
    startTimer();
    super.onInit();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      timePassed.value++;
    });
  }

  void restart() {
    Get.back();
    // set default values
    positions.value = [];
    hPositions.value = [];
    vPositions.value = [];

    bombIndex = -1;

    bombImage.value = 0;

    explosionImage.value = 0;
    isExplosion.value = false;

    tilePositions.value = {};

    dragDistance = 0;

    tileWidth = 100;

    rowCount = 3;

    isMovingVertically = [];
    isMovingHorizontally = [];

    animationDuration.value = const Duration(milliseconds: 0);

    colorMode = 'color';

    bordersEnabled = false;

    solved = false;
    isEnded.value = false;

    timePassed.value = 0;

    rowCount = Get.arguments['rowCount'];
    bombEnabled = Get.arguments['bombEnabled'];
    setTileWidth();
    setPositions();

    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      timePassed.value++;
    });
    updateAllTiles();
  }

  @override
  void onClose() {
    // bombTimer.cancel();
    // explosionTimer.cancel();
    timer.cancel();
    super.onClose();
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
    List valueOptions = List.generate(rowCount * rowCount, (index) => index);
    startPosition = Map.fromIterables(valueOptions, valueOptions);
    shuffleStartingPosition();
    tilePositions.value = startPosition;
  }

  void shuffleStartingPosition() {
    // set bomb position
    if (bombEnabled) {
      bombIndex = Random().nextInt(rowCount * rowCount);
    }
    // make a random move (up, down, left, right) at each tile;
    for (int i = 0; i < rowCount * rowCount; i++) {
      Map backUpPos = Map.from(startPosition);
      List moves = [moveUp, moveDown, moveLeft, moveRight];
      moves[Random().nextInt(moves.length)](i, isStart: true);
      // if bomb would explode skip that step
      if (bombEnabled && startPosition[bombIndex] != bombIndex) {
        startPosition = backUpPos;
      }
    }

    // if more than 50% of positions are the same reshuffle
    int sameIndexCount = 0;
    for (int i = 0; i < rowCount * rowCount; i++) {
      if (i == startPosition[i]) {
        sameIndexCount++;
      }
    }
    print(startPosition);

    if (sameIndexCount > (rowCount * rowCount / 2)) {
      shuffleStartingPosition();
    }
  }

  bool isBombPosition(index) {
    if (bombIndex == -1) {
      return false;
    } else {
      return bombIndex == index;
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
          if (i == bombIndex) {
            bombMoved();
          }
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
        openFinished();
      }
    }
  }

  List getColumn(index, isStart) {
    List<int> tiles = [];
    Map tilePos = {};
    for (int i = 0; i < rowCount * rowCount; i++) {
      if (i % rowCount == index % rowCount) {
        tiles.add(i);
        if (isStart) {
          tilePos[i] = startPosition[i];
        } else {
          tilePos[i] = tilePositions[i];
        }
      }
    }
    return [tiles, tilePos];
  }

  void moveUp(index, {isStart = false}) {
    // get column indexes
    List column = getColumn(index, isStart);
    List<int> tiles = column[0];
    Map tilePos = column[1];

    // update tiles
    for (int i = 0; i < tiles.length; i++) {
      if (i == tiles.length - 1) {
        if (isStart) {
          startPosition[tiles[i]] = tilePos[tiles.first];
        } else {
          tilePositions[tiles[i]] = tilePos[tiles.first];
        }
      } else {
        if (isStart) {
          startPosition[tiles[i]] = tilePos[tiles[i + 1]];
        } else {
          tilePositions[tiles[i]] = tilePos[tiles[i + 1]];
        }
      }
    }
  }

  void moveDown(index, {isStart = false}) {
    // get column indexes
    List column = getColumn(index, isStart);
    List<int> tiles = column[0];
    Map tilePos = column[1];
    // update tiles
    for (int i = 0; i < tiles.length; i++) {
      if (i == 0) {
        if (isStart) {
          startPosition[tiles[i]] = tilePos[tiles.last];
        } else {
          tilePositions[tiles[i]] = tilePos[tiles.last];
        }
      } else {
        if (isStart) {
          startPosition[tiles[i]] = tilePos[tiles[i - 1]];
        } else {
          tilePositions[tiles[i]] = tilePos[tiles[i - 1]];
        }
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
          if (i == bombIndex) {
            bombMoved();
          }
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
        openFinished();
      }
    }
  }

  List getRow(index, isStart) {
    List<int> tiles = [];
    Map tilePos = {};
    for (int i = 0; i < rowCount * rowCount; i++) {
      if (i ~/ rowCount == index ~/ rowCount) {
        tiles.add(i);
        if (isStart) {
          tilePos[i] = startPosition[i];
        } else {
          tilePos[i] = tilePositions[i];
        }
      }
    }
    return [tiles, tilePos];
  }

  void moveLeft(index, {isStart = false}) {
    // get row indexes
    List row = getRow(index, isStart);
    List<int> tiles = row[0];
    Map tilePos = row[1];

    // update tiles
    for (int i = 0; i < tiles.length; i++) {
      if (i == tiles.length - 1) {
        if (isStart) {
          startPosition[tiles[i]] = tilePos[tiles.first];
        } else {
          tilePositions[tiles[i]] = tilePos[tiles.first];
        }
      } else {
        if (isStart) {
          startPosition[tiles[i]] = tilePos[tiles[i + 1]];
        } else {
          tilePositions[tiles[i]] = tilePos[tiles[i + 1]];
        }
      }
    }
  }

  void moveRight(index, {isStart = false}) {
    // get row indexes
    List row = getRow(index, isStart);
    List<int> tiles = row[0];
    Map tilePos = row[1];

    // update tiles
    for (int i = 0; i < tiles.length; i++) {
      if (i == 0) {
        if (isStart) {
          startPosition[tiles[i]] = tilePos[tiles.last];
        } else {
          tilePositions[tiles[i]] = tilePos[tiles.last];
        }
      } else {
        if (isStart) {
          startPosition[tiles[i]] = tilePos[tiles[i - 1]];
        } else {
          tilePositions[tiles[i]] = tilePos[tiles[i - 1]];
        }
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
      update(['htile$i']);
      update(['vtile$i']);
    }
  }

  showPause() {
    timer.cancel();
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
                    startTimer();
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
                  onPressed: restart,
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
                    Get.offAllNamed(Routes.home);
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

  void bombMoved() {
    // disable movement
    isMovingHorizontally.add(-1);
    isMovingVertically.add(-1);
    isEnded.value = true;
    bombTimer = Timer.periodic(const Duration(milliseconds: 200), (bombTimer) {
      bombImage.value += 1;
      update(['tile$bombIndex']);
      if (bombImage.value >= 3) {
        bombTimer.cancel();

        int count = 0;
        explosionTimer =
            Timer.periodic(const Duration(milliseconds: 150), (explosionTimer) {
          if (count <= 3) {
            count++;
            if (count == 3) {
              isExplosion.value = true;
              update(['explosion']);
            }
          } else {
            explosionImage.value += 1;

            update(['explosion']);
          }
          if (explosionImage.value >= 8) {
            explosionTimer.cancel();
            timer.cancel();
            isExplosion.value = false;
            Get.dialog(
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'bomb exploded!',
                        style: Get.textTheme.headline4
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: restart,
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
                            Get.offAllNamed(Routes.home);
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
              barrierColor: const Color.fromRGBO(230, 50, 17, 0.95),
            );
          }
        });
      }
    });
  }

  void openFinished() {
    // game over puzzle solved
    timer.cancel();
    // disable movement
    isMovingHorizontally.add(-1);
    isMovingVertically.add(-1);
    solved = true;
    updateAllTiles();
    bool isHighscore = addScore(rowCount, bombEnabled, timePassed.value);
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'solved!',
                style: Get.textTheme.headline4?.copyWith(color: Colors.white),
              ),
              isHighscore
                  ? Text(
                      'New Highscore!',
                      style: Get.textTheme.headline4
                          ?.copyWith(color: Colors.white),
                    )
                  : Container(),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: restart,
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
                    Get.offAllNamed(Routes.home);
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
      barrierColor: const Color.fromRGBO(5, 15, 5, 0.95),
    );
  }
}
