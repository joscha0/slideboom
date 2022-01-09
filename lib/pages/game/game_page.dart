import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'game_controller.dart';

class GamePage extends GetView<GameController> {
  const GamePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => GameController());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Center(
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.black, width: 5)),
          width: controller.tileWidth * controller.rowCount + 10,
          height: controller.tileWidth * controller.rowCount + 10,
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
                if (i ~/ controller.rowCount == controller.rowCount - 1 ||
                    i ~/ controller.rowCount == 0) ...[
                  tile(
                    context,
                    i,
                    true,
                    false,
                    idStr: 'vtile$i',
                  ),
                ],
              ]
            ],
          ),
        ),
      ),
    );
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
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: c.getColor(index),
              ),
              child: Center(
                child: Text(
                  (c.tilePositions[index] + 1).toString(),
                  style: TextStyle(
                    fontSize: c.tileWidth * 0.7,
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
