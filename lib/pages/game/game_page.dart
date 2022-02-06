import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'game_controller.dart';

class GamePage extends GetView<GameController> {
  const GamePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            controller.showPause(),
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
              layout: (ResponsiveWrapper.of(context).isSmallerThan(DESKTOP) &&
                      ResponsiveWrapper.of(context).orientation ==
                          Orientation.landscape)
                  ? ResponsiveRowColumnType.ROW
                  : ResponsiveRowColumnType.COLUMN,
              children: [
                ResponsiveRowColumnItem(
                  child: SizedBox(
                    height: 120,
                    child: Obx(() {
                      return controller.isEnded.value
                          ? Container()
                          : Column(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.pause,
                                    size: 32,
                                  ),
                                  onPressed: () => controller.showPause(),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        '${controller.timePassed.value ~/ 100}',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 48),
                                      ),
                                    ),
                                    const Text(
                                      ' : ',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 48),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        (controller.timePassed.value % 100)
                                            .toString()
                                            .padLeft(2, '0'),
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 48),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                    }),
                  ),
                ),
                ResponsiveRowColumnItem(
                  child: Container(
                    decoration: controller.bordersEnabled
                        ? BoxDecoration(
                            border: Border.all(color: Colors.black, width: 5))
                        : const BoxDecoration(),
                    width: controller.tileWidth * controller.rowCount +
                        (controller.bordersEnabled ? 10 : 0),
                    height: controller.tileWidth * controller.rowCount +
                        (controller.bordersEnabled ? 10 : 0),
                    child: Stack(
                      children: [
                        for (int i = 0;
                            i < controller.rowCount * controller.rowCount;
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
                        // add bomb explosion
                        if (controller.bombIndex != -1) ...[
                          bombExplosion(),
                        ],
                      ],
                    ),
                  ),
                ),
                if (ResponsiveWrapper.of(context).isLargerThan(TABLET) &&
                    ResponsiveWrapper.of(context).orientation ==
                        Orientation.landscape) ...[
                  const ResponsiveRowColumnItem(
                    child: SizedBox(
                      height: 120,
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
              decoration: c.bordersEnabled
                  ? BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: c.getColor(index),
                    )
                  : BoxDecoration(
                      color: c.getColor(index),
                    ),
              child: Center(
                child: c.isBombPosition(index)
                    ? Image.asset('assets/bomb/bomb_${c.bombImage.value}.png')
                    : Text(
                        (c.tilePositions[index] + 1).toString(),
                        style: TextStyle(
                          fontSize: c.tileWidth * 0.6,
                          color: c.getColor(index).computeLuminance() < 0.5
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
