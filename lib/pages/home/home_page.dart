import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Center(
        child: SizedBox(
          width: 450,
          height: 450,
          child: Stack(
            children: [for (int i = 0; i < 9; i++) tile(context, i)],
          ),
        ),
      ),
    );
  }

  Widget tile(context, index) {
    final color = Colors.primaries[index * 2];
    return GetBuilder<HomeController>(
      id: 'tile$index',
      init: HomeController(),
      builder: (c) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          width: 150,
          height: 150,
          left: c.positions[index][0],
          top: c.positions[index][1],
          child: GestureDetector(
            onVerticalDragStart: c.onVerticalDragStart,
            onVerticalDragUpdate: (details) =>
                c.onVerticalDragUpdate(details, index),
            onVerticalDragEnd: (details) => c.onVerticalDragEnd(details, index),
            onHorizontalDragStart: c.onHorizontalDragStart,
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
