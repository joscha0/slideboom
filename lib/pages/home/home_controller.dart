import 'package:fixmymaze/pages/game/game_page.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxString dropDownValue = '3x3'.obs;
  RxBool checkboxValue = true.obs;

  Map<String, int> modes = {
    '2x2': 2,
    '3x3': 3,
    '4x4': 4,
    '5x5': 5,
    '6x6': 6,
    '7x7': 7
  };

  void onChanged(String? value) {
    dropDownValue.value = value ?? '4x4';
    if ((modes[value] ?? 4) < 4) {
      checkboxValue.value = false;
    }
  }

  void startGame() {
    Get.to(const GamePage(),
        arguments: modes[dropDownValue.value], transition: Transition.zoom);
  }

  void changeCheckbox(bool? value) {
    checkboxValue.value = value ?? true;
  }
}
