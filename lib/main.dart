import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:slideboom/app.dart';

void main() async {
  await GetStorage.init();

  runApp(const MyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(854, 480);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "flutter";
    win.show();
  });
}
