import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:slideboom/shared/app_controller.dart';
import 'package:slideboom/shared/app_pages.dart';

class MyApp extends GetView<AppController> {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<AppController>(
        init: AppController(),
        builder: (c) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, widget) => ResponsiveWrapper.builder(
              ClampingScrollWrapper.builder(context, widget!),
              breakpoints: const [
                ResponsiveBreakpoint.resize(350, name: MOBILE),
                ResponsiveBreakpoint.autoScale(600, name: TABLET),
                ResponsiveBreakpoint.resize(850, name: DESKTOP),
                ResponsiveBreakpoint.autoScale(1600, name: 'XL'),
              ],
            ),
            theme: ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color.fromARGB(255, 250, 250, 250),
              textTheme: GoogleFonts.bungeeTextTheme(),
            ),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black,
              textTheme: GoogleFonts.bungeeTextTheme(),
            ),
            themeMode: c.themeMode.value,
            getPages: AppPages.routes,
            initialRoute: AppPages.initial,
          );
        });
  }
}
