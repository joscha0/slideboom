import 'package:slideboom/pages/game/game_page.dart';
import 'package:get/get.dart';
import 'package:slideboom/storage/storage.dart';

class HomeController extends GetxController {
  RxString dropDownValue = '3x3'.obs;
  RxBool checkboxValue = false.obs;

  Map<String, int> modes = {
    '2x2': 2,
    '3x3': 3,
    '4x4': 4,
    '5x5': 5,
    '6x6': 6,
    '7x7': 7
  };

  RxList scores = [].obs;

  @override
  void onInit() {
    loadScores();
    super.onInit();
  }

  void onChanged(String? value) {
    dropDownValue.value = value ?? '4x4';
    if ((modes[value] ?? 4) < 4) {
      checkboxValue.value = false;
    }
    loadScores();
  }

  void startGame() {
    Get.to(() => const GamePage(),
        arguments: {
          'bombEnabled': checkboxValue.value,
          'rowCount': modes[dropDownValue.value]
        },
        transition: Transition.zoom);
  }

  void changeCheckbox(bool? value) {
    checkboxValue.value = value ?? true;
    loadScores();
  }

  void loadScores() {
    scores.value = [];
    List allScores = getScores(dropDownValue.value, checkboxValue.value);
    for (Map score in allScores) {
      score = {
        'date': score['date'].substring(0, 19),
        'time': "${score['time'] ~/ 100} : " +
            (score['time'] % 100).toString().padLeft(2, '0'),
      };
      scores.add(score);
    }
    scores.sort((a, b) => a['time'].compareTo(b['time']));
  }
}
