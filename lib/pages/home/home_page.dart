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
    final color = controller.randomColor;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      width: 150,
      height: 150,
      left: (index % 3) * 150,
      top: (index ~/ 3) * 150,
      child: GestureDetector(
        onVerticalDragStart: controller.onVerticalDragStart,
        onVerticalDragUpdate: controller.onVerticalDragUpdate,
        onVerticalDragEnd: controller.onVerticalDragEnd,
        onHorizontalDragStart: controller.onHorizontalDragStart,
        onHorizontalDragUpdate: controller.onHorizontalDragUpdate,
        onHorizontalDragEnd: controller.onHorizontalDragEnd,
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
  }
}
