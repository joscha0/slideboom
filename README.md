# slideboom
<img src="https://user-images.githubusercontent.com/45885696/158198859-782f0516-d9f6-43a5-9cf9-95c1b419e246.png" width=400>


> simple slide puzzle built for the 2022 [flutter puzzle hack](https://flutterhack.devpost.com/)

Visit https://slideboom.960.eu/ to play the web version of the game.

Or download the Android, Windows or Linux build from the release tab.

---

## The Game

### How to play?
- Slide the tiles into numerical order.
- If you move one tile, the entire row moves
- Be as fast as possible and use the least amount of moves.
- If you move the bomb you lose!

### Keyboard shortcuts
It is recommended to play the game with touch inputs. If you are on a PC you can also use keyboard shortcuts.

#### Home Screen
- `p`: play
- `m`: increase mode
- `n`: decrease mode
- `b`: toggle bomb
- `?`: open help


#### In Game
- `ESC`: toggle pause
- `WASD`: move the selection
- `arrow keys` / `vim keys (HJKL)`: move tiles

## Build

### Web
```bash
 flutter build web --web-renderer canvaskit
```
(forces canvaskit for mobile web, required for animation)

### Linux
```bash
 flutter build linux --release
 cd build_files/linux
 ./create-appimage.sh
 cd Slideboom.AppDir
 ./Slideboom-x86_64.AppImage
 ```
([appimagetool](https://github.com/AppImage/AppImageKit) required)
- generates executable appimage file

### Android
```bash
flutter build apk
```

### Windows
```bash
flutter pub run msix:create
```
in [windows](https://github.com/joscha0/slideboom/tree/windows) branch

