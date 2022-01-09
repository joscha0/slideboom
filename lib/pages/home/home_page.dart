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
            child: GetX<HomeController>(
                init: HomeController(),
                builder: (c) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: double.infinity,
                      ),
                      Text(
                        'fix my maze',
                        style: Get.textTheme.headline3,
                      ),
                      DropdownButton(
                          value: c.dropDownValue.value,
                          style: Get.textTheme.headline5,
                          items: c.modes.keys
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: c.onChanged),
                      ElevatedButton(
                          onPressed: c.startGame, child: const Text('play'))
                    ],
                  );
                })));
  }
}
