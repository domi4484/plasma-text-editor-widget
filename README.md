# Plasma Text Editor Widget

A KDE Plasma 6 widget that displays the contents of a text file on your desktop or panel.

## Features

- Display any text file content in a widget
- Configurable file path with file browser
- Read-only mode to prevent accidental edits
- Word wrap support
- Monospace font for code/logs
- Auto-reload when configuration changes

## Planned Features

- Syntax highlighting support
- Line numbers display
- Auto-reload when file changes on disk
- Multiple file tabs

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
cmake .. -G Ninja
cmake --build .
sudo cmake --install .
```

### Reload Plasma

```bash
kquitapp6 plasmashell && plasmashell --replace &
```

Or simply log out and log back in.

## Usage

1. Right-click on your desktop or panel
2. Select "Add Widgets..."
3. Search for "Text File Viewer"
4. Add the widget to your desktop/panel
5. Right-click the widget and select "Configure Text File Viewer"
6. Click "Browse..." to select a file or type the path manually
7. Adjust other settings as needed (read-only, word wrap)
8. Click "OK"

## Example Use Cases

- Monitor log files
- Display system information (`/etc/os-release`)
- Show TODO lists
- Display code snippets
- Monitor configuration files

## Development

The widget is built as a pure QML Plasma applet without C++ plugins to maximize compatibility.

### Project Structure

```
plasma-text-widget/
├── CMakeLists.txt              # Main build configuration
├── metadata.json               # Widget metadata
├── contents/
│   ├── config/
│   │   ├── config.qml         # Config categories definition
│   │   └── main.xml           # Config schema (defaults)
│   └── ui/
│       ├── main.qml           # Main widget UI
│       └── configGeneral.qml  # Configuration page UI
└── plugin/                     # (Currently unused, reserved for future C++ features)
```

## Known Issues

- Syntax highlighting not yet implemented
- Line numbers not yet implemented
- Large files may cause performance issues
- No automatic reload when file changes externally

## License

GPL-2.0-or-later

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Authors

- Initial development via AI assistance