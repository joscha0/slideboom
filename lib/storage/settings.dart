import 'package:get_storage/get_storage.dart';

final _box = GetStorage();

// selected mode
Map getMode() {
  return _box.read('mode') ?? {'mode': '3x3', 'bombs': false};
}

void setMode(String mode, bool bombs) {
  _box.write('mode', {'mode': mode, 'bombs': bombs});
}

// muted state
bool getMuted() {
  return _box.read('muted') ?? false;
}

void setMuted(bool muted) {
  _box.write('muted', muted);
}
