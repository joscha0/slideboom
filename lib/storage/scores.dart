import 'package:get_storage/get_storage.dart';
import 'dart:math';

final box = GetStorage();

getScores(String mode, bool bombs) {
  String id = "scores-" + mode + (bombs ? "b" : "");
  Map scores = box.read(id) ?? {};
  return scores;
}

addScore(int rowCount, bool bombs, int time) {
  // id: scores-4x4b
  String id = "scores-${rowCount}x$rowCount" + (bombs ? "b" : "");
  Map<DateTime, int> scores = box.read(id) ?? {};
  int slowest = time;
  if (scores.isNotEmpty) {
    slowest = scores.values.toList().reduce(max);
  }
  if (scores.length < 10) {
    DateTime now = DateTime.now();
    scores[now] = time;
    box.write(id, scores);
  } else if (slowest > time) {
    scores.removeWhere((key, value) => value == slowest);
    DateTime now = DateTime.now();
    scores[now] = time;
    box.write(id, scores);
  }
}
