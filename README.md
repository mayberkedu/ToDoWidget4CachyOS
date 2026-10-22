# Cachy To Do

A compact glass-style task widget for KDE Plasma 6. Features drag-and-drop task ordering, optional deadlines, color-coded priorities, customizable background tint and opacity, and English/Turkish language support. Tasks are stored locally.

Built with QML and JavaScript for the KDE Plasma desktop, including CachyOS.

## Features

- **Compact glass-style interface** with translucent surfaces and a small **νύξ** signature.
- **Independent task completion:** click the circular control to complete or reopen a task.
- **Drag-and-drop ordering:** move tasks up or down, with automatic scrolling at the list edges.
- **Optional deadlines:** choose a date from the calendar; overdue tasks are highlighted.
- **Color-coded priorities:** green for low, yellow for medium, and red for high.
- **Task filters:** switch between All, To do, and Done.
- **Customizable appearance:** choose the background color, tint strength, and opacity.
- **English and Turkish:** English is the default; change the language in the widget settings.
- **Local storage:** each widget instance keeps its own tasks and settings in Plasma configuration.

The glass effect uses translucent QML surfaces; it does not apply wallpaper blur or optical refraction. Deadlines are date-only and do not send notifications.

## Requirements

- KDE Plasma **6.0+**
- Qt **6.5+**, Qt Quick Controls, and the Plasma QML modules

CachyOS and other distributions running KDE Plasma 6 are supported targets. Other desktop environments are not supported.

On CachyOS or Arch Linux, install the runtime dependencies if needed:

```sh
sudo pacman -S --needed plasma-workspace qt6-declarative
```

## Installation

With a `cachy-todo.plasmoid` package available locally, install it using its full path:

```sh
kpackagetool6 --type Plasma/Applet --install /absolute/path/to/cachy-todo.plasmoid
```

Alternatively, use Plasma's **Add Widgets → Get New Widgets → Install Widget From Local File** option and select the package.

Then right-click the desktop, enter **Edit Mode**, open **Add Widgets**, and drag **Cachy To Do** onto the desktop.

To update an existing installation:

```sh
kpackagetool6 --type Plasma/Applet --upgrade /absolute/path/to/cachy-todo.plasmoid
```

The recommended size is **340 × 320** pixels; the minimum is **280 × 240**. Plasma may snap the dimensions to its desktop grid.

If an update still shows the previous interface, log out and back in. Avoid removing the widget to refresh it, as removing an instance can remove its saved tasks.

## Usage

- Right-click the widget and choose **New task** to add a task.
- Right-click a task or open its **⋮** menu to edit it, change its priority, or delete it.
- Double-click a task's text to edit it.
- Click the colored circle to complete or reopen a task.
- Hold and drag a task row to change its position. The order is saved.
- Use **Clear completed** in the context menu to remove finished tasks.

### Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| `Ctrl+N` | Open the new-task dialog |
| `Enter` | Save from the task text field |
| `Esc` | Close the active dialog |

## Appearance and language

Right-click the widget and choose **Appearance & language…**.

- **Language:** choose English or Türkçe.
- **Glass color:** choose the background tint color.
- **Tint / color blend:** 0% uses neutral glass; 100% uses your chosen color.
- **Background opacity:** 0% is transparent; 100% is opaque. Task text remains fully visible.

The settings preview updates immediately. Choose **Apply** or **OK** to save changes; the widget updates without restarting Plasma.

Changing the language preserves task text and ordering. Plasma's own configuration-window buttons and the system color picker follow the desktop's language.

## Data storage

Tasks and settings are stored per widget instance using Plasma's KConfig mechanism. The configuration is usually located at:

```text
~/.config/plasma-org.kde.plasma.desktop-appletsrc
```

No account, network connection, or external server is required. Back up the configuration before removing a widget instance. If saved tasks cannot be read, the widget displays an error and blocks changes to avoid overwriting the saved data.

## Development

With the project source files available, run these commands from the project directory:

```sh
# Run JavaScript tests, QML linting, and Qt Quick UI tests.
bash scripts/check.sh

# Build the installable package, including the MIT license.
bash scripts/package.sh

# Preview the interface with sample tasks.
/usr/lib/qt6/bin/qml ./preview.qml
```

The package is written to `dist/cachy-todo.plasmoid`. The standalone preview uses temporary sample data; changes are discarded when it closes.

Development checks require Node.js and Qt Quick Test. Set `QT6_BIN_DIR` if the Qt tools are installed outside `/usr/lib/qt6/bin`.

## License

MIT.
