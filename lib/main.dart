import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/home/home_page.dart';

void main() async {
  await GetStorage.init();

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light().copyWith(
      textTheme: GoogleFonts.bungeeTextTheme(),
    ),
    home: const HomePage(),
  ));
}
