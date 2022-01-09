import 'package:fixmymaze/pages/game/game_page.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxString dropDownValue = '3x3'.obs;

  Map<String, int> modes = {'2x2': 2, '3x3': 3, '4x4': 4, '5x5': 5};

  void onChanged(String? value) {
    dropDownValue.value = value ?? '3x3';
  }

  void startGame() {
    Get.to(const GamePage(), arguments: modes[dropDownValue.value]);
  }
}
