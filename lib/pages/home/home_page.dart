import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:slideboom/shared/app_pages.dart';

import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyP): () =>
            controller.startGame(),
        const SingleActivator(LogicalKeyboardKey.keyB): () =>
            controller.toggleBomb(),
        const SingleActivator(LogicalKeyboardKey.keyN): () =>
            controller.decreaseMode(),
        const SingleActivator(LogicalKeyboardKey.keyM): () =>
            controller.increaseMode(),
        const CharacterActivator('?'): () => controller.openHelp(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tooltip(
                message: "open Help",
                child: IconButton(
                    onPressed: controller.openHelp,
                    icon: const Icon(Icons.help)),
              ),
              Tooltip(
                message: "toggle light/dark theme",
                child: IconButton(
                  icon: Icon(
                    controller.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                  ),
                  onPressed: controller.switchTheme,
                ),
              ),
            ],
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
                                child: AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 300),
                                  firstChild: Image.asset(
                                    'assets/home.png',
                                  ),
                                  secondChild: Image.asset(
                                    'assets/home-light.png',
                                  ),
                                  crossFadeState: c.isDarkTheme
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
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
                                    PopupMenuButton(
                                      tooltip: 'select mode',
                                      initialValue: c.dropDownValue.value,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            Text(
                                              c.dropDownValue.value,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5,
                                            ),
                                            const Icon(Icons.arrow_drop_down),
                                          ],
                                        ),
                                      ),
                                      itemBuilder: (context) => c.modes.keys
                                          .map<PopupMenuItem<String>>(
                                              (String value) {
                                        return PopupMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                          ),
                                        );
                                      }).toList(),
                                      onSelected: c.onChanged,
                                    ),
                                    const SizedBox(width: 25),
                                    SizedBox(
                                      width: 150,
                                      child: Tooltip(
                                        message: "toggle bomb",
                                        child: CheckboxListTile(
                                          value: c.checkboxValue.value,
                                          onChanged: c.changeCheckbox,
                                          title: Text(
                                            'bomb ${c.checkboxValue.value ? "on" : "off"}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Tooltip(
                                message: "start game",
                                child: ElevatedButton(
                                    onPressed: c.startGame,
                                    child: const Text(
                                      'play',
                                      style: TextStyle(fontSize: 42),
                                    )),
                              ),
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
                                  'Scores for ${c.dropDownValue.value}${c.checkboxValue.value ? " with bomb" : ""}:',
                                  style: Theme.of(context).textTheme.headline6,
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
                                      // headingRowHeight: 0,
                                      columnSpacing: 25,
                                      showCheckboxColumn: false,
                                      columns: [
                                        DataColumn(
                                          label: Text(
                                            '',
                                            style: Get.textTheme.headline5,
                                          ),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'time',
                                            style: Get.textTheme.headline5,
                                          ),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                            label: Text(
                                              'moves',
                                              style: Get.textTheme.headline5,
                                            ),
                                            numeric: true),
                                      ],
                                      rows: [
                                        for (int i = 0;
                                            i < c.scores.length;
                                            i++) ...[
                                          DataRow(
                                              onSelectChanged: (value) {
                                                c.openScoreDialog(i);
                                              },
                                              cells: [
                                                DataCell(
                                                    Text((i + 1).toString())),
                                                DataCell(Text(
                                                  c.scores[i]['time'],
                                                  style: const TextStyle(
                                                      fontSize: 21),
                                                )),
                                                DataCell(Text(
                                                  "${c.scores[i]['moves']}",
                                                  style: const TextStyle(
                                                      fontSize: 21),
                                                )),
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
                          child: Center(
                            child: Row(
                              children: [
                                Text(
                                  'source code:',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Tooltip(
                                  message: "open github",
                                  child: IconButton(
                                    iconSize: 32,
                                    icon: AnimatedCrossFade(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      firstChild: Image.asset(
                                        'assets/github.png',
                                      ),
                                      secondChild: Image.asset(
                                        'assets/github-light.png',
                                      ),
                                      crossFadeState: c.isDarkTheme
                                          ? CrossFadeState.showFirst
                                          : CrossFadeState.showSecond,
                                    ),
                                    onPressed: () => c.openGithub(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
