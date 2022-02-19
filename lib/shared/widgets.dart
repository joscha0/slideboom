import 'package:flutter/material.dart';

Widget timeText({Duration elapsed = Duration.zero}) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String minutes = twoDigits(elapsed.inMinutes);
  String seconds = twoDigits(elapsed.inSeconds.remainder(60));
  String hundreds = twoDigits(elapsed.inMilliseconds.remainder(100));
  return Flex(
    direction: Axis.horizontal,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        minutes,
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 32),
      ),
      const Text(
        ":",
        textScaleFactor: 1,
        style: TextStyle(fontSize: 32),
      ),
      sizedTimeText(seconds),
      const Text(
        ".",
        textScaleFactor: 1,
        style: TextStyle(fontSize: 32),
      ),
      sizedTimeText(hundreds),
    ],
  );
}

Widget sizedTimeText(String time) {
  return SizedBox(
    width: 50,
    child: Text(
      time,
      textScaleFactor: 1,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 32),
    ),
  );
}
