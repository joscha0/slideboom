import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slideboom/shared/app_controller.dart';
import 'package:slideboom/shared/app_pages.dart';
import 'package:slideboom/shared/functions.dart';
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

  RxBool muted = false.obs;

  bool get isDarkTheme => Get.find<AppController>().isDarkMode.value;

  @override
  void onInit() {
    Map mode = getMode();
    muted.value = getMuted();
    dropDownValue.value = mode['mode'];
    checkboxValue.value = mode['bombs'];
    loadScores();
    super.onInit();
  }

  void onChanged(String? value) {
    dropDownValue.value = value ?? '4x4';
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
    changeCheckbox(!checkboxValue.value);
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
        'moves': score['moves'],
        'startPosition': score['startPosition'],
        'bombIndex': score['bombIndex'],
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

  void switchTheme() {
    Get.find<AppController>().switchTheme();
  }

  void openScoreDialog(int index) {
    Map score = scores[index];
    int rowCount = 0;
    double tileWidth = 0;
    if (score['startPosition'] != null) {
      rowCount = sqrt(score['startPosition'].length).toInt();
      tileWidth = getTileWidth(rowCount);
    }
    Get.dialog(AlertDialog(
        title: Text(
          '#${index + 1}',
          textAlign: TextAlign.center,
          style: Get.textTheme.headline4,
        ),
        scrollable: true,
        content: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "time: ",
                    style: Get.textTheme.bodyText1,
                  ),
                  Text(
                    score['time'],
                    style: Get.textTheme.headline5,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "moves: ",
                    style: Get.textTheme.bodyText1,
                  ),
                  Text(
                    score['moves'].toString(),
                    style: Get.textTheme.headline5,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "date: ",
                    style: Get.textTheme.bodyText1,
                  ),
                  Text(
                    score['date'],
                    style: Get.textTheme.bodyText2,
                  ),
                ],
              ),
              if (score['startPosition'] != null) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "starting position:",
                    style: Get.textTheme.bodyText1,
                  ),
                ),
                Center(
                  child: Container(
                    height: tileWidth * rowCount * 0.6,
                    width: tileWidth * rowCount * 0.6,
                    // constraints: BoxConstraints(maxHeight: 150, maxWidth: 150),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowCount),
                      itemCount: score['startPosition'].length,
                      itemBuilder: (context, i) {
                        Color color = getColor(
                            score['startPosition'][i], rowCount, false);
                        return Container(
                          color: color,
                          child: Center(
                            child: score['bombIndex'] == i
                                ? Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child:
                                        Image.asset('assets/bomb/bomb_0.png'),
                                  )
                                : Text(
                                    (score['startPosition'][i] + 1).toString(),
                                    style: TextStyle(
                                      fontSize: tileWidth * 0.4,
                                      color: color.computeLuminance() < 0.5
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        )));
  }

  void toggleMute() {
    muted.value = !muted.value;
    setMuted(muted.value);
  }
}
