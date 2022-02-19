import 'package:flutter/material.dart';
import 'package:get/get.dart';

void openHelp() {
  Get.dialog(AlertDialog(
      title: Text(
        'Help',
        textAlign: TextAlign.center,
        style: Get.textTheme.headline4,
      ),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to play?',
            style: Get.textTheme.headline5,
          ),
          Text(
            'slide the tiles into numerical order.\nbe as fast as possible!\nIf you move the bomb you lose!',
            style: Get.textTheme.bodyText1,
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'Keyboard shortcuts',
            style: Get.textTheme.headline5,
          ),
          Text('on home screen:', style: Get.textTheme.headline6),
          Text(
            '- p: play\n- m: increase mode\n- n: decrease mode\n- b: toggle bomb\n- ?: open help',
            style: Get.textTheme.bodyText1,
          ),
          Text('in game:', style: Get.textTheme.headline6),
          Text(
            '- escape: toggle pause\n- wasd: move selected\n- arrow keys: move tiles\n- vim keys (hjkl): move tiles',
            style: Get.textTheme.bodyText1,
          ),
        ],
      )));
}
