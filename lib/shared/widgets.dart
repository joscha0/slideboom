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
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 32),
      ),
      const Text(
        ":",
        style: TextStyle(fontSize: 32),
      ),
      sizedTimeText(seconds),
      const Text(
        ".",
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
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 32),
    ),
  );
}
