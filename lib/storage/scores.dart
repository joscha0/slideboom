import 'package:get_storage/get_storage.dart';

final _box = GetStorage();

getScores(String mode, bool bombs) {
  String id = "scores-" + mode + (bombs ? "b" : "");
  List scores = _box.read(id) ?? [];
  return scores;
}

bool addScore(int rowCount, bool bombs, int time) {
  /// returns true if score is new highscore
  // id: scores-4x4b
  String id = "scores-${rowCount}x$rowCount" + (bombs ? "b" : "");
  List scores = _box.read(id) ?? [];
  Map slowest = {'time': 0};
  bool isHishscore = false;
  if (scores.length > 1) {
    slowest = scores.reduce((a, b) => a['time'] > b['time'] ? a : b);
    Map fastest = scores.reduce((a, b) => a['time'] < b['time'] ? a : b);
    if (fastest['time'] > time) {
      isHishscore = true;
    }
  } else if (scores.isNotEmpty) {
    if (scores[0]['time'] > time) {
      isHishscore = true;
    }
  } else {
    isHishscore = true;
  }

  if (scores.length < 10) {
    _saveScore(id, time, scores);
  } else if (slowest['time'] > time) {
    scores.removeWhere((score) => score == slowest);
    _saveScore(id, time, scores);
  }
  return isHishscore;
}

_saveScore(String id, int time, List scores) {
  DateTime now = DateTime.now();
  scores.add({
    'date': now.toString(),
    'time': time,
  });
  _box.write(id, scores);
}
