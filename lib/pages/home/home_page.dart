import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slideboom/routes/app_pages.dart';

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
            Get.toNamed(
              Routes.settings,
            );
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
                      Image.asset(
                        'assets/home.png',
                        width: 250,
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
                        height: 250,
                        padding: const EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            headingRowHeight: 0,
                            columnSpacing: 25,
                            columns: const [
                              DataColumn(label: Text(''), numeric: true),
                              DataColumn(
                                label: Text('time'),
                                numeric: true,
                              ),
                              DataColumn(label: Text('date')),
                            ],
                            rows: [
                              for (Map score in c.scores) ...[
                                DataRow(cells: [
                                  DataCell(Text((c.scores.indexOf(score) + 1)
                                      .toString())),
                                  DataCell(Text(
                                    score['time'],
                                    style: const TextStyle(fontSize: 21),
                                  )),
                                  DataCell(Text(score['date'])),
                                ]),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                })));
  }
}
