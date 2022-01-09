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
        child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final color = controller.randomColor;
              return GestureDetector(
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
              );
            }),
      ),
    );
  }
}
