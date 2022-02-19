import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:slideboom/shared/functions.dart';
import 'package:slideboom/shared/constants.dart';
import 'package:slideboom/shared/helpDialog.dart';
import 'package:slideboom/shared/widgets.dart';
import 'package:yoda/yoda.dart';

import 'game_controller.dart';

class GamePage extends GetView<GameController> {
  const GamePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            controller.showPause(),
        const SingleActivator(LogicalKeyboardKey.keyW): () =>
            controller.keyMoveIndex(Direction.UP),
        const SingleActivator(LogicalKeyboardKey.keyS): () =>
            controller.keyMoveIndex(Direction.DOWN),
        const SingleActivator(LogicalKeyboardKey.keyA): () =>
            controller.keyMoveIndex(Direction.LEFT),
        const SingleActivator(LogicalKeyboardKey.keyD): () =>
            controller.keyMoveIndex(Direction.RIGHT),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            controller.keyMoveTiles(Direction.UP),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            controller.keyMoveTiles(Direction.DOWN),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            controller.keyMoveTiles(Direction.LEFT),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            controller.keyMoveTiles(Direction.RIGHT),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
          ),
          body: Center(
            child: ResponsiveRowColumn(
              columnMainAxisAlignment: MainAxisAlignment.center,
              rowMainAxisAlignment: MainAxisAlignment.spaceEvenly,
              layout: ResponsiveWrapper.of(context).orientation ==
                      Orientation.landscape
                  ? ResponsiveRowColumnType.ROW
                  : ResponsiveRowColumnType.COLUMN,
              children: [
                ResponsiveRowColumnItem(
                  child: SizedBox(
                    height: 120,
                    width: 250,
                    child: Obx(() {
                      return controller.isEnded.value
                          ? Container()
                          : Column(
                              children: [
                                Tooltip(
                                  message: "pause",
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.pause,
                                      size: 32,
                                    ),
                                    onPressed: () => controller.showPause(),
                                  ),
                                ),
                                timeText(
                                    elapsed: controller.timerElapsed.value),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text("moves: ${controller.moves}"),
                                ),
                              ],
                            );
                    }),
                  ),
                ),
                ResponsiveRowColumnItem(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (controller.bombIndex != -1) ...[
                        bombExplosion(),
                      ],
                      Obx(() {
                        return Yoda(
                          yodaEffect: YodaEffect.Explosion,
                          controller: controller.yodaControllerExplode,
                          duration: const Duration(milliseconds: 2500),
                          animParameters: AnimParameters(
                            fractionalCenter: controller.offsetExplosion.value,
                            hTiles: 20,
                            vTiles: 20,
                            effectPower: 0.5 - (controller.rowCount * 0.04),
                            blurPower: 5,
                            gravity: 0.1,
                            randomness: 30,
                          ),
                          startWhenTapped: false,
                          child: Container(
                            decoration: controller.bordersEnabled
                                ? BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 5))
                                : const BoxDecoration(),
                            width: controller.tileWidth * controller.rowCount +
                                (controller.bordersEnabled ? 10 : 0),
                            height: controller.tileWidth * controller.rowCount +
                                (controller.bordersEnabled ? 10 : 0),
                            child: Stack(
                              children: [
                                for (int i = 0;
                                    i <
                                        controller.rowCount *
                                            controller.rowCount;
                                    i++) ...[
                                  tile(context, i, false, false),

                                  // add horizontal overflow tiles
                                  if ((i + 1) % controller.rowCount == 1 ||
                                      (i + 1) % controller.rowCount == 0) ...[
                                    tile(
                                      context,
                                      i,
                                      true,
                                      true,
                                      idStr: 'htile$i',
                                    ),
                                  ],

                                  // add vertical overflow tiles
                                  if (i ~/ controller.rowCount ==
                                          controller.rowCount - 1 ||
                                      i ~/ controller.rowCount == 0) ...[
                                    tile(
                                      context,
                                      i,
                                      true,
                                      false,
                                      idStr: 'vtile$i',
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                      // add bomb explosion
                    ],
                  ),
                ),
                if (ResponsiveWrapper.of(context).isLargerThan(TABLET) &&
                    ResponsiveWrapper.of(context).orientation ==
                        Orientation.landscape) ...[
                  const ResponsiveRowColumnItem(
                    child: SizedBox(
                      height: 120,
                      width: 250,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bombExplosion() {
    return GetBuilder<GameController>(
        id: 'explosion',
        init: GameController(),
        builder: (c) {
          return Visibility(
            visible: c.isExplosion.value,
            child: Positioned(
                width: c.tileWidth * 2,
                height: c.tileWidth * 2,
                left: c.positions[c.bombIndex][0] - 0.5 * c.tileWidth,
                top: c.positions[c.bombIndex][1] - 0.5 * c.tileWidth,
                child: Image.asset(
                    'assets/explosion/explosion_${c.explosionImage.value}.png')),
          );
        });
  }

  Widget tile(context, int index, bool isOtile, bool isHtile, {String? idStr}) {
    /// [isOtile]: tile is overflow tile
    return GetBuilder<GameController>(
      id: idStr ?? 'tile$index',
      init: GameController(),
      builder: (c) {
        Color color = getColor(
          c.tilePositions[index],
          c.rowCount,
          c.solved,
        );
        return AnimatedPositioned(
          duration: c.animationDuration.value,
          width: c.tileWidth,
          height: c.tileWidth,
          left: isOtile
              ? isHtile
                  ? controller.hPositions[index][0]
                  : controller.vPositions[index][0]
              : c.positions[index][0],
          top: isOtile
              ? isHtile
                  ? controller.hPositions[index][1]
                  : controller.vPositions[index][1]
              : c.positions[index][1],
          child: GestureDetector(
            onVerticalDragStart: (details) =>
                c.onVerticalDragStart(details, index),
            onVerticalDragUpdate: (details) =>
                c.onVerticalDragUpdate(details, index),
            onVerticalDragEnd: (details) => c.onVerticalDragEnd(details, index),
            onHorizontalDragStart: (details) =>
                c.onHorizontalDragStart(details, index),
            onHorizontalDragUpdate: (details) =>
                c.onHorizontalDragUpdate(details, index),
            onHorizontalDragEnd: (details) =>
                c.onHorizontalDragEnd(details, index),
            child: Container(
              decoration: index == c.selectedIndex.value
                  ? BoxDecoration(
                      border: Border.all(
                        color: c.isDarkTheme ? Colors.white : Colors.black,
                        width: c.tileWidth * 0.08,
                      ),
                      color: color,
                    )
                  : c.bordersEnabled
                      ? BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: color,
                        )
                      : BoxDecoration(color: color),
              child: Center(
                child: c.isBombPosition(index)
                    ? Image.asset('assets/bomb/bomb_${c.bombImage.value}.png')
                    : Text(
                        (c.tilePositions[index] + 1).toString(),
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontSize: index == c.selectedIndex.value
                              ? c.tileWidth * 0.5
                              : c.tileWidth * 0.6,
                          color: color.computeLuminance() < 0.5
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
