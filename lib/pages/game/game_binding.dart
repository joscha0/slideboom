import 'package:get/get.dart';
import 'package:slideboom/pages/game/game_controller.dart';

class GameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameController>(() => GameController());
  }
}
