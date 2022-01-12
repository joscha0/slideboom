import 'package:fixmymaze/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        floatingActionButton: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Get.to(() => const SettingsPage(),
                transition: Transition.rightToLeftWithFade);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        body: SafeArea(
            child: GetX<HomeController>(
                init: HomeController(),
                builder: (c) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: double.infinity,
                      ),
                      Text(
                        'slide boom!',
                        style: Get.textTheme.headline3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton(
                              value: c.dropDownValue.value,
                              style: Get.textTheme.headline5,
                              items: c.modes.keys.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: c.onChanged),
                          if ((c.modes[c.dropDownValue.value] ?? 4) >= 4) ...[
                            const SizedBox(width: 25),
                            Checkbox(
                                value: c.checkboxValue.value,
                                onChanged: c.changeCheckbox),
                            Text(
                                'bombs ${c.checkboxValue.value ? "on" : "off"}')
                          ],
                        ],
                      ),
                      ElevatedButton(
                          onPressed: c.startGame,
                          child: const Text(
                            'play',
                            style: TextStyle(fontSize: 42),
                          )),
                      const SizedBox(
                        height: 25,
                      ),
                      Text(
                        'Scores for ${c.dropDownValue.value}${c.checkboxValue.value ? " with bombs" : ""}:',
                        style: Get.textTheme.headline6,
                      ),
                      Container(
                        padding: const EdgeInsets.all(25),
                        child: Table(
                          children: const [
                            TableRow(children: [
                              Text('1.'),
                              Text('...'),
                            ])
                          ],
                        ),
                      ),
                    ],
                  );
                })));
  }
}
