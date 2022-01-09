import 'package:fixmymaze/pages/game/game_page.dart';
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
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: double.infinity,
            ),
            Text(
              'fix my maze',
              style: Get.textTheme.headline3,
            ),
            ElevatedButton(
                onPressed: () {
                  Get.to(const GamePage());
                },
                child: const Text('play'))
          ],
        )));
  }
}
