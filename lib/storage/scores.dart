import 'package:get_storage/get_storage.dart';

final _box = GetStorage();

getScores(String mode, bool bombs) {
  String id = "scores-" + mode + (bombs ? "b" : "");
  List scores = _box.read(id) ?? [];
  return scores;
}

bool addScore(
    int rowCount, bool bombs, int time, int moves, List<int> startPosition) {
  /// returns true if score is new highscore
  // id: scores-4x4b
  String id = "scores-${rowCount}x$rowCount" + (bombs ? "b" : "");
  List scores = _box.read(id) ?? [];
  Map slowest = {'time': 0};

  bool isHighscore = false;
  if (scores.length > 1) {
    slowest = scores.reduce((a, b) => a['time'] > b['time'] ? a : b);
    Map fastest = scores.reduce((a, b) => a['time'] < b['time'] ? a : b);
    if (fastest['time'] > time) {
      isHighscore = true;
    }
  } else if (scores.isNotEmpty) {
    if (scores[0]['time'] > time) {
      isHighscore = true;
    }
  } else {
    isHighscore = true;
  }

  if (scores.length < 10) {
    _saveScore(id, time, scores, moves, startPosition);
  } else if (slowest['time'] > time) {
    scores.removeWhere((score) => score == slowest);
    _saveScore(id, time, scores, moves, startPosition);
  }
  return isHighscore;
}

_saveScore(
    String id, int time, List scores, int moves, List<int> startPosition) {
  DateTime now = DateTime.now();
  scores.add({
    'date': now.toString(),
    'time': time,
    'moves': moves,
    'startPosition': startPosition,
  });
  _box.write(id, scores);
}
