import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/game/game_page.dart';

void main() {
  runApp(const GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: GamePage(),
  ));
}
