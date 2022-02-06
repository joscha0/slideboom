import 'package:get/route_manager.dart';
import 'package:slideboom/pages/game/game_binding.dart';
import 'package:slideboom/pages/game/game_page.dart';
import 'package:slideboom/pages/home/home_binding.dart';
import 'package:slideboom/pages/home/home_page.dart';
import 'package:slideboom/pages/settings/settings_binding.dart';
import 'package:slideboom/pages/settings/settings_page.dart';

abstract class Routes {
  static const home = '/home';
  static const game = '/game';
  static const settings = '/settings';
}

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.game,
      page: () => const GamePage(),
      binding: GameBinding(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
