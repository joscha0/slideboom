import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import 'package:slideboom/shared/app_controller.dart';
import 'package:slideboom/shared/app_pages.dart';
import 'package:slideboom/shared/constants.dart';
import 'package:slideboom/shared/functions.dart';
import 'package:slideboom/shared/helpDialog.dart';
import 'package:slideboom/shared/widgets.dart';
import 'package:slideboom/storage/storage.dart';
import 'package:yoda/yoda.dart';
import 'package:share_plus/share_plus.dart';

class GameController extends GetxController
    with GetSingleTickerProviderStateMixin {
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
  Map<int, int> startPosition = {};

  double dragDistance = 0;

  double tileWidth = 100;

  int rowCount = 3;
  bool bombEnabled = false;

  List isMovingVertically = [];
  List isMovingHorizontally = [];

  Rx<Duration> animationDuration = const Duration(milliseconds: 0).obs;

  Rx<Duration> timerElapsed = Duration.zero.obs;
  Duration _offset = Duration.zero;
  late final Ticker _ticker;

  String colorMode = 'color';

  bool bordersEnabled = false; // 'gray', 'color', 'white'

  bool solved = false;
  RxBool isEnded = false.obs;

  RxInt selectedIndex = (-1).obs;

  RxInt moves = 0.obs;

  late YodaController yodaControllerExplode;
  Rx<Offset> offsetExplosion = const Offset(0.5, 0.5).obs;

  // late Timer timer;
  late Timer bombTimer;
  late Timer explosionTimer;

  AudioPlayer audioPlayer = AudioPlayer();
  RxBool muted = false.obs;

  bool get isDarkTheme => Get.find<AppController>().isDarkMode.value;

  @override
  void onInit() {
    precacheImages();
    setArgumentValues();
    tileWidth = getTileWidth(rowCount);
    setPositions();
    startTimer();
    offsetExplosion.value = getOffsetExplosion();
    super.onInit();
    yodaControllerExplode = YodaController()
      ..addStatusListener((status, context) {
        if (status == AnimationStatus.completed) {
          showBombExploded();
        }
      });
  }

  void precacheImages() {
    for (int i = 0; i <= 3; i++) {
      precacheImage(AssetImage('assets/bomb/bomb_$i.png'), Get.context!);
    }
    for (int i = 0; i <= 8; i++) {
      precacheImage(
          AssetImage('assets/explosion/explosion_$i.png'), Get.context!);
    }
  }

  void startTimer() {
    _ticker = createTicker((elapsed) {
      timerElapsed.value = _offset + elapsed;
    });
    _ticker.start();
  }

  void pauseTimer() {
    _ticker.stop();
    _offset = timerElapsed.value;
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

    timerElapsed.value = Duration.zero;
    _offset = Duration.zero;

    selectedIndex.value = -1;

    moves.value = 0;

    setArgumentValues();
    tileWidth = getTileWidth(rowCount);
    setPositions();

    updateAllTiles();
    _ticker.start();
    yodaControllerExplode.reset();
    offsetExplosion.value = getOffsetExplosion();
  }

  void setArgumentValues() {
    try {
      rowCount = Get.arguments['rowCount'];
      bombEnabled = Get.arguments['bombEnabled'];
    } catch (_) {
      // if user accesses /game page directly (e.g. web)
      Map mode = getMode();
      rowCount = int.parse(mode['mode'].split('x')[0]);
      bombEnabled = mode['bombs'];
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
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
    List<int> valueOptions =
        List.generate(rowCount * rowCount, (index) => index);
    startPosition = Map.fromIterables(valueOptions, valueOptions);
    shuffleStartingPosition();
    tilePositions.value = {...startPosition};
  }

  void shuffleStartingPosition() {
    // set bomb position
    if (bombEnabled) {
      bombIndex = Random().nextInt(rowCount * rowCount);
      if (rowCount == 3 && bombIndex == 4) {
        shuffleStartingPosition();
      }
    }
    // make a random move (up, down, left, right) at each tile;
    for (int i = 0; i < rowCount * rowCount; i++) {
      Map<int, int> backUpPos = Map.from(startPosition);
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
  
  Keyboard control
  
  */

  void keyMoveIndex(Direction dir) {
    int oldSelected = selectedIndex.value;
    if (selectedIndex.value == -1) {
      selectedIndex.value = 0;
    } else {
      switch (dir) {
        case Direction.UP:
          if (selectedIndex.value ~/ rowCount == 0) {
            selectedIndex.value =
                selectedIndex.value + rowCount * (rowCount - 1);
          } else {
            selectedIndex.value = selectedIndex.value - rowCount;
          }
          break;
        case Direction.DOWN:
          if (selectedIndex.value ~/ rowCount == rowCount - 1) {
            selectedIndex.value =
                selectedIndex.value - rowCount * (rowCount - 1);
          } else {
            selectedIndex.value = selectedIndex.value + rowCount;
          }
          break;
        case Direction.LEFT:
          if (selectedIndex.value % rowCount == 0) {
            selectedIndex.value = selectedIndex.value + (rowCount - 1);
          } else {
            selectedIndex.value = selectedIndex.value - 1;
          }
          break;
        case Direction.RIGHT:
          if (selectedIndex.value % rowCount == rowCount - 1) {
            selectedIndex.value = selectedIndex.value - (rowCount - 1);
          } else {
            selectedIndex.value = selectedIndex.value + 1;
          }
          break;
        default:
      }
    }
    update(['tile$oldSelected']);
    update(['tile${selectedIndex.value}']);
  }

  void keyMoveTiles(Direction dir) {
    if (selectedIndex.value != -1) {
      switch (dir) {
        case Direction.UP:
          if (isMovingHorizontally.isEmpty) {
            for (int i = 0; i < rowCount * rowCount; i++) {
              if (i % rowCount == selectedIndex.value % rowCount) {
                if (i == bombIndex) {
                  bombMoved();
                  return;
                }
              }
            }
            moveUp(selectedIndex.value);
            _moveVertical(false, selectedIndex.value);
          }
          break;
        case Direction.DOWN:
          if (isMovingHorizontally.isEmpty) {
            for (int i = 0; i < rowCount * rowCount; i++) {
              if (i % rowCount == selectedIndex.value % rowCount) {
                if (i == bombIndex) {
                  bombMoved();
                  return;
                }
              }
            }
            moveDown(selectedIndex.value);
            _moveVertical(false, selectedIndex.value);
          }
          break;
        case Direction.LEFT:
          if (isMovingVertically.isEmpty) {
            for (int i = 0; i < rowCount * rowCount; i++) {
              if (i ~/ rowCount == selectedIndex.value ~/ rowCount) {
                if (i == bombIndex) {
                  bombMoved();
                  return;
                }
              }
            }
            moveLeft(selectedIndex.value);
            _moveHorizontal(false, selectedIndex.value);
          }
          break;
        case Direction.RIGHT:
          if (isMovingVertically.isEmpty) {
            for (int i = 0; i < rowCount * rowCount; i++) {
              if (i ~/ rowCount == selectedIndex.value ~/ rowCount) {
                if (i == bombIndex) {
                  bombMoved();
                  return;
                }
              }
            }
            moveRight(selectedIndex.value);
            _moveHorizontal(false, selectedIndex.value);
          }
          break;
        default:
      }
      keyMoveIndex(dir);
    }
  }

  void removeSelectedIndex() {
    if (selectedIndex.value != -1) {
      int oldSelected = selectedIndex.value;
      selectedIndex.value = -1;
      update(['tile$oldSelected']);
    }
  }

  /*

  Move vertically
  
  */

  void onVerticalDragStart(DragStartDetails details, index) {
    if (isMovingHorizontally.isEmpty) {
      removeSelectedIndex();

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

      _moveVertical(isMoving, index);
    }
  }

  void _moveVertical(bool isMoving, int index) {
    playSlideSound();
    if (isMoving) {
      moves.value++;
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
      removeSelectedIndex();
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

      _moveHorizontal(isMoving, index);
    }
  }

  void playSlideSound() async {
    await audioPlayer.setAsset("assets/sounds/slide.mp3");
    await audioPlayer.play();
  }

  void _moveHorizontal(bool isMoving, int index) {
    playSlideSound();
    if (isMoving) {
      moves.value++;
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
    pauseTimer();
    Get.dialog(
      CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            Get.back();
            _ticker.start();
          },
        },
        child: Focus(
          autofocus: true,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Paused',
                    style:
                        Get.textTheme.headline4?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _ticker.start();
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
                  Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() => Tooltip(
                                message: muted.value ? "unmute" : "mute",
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    muted.value
                                        ? Icons.volume_off
                                        : Icons.volume_up,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => toggleMute(),
                                ),
                              )),
                          const Tooltip(
                            message: "help",
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.help,
                                size: 32,
                                color: Colors.white,
                              ),
                              onPressed: openHelp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black87,
    );
  }

  void playFuseSound() async {
    await audioPlayer.setAsset("assets/sounds/fuse.mp3");
    await audioPlayer.setLoopMode(LoopMode.one);
    await audioPlayer.play();
  }

  void bombMoved() {
    // disable movement
    isMovingHorizontally.add(-1);
    isMovingVertically.add(-1);
    isEnded.value = true;
    playFuseSound();
    bombTimer = Timer.periodic(const Duration(milliseconds: 120), (bombTimer) {
      bombImage.value += 1;
      update(['tile$bombIndex']);
      if (bombImage.value >= 3) {
        bombTimer.cancel();

        int count = 0;

        explosionTimer = Timer.periodic(const Duration(milliseconds: 100),
            (explosionTimer) async {
          if (count <= 2) {
            // wait a little until explosion
            count++;
            if (count == 2) {
              isExplosion.value = true;
              await audioPlayer.stop();
              await audioPlayer.setLoopMode(LoopMode.off);
              await audioPlayer.setAsset("assets/sounds/bomb.mp3");
              await audioPlayer.play();
              update(['explosion']);
            }
          } else {
            explosionImage.value += 1;

            update(['explosion']);
          }
          if (explosionImage.value == 1) {
            yodaControllerExplode.start();
          }
          if (explosionImage.value >= 8) {
            explosionTimer.cancel();
            _ticker.stop();
            isExplosion.value = false;
          }
        });
      }
    });
  }

  void showBombExploded() {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'bomb exploded!',
                style: Get.textTheme.headline4?.copyWith(color: Colors.white),
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

  void openFinished() {
    // game over puzzle solved
    _ticker.stop();
    // disable movement
    isMovingHorizontally.add(-1);
    isMovingVertically.add(-1);
    solved = true;
    updateAllTiles();
    bool isHighscore = addScore(
        rowCount,
        bombEnabled,
        timerElapsed.value.inMilliseconds,
        moves.value,
        startPosition.values.toList(),
        bombIndex);
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'solved!',
                style: Get.textTheme.headline3?.copyWith(color: Colors.white),
              ),
              Text(
                getTimeString(),
                style: Get.textTheme.headline4?.copyWith(color: Colors.white),
              ),
              Text(
                'with $moves moves',
                style: Get.textTheme.headline5?.copyWith(color: Colors.white),
              ),
              isHighscore
                  ? Text(
                      'New Highscore!',
                      style: Get.textTheme.headline4
                          ?.copyWith(color: Colors.white),
                    )
                  : Container(),
              ElevatedButton.icon(
                  onPressed: shareScore,
                  icon: const Icon(Icons.share),
                  label: const Text("share")),
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

  String getTimeString() {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(timerElapsed.value.inMinutes);
    String seconds = twoDigits(timerElapsed.value.inSeconds.remainder(60));
    String hundreds =
        twoDigits(timerElapsed.value.inMilliseconds.remainder(100));
    return "$minutes:$seconds:$hundreds";
  }

  void shareScore() {
    String modeString =
        "${rowCount}x$rowCount " + (bombEnabled ? "with" : "without") + " bomb";
    String timeString = getTimeString();
    Share.share(
        'I solved slideboom $modeString in $timeString with $moves moves can you beat me? check it out at https://slideboom.960.eu/#/home');
  }

  Offset getOffsetExplosion() {
    double dx = ((bombIndex) % rowCount) / rowCount + 1 / (rowCount * 2);
    double dy = ((bombIndex) ~/ rowCount) / rowCount + 1 / (rowCount * 2);
    return Offset(dx, dy);
  }

  void toggleMute() async {
    muted.value = !muted.value;
    if (muted.value) {
      await audioPlayer.setVolume(0);
    } else {
      await audioPlayer.setVolume(1);
    }
  }
}
