import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:slideboom/routes/app_pages.dart';

void main() async {
  await GetStorage.init();

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    builder: (context, widget) => ResponsiveWrapper.builder(
      ClampingScrollWrapper.builder(context, widget!),
      breakpoints: const [
        ResponsiveBreakpoint.resize(350, name: MOBILE),
        ResponsiveBreakpoint.autoScale(600, name: TABLET),
        ResponsiveBreakpoint.resize(800, name: DESKTOP),
        ResponsiveBreakpoint.autoScale(1700, name: 'XL'),
      ],
    ),
    theme: ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.indigo[100],
      textTheme: GoogleFonts.bungeeTextTheme(),
    ),
    getPages: AppPages.routes,
    initialRoute: AppPages.initial,
  ));
}
