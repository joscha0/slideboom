import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slideboom/shared/app_pages.dart';
import 'package:slideboom/shared/constants.dart';
import 'package:slideboom/storage/storage.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  RxString dropDownValue = '3x3'.obs;
  RxBool checkboxValue = false.obs;

  Map<String, int> modes = {
    '2x2': 2,
    '3x3': 3,
    '4x4': 4,
    '5x5': 5,
    '6x6': 6,
    '7x7': 7,
    '8x8': 8,
    '9x9': 9
  };

  RxList scores = [].obs;

  @override
  void onInit() {
    Map mode = getMode();
    dropDownValue.value = mode['mode'];
    checkboxValue.value = mode['bombs'];
    loadScores();
    super.onInit();
  }

  void onChanged(String? value) {
    dropDownValue.value = value ?? '4x4';
    if ((modes[value] ?? 4) < 4) {
      checkboxValue.value = false;
    }
    loadScores();
    saveMode();
  }

  void startGame() {
    Get.toNamed(
      Routes.game,
      arguments: {
        'bombEnabled': checkboxValue.value,
        'rowCount': modes[dropDownValue.value]
      },
    );
  }

  void changeCheckbox(bool? value) {
    checkboxValue.value = value ?? true;
    loadScores();
    saveMode();
  }

  void toggleBomb() {
    if ((modes[dropDownValue.value] ?? 0) > 3) {
      changeCheckbox(!checkboxValue.value);
    }
  }

  void increaseMode() {
    if (dropDownValue.value != modes.keys.last) {
      int newMode = modes[dropDownValue.value]! + 1;
      onChanged('${newMode}x$newMode');
    }
  }

  void decreaseMode() {
    if (dropDownValue.value != modes.keys.first) {
      int newMode = modes[dropDownValue.value]! - 1;
      onChanged('${newMode}x$newMode');
    }
  }

  void loadScores() {
    scores.value = [];
    List allScores = getScores(dropDownValue.value, checkboxValue.value);
    allScores.sort((a, b) => a['time'].compareTo(b['time']));
    for (Map score in allScores) {
      score = {
        'date': score['date'].substring(0, 19),
        'time': getTimeString(score['time']),
      };
      scores.add(score);
    }
  }

  String getTimeString(int time) {
    Duration dur = Duration(milliseconds: time);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(dur.inMinutes);
    String seconds = twoDigits(dur.inSeconds.remainder(60));
    String hundreds = twoDigits(dur.inMilliseconds.remainder(100));
    return "$minutes:$seconds:$hundreds";
  }

  void saveMode() {
    setMode(dropDownValue.value, checkboxValue.value);
  }

  void openGithub() async {
    await launch(githubUrl);
  }

  void openHelp() {
    Get.defaultDialog(
        title: 'Help',
        titleStyle: Get.textTheme.headline4,
        middleText: '',
        content: Column(
          children: [
            Text(
              'How to play?',
              style: Get.textTheme.headline5,
            ),
            const Text(
                'slide the tiles into numerical order.\nbe as fast as possible!\nIf you move a bomb you lose!'),
            const SizedBox(
              height: 15,
            ),
            Text(
              'Keyboard shortcuts',
              style: Get.textTheme.headline5,
            ),
            Text('on home screen:', style: Get.textTheme.headline6),
            const Text(
                '- p: play\n- m: increase mode\n- n: decrease mode\n- b: toggle bomb\n- ?: open help'),
            Text('in game:', style: Get.textTheme.headline6),
            const Text(
                '- escape: toggle pause\n- wasd: move selected\n- arrow keys: move tiles'),
          ],
        ));
  }
}
