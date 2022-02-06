import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
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
                  bool isRow =
                      ResponsiveWrapper.of(context).isLargerThan(DESKTOP) ||
                          ResponsiveWrapper.of(context).orientation ==
                              Orientation.landscape;
                  return ResponsiveRowColumn(
                    columnMainAxisAlignment: MainAxisAlignment.center,
                    layout: isRow
                        ? ResponsiveRowColumnType.ROW
                        : ResponsiveRowColumnType.COLUMN,
                    children: [
                      ResponsiveRowColumnItem(
                        rowOrder: 1,
                        rowFlex:
                            ResponsiveWrapper.of(context).isLargerThan(TABLET)
                                ? 2
                                : 1,
                        child: Column(
                            mainAxisAlignment: isRow
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: double.infinity,
                              ),
                              Container(
                                constraints: BoxConstraints(
                                    maxHeight: ResponsiveWrapper.of(context)
                                            .scaledHeight *
                                        0.3),
                                padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveWrapper.of(context)
                                            .scaledWidth *
                                        0.15),
                                child: Image.asset(
                                  'assets/home.png',
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveWrapper.of(context)
                                            .scaledHeight *
                                        0.01),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    DropdownButton(
                                        value: c.dropDownValue.value,
                                        style: Get.textTheme.headline5,
                                        items: c.modes.keys
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: c.onChanged),
                                    if ((c.modes[c.dropDownValue.value] ?? 4) >=
                                        4) ...[
                                      const SizedBox(width: 25),
                                      Checkbox(
                                          value: c.checkboxValue.value,
                                          onChanged: c.changeCheckbox),
                                      Text(
                                          'bombs ${c.checkboxValue.value ? "on" : "off"}')
                                    ],
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: c.startGame,
                                  child: const Text(
                                    'play',
                                    style: TextStyle(fontSize: 42),
                                  )),
                            ]),
                      ),
                      ResponsiveRowColumnItem(
                        rowOrder: 0,
                        rowFlex: 1,
                        child: Padding(
                          padding: EdgeInsets.all(ResponsiveWrapper.of(context)
                                  .isLargerThan(DESKTOP)
                              ? 0.05 *
                                  ResponsiveWrapper.of(context).scaledHeight
                              : 0),
                          child: Column(
                              mainAxisAlignment: isRow
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: ResponsiveWrapper.of(context)
                                          .scaledHeight *
                                      0.03,
                                ),
                                Text(
                                  'Scores for ${c.dropDownValue.value}${c.checkboxValue.value ? " with bombs" : ""}:',
                                  style: Get.textTheme.headline6,
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                      maxHeight: ResponsiveWrapper.of(context)
                                              .scaledHeight *
                                          (isRow
                                              ? 0.8
                                              : (ResponsiveWrapper.of(context)
                                                      .isLargerThan(MOBILE)
                                                  ? 0.25
                                                  : 0.4))),
                                  padding: const EdgeInsets.all(8),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      headingRowHeight: 0,
                                      columnSpacing: 25,
                                      columns: const [
                                        DataColumn(
                                          label: Text(''),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                          label: Text('time'),
                                          numeric: true,
                                        ),
                                        DataColumn(label: Text('date')),
                                      ],
                                      rows: [
                                        for (Map score in c.scores) ...[
                                          DataRow(cells: [
                                            DataCell(Text(
                                                (c.scores.indexOf(score) + 1)
                                                    .toString())),
                                            DataCell(Text(
                                              score['time'],
                                              style:
                                                  const TextStyle(fontSize: 21),
                                            )),
                                            DataCell(Text(score['date'])),
                                          ]),
                                        ]
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      if (ResponsiveWrapper.of(context)
                          .isLargerThan(DESKTOP)) ...[
                        ResponsiveRowColumnItem(
                          rowOrder: 2,
                          rowFlex: 1,
                          child: Container(),
                        ),
                      ]
                    ],
                  );
                })));
  }
}
