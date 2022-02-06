import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slideboom/routes/app_pages.dart';

void main() async {
  await GetStorage.init();

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light().copyWith(
      textTheme: GoogleFonts.bungeeTextTheme(),
    ),
    getPages: AppPages.routes,
    initialRoute: AppPages.initial,
  ));
}
