# Plasma Text Editor Widget

A KDE Plasma 6 widget that displays the contents of a text file on your desktop or panel.

## Features

- Display any text file content in a widget
- Configurable file path
- Read-only mode to prevent accidental edits
- Word wrap support
- Monospace font for code/logs
- Auto-reload when content changes
- Auto-save when editing


## Requirements

- KDE Plasma 6
- Qt 6
- KDE Frameworks 6 (KF6):
  - KI18n
  - Kirigami
  - KCMUtils

## Building

### Dependencies (openSUSE Tumbleweed)

```bash
sudo zypper in cmake ninja extra-cmake-modules \
    qt6-base-devel qt6-declarative-devel \
    kf6-ki18n-devel kf6-kirigami-devel kf6-kcmutils-devel
```

### Build and Install

```bash
mkdir build
cd build
cmake . -B build/ -G Ninja
cmake --build build
sudo cmake --install build
```

### Reload Plasma

```bash
kquitapp6 plasmashell && plasmashell --replace &
```

Or simply log out and log back in.


## License

GPL-3.0-or-later

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
