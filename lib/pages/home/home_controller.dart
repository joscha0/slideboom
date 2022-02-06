import 'package:get/get.dart';
import 'package:slideboom/shared/app_pages.dart';
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

  void loadScores() {
    scores.value = [];
    List allScores = getScores(dropDownValue.value, checkboxValue.value);
    allScores.sort((a, b) => a['time'].compareTo(b['time']));
    for (Map score in allScores) {
      score = {
        'date': score['date'].substring(0, 19),
        'time': "${score['time'] ~/ 100} : " +
            (score['time'] % 100).toString().padLeft(2, '0'),
      };
      scores.add(score);
    }
  }

  void saveMode() {
    setMode(dropDownValue.value, checkboxValue.value);
  }

  void openGithub() async {
    // await launch(githubUrl);
  }
}
