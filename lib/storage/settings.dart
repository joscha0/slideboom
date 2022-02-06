import 'package:get_storage/get_storage.dart';

final _box = GetStorage();

// selected mode
getMode() {
  return _box.read('mode') ?? {'mode': '3x3', 'bombs': false};
}

setMode(String mode, bool bombs) {
  _box.write('mode', {'mode': mode, 'bombs': bombs});
}
