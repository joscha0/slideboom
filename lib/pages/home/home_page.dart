import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => HomeController());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Center(
        child: SizedBox(
          width: controller.tileWidth * 3,
          height: controller.tileWidth * 3,
          child: Stack(
            children: [
              for (int i = 0; i < 9; i++) ...[
                tile(context, i, false, false),

                // add horizontal overflow tiles
                if ((i + 1) % 3 == 1 || (i + 1) % 3 == 0) ...[
                  tile(
                    context,
                    i,
                    true,
                    true,
                    idStr: 'htile$i',
                  ),
                ],

                // add vertical overflow tiles
                if (i ~/ 3 == 3 - 1 || i ~/ 3 == 0) ...[
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
    final color = Colors.primaries[index * 2];
    return GetBuilder<HomeController>(
      id: idStr ?? 'tile$index',
      init: HomeController(),
      builder: (c) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
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
              color: color,
              child: Center(
                child: Text(
                  (index + 1).toString(),
                  style: TextStyle(
                    fontSize: 72,
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
