import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class TimeText extends GetWidget {
//   RxString minutes = "00".obs, seconds = "00".obs, hundreds = "00".obs;

//   TimeText({Key? key, Duration elapsed = Duration.zero}) : super(key: key) {
//     minutes.value = twoDigits(elapsed.inMinutes);
//     seconds.value = twoDigits(elapsed.inSeconds.remainder(60));
//     hundreds.value = twoDigits(elapsed.inMilliseconds.remainder(100));
//   }

//   String twoDigits(int n) => n.toString().padLeft(2, "0");

//   @override
//   Widget build(BuildContext context) {
//     return Flex(
//       direction: Axis.horizontal,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           minutes.value,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 32),
//         ),
//         const Text(
//           ":",
//           style: TextStyle(fontSize: 32),
//         ),
//         sizedTimeText(seconds.value),
//         const Text(
//           ".",
//           style: TextStyle(fontSize: 32),
//         ),
//         sizedTimeText(hundreds.value),
//       ],
//     );
//   }

//   Widget sizedTimeText(String time) {
//     return SizedBox(
//       width: 50,
//       child: Text(
//         time,
//         textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 32),
//       ),
//     );
//   }
// }

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
