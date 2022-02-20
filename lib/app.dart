import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            title: "slideboom",
            debugShowCheckedModeBanner: false,
            builder: (context, widget) => ResponsiveWrapper.builder(
              ClampingScrollWrapper.builder(context, widget!),
              breakpoints: const [
                ResponsiveBreakpoint.resize(350, name: MOBILE),
                ResponsiveBreakpoint.resize(600, name: TABLET),
                ResponsiveBreakpoint.resize(850, name: DESKTOP),
                ResponsiveBreakpoint.autoScale(1600, name: 'XL'),
              ],
            ),
            theme: ThemeData(
              appBarTheme: const AppBarTheme(
                shadowColor: Colors.transparent,
                color: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Color.fromARGB(255, 250, 250, 250),
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
              ),
              scaffoldBackgroundColor: const Color.fromARGB(255, 250, 250, 250),
              textTheme: GoogleFonts.dosisTextTheme(
                const TextTheme(
                  headline4: TextStyle(color: Colors.black),
                  bodyText1: TextStyle(color: Colors.black54),
                ),
              ),
            ),
            darkTheme: ThemeData(
              appBarTheme: const AppBarTheme(
                shadowColor: Colors.transparent,
                color: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.black,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              scaffoldBackgroundColor: Colors.black,
              unselectedWidgetColor: Colors.white70,
              canvasColor: Colors.grey[850],
              dividerColor: Colors.white24,
              hoverColor: Colors.white12,
              dialogBackgroundColor: Colors.grey[850],
              popupMenuTheme: PopupMenuThemeData(color: Colors.grey[850]),
              primarySwatch: Colors.blue,
              iconTheme: const IconThemeData(color: Colors.white),
              textTheme: GoogleFonts.dosisTextTheme(
                const TextTheme(
                  headline5: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                  headline4: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                  bodyText2: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                  headline6: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                  headline3: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                  bodyText1: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            themeMode: c.themeMode.value,
            getPages: AppPages.routes,
            initialRoute: AppPages.initial,
          );
        });
  }
}
