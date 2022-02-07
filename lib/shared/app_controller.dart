import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppController extends GetxController {
  final box = GetStorage();
  final _key = 'isDarkMode';

  RxBool isDarkMode = false.obs;
  Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  ElevatedButtonThemeData buttonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    ),
  );

  @override
  void onInit() {
    isDarkMode.value = box.read(_key) ?? ThemeMode.system == ThemeMode.dark;
    themeMode.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
    super.onInit();
  }

  void saveThemeMode(bool isDarkMode) => box.write(_key, isDarkMode);

  void switchTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.light : ThemeMode.dark);
    isDarkMode.value = !isDarkMode.value;
    saveThemeMode(isDarkMode.value);
  }
}
