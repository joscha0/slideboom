import 'package:get/get.dart';

class HomeController extends GetxController {
  RxString dropDownValue = '3x3'.obs;

  void onChanged(String? value) {
    dropDownValue.value = value ?? '3x3';
  }
}
