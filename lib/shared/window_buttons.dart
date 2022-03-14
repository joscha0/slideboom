import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

final buttonColors = WindowButtonColors(
  iconNormal: Colors.white54,
  mouseOver: Colors.white24,
  mouseDown: Colors.white24,
  iconMouseOver: Colors.white,
  iconMouseDown: Colors.white,
);

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: Colors.white54,
    iconMouseOver: Colors.white);

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Row(
        children: [
          MinimizeWindowButton(colors: buttonColors),
          appWindow.isMaximized
              ? RestoreWindowButton(
                  colors: buttonColors,
                  onPressed: maximizeOrRestore,
                )
              : MaximizeWindowButton(
                  colors: buttonColors,
                  onPressed: maximizeOrRestore,
                ),
          CloseWindowButton(colors: closeButtonColors),
        ],
      ),
    );
  }
}

class RestoreWindowButton extends WindowButton {
  RestoreWindowButton(
      {Key? key,
      WindowButtonColors? colors,
      VoidCallback? onPressed,
      bool? animate})
      : super(
            key: key,
            colors: colors,
            animate: animate ?? false,
            iconBuilder: (buttonContext) =>
                RestoreIcon(color: buttonContext.iconColor),
            onPressed: onPressed ?? () => appWindow.maximizeOrRestore());
}
