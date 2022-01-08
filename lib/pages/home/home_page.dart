import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HomePage')),
      body: Center(
        child: GridView.count(
          crossAxisCount: 3,
          children: [
            for (int i = 1; i <= 9; i++) Center(child: Text(i.toString())),
          ],
        ),
      ),
    );
  }
}
