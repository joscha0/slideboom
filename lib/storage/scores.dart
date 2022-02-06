import 'package:get_storage/get_storage.dart';

final box = GetStorage();

getScores(String mode, bool bombs) {
  String id = "scores-" + mode + (bombs ? "b" : "");
  List scores = box.read(id) ?? [];
  return scores;
}

addScore(int rowCount, bool bombs, int time) {
  // id: scores-4x4b
  String id = "scores-${rowCount}x$rowCount" + (bombs ? "b" : "");
  List scores = box.read(id) ?? [];
  int slowest = 0;
  if (scores.isNotEmpty) {
    slowest =
        scores.reduce((a, b) => a['time'] > b['time'] ? a['time'] : b['time']);
  }
  if (scores.length < 10) {
    _saveScore(id, time, scores);
  } else if (slowest > time) {
    scores.removeWhere((score) => score == slowest);
    _saveScore(id, time, scores);
  }
}

_saveScore(String id, int time, List scores) {
  DateTime now = DateTime.now();
  scores.add({
    'date': now.toString(),
    'time': time,
  });
  box.write(id, scores);
}
