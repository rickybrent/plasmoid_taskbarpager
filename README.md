 # Taskbar Pager
A combination taskbar-pager applet for the [KDE Plasma desktop](https://kde.org/plasma-desktop/), for those who love Tint2's multi_desktop mode.

Instead of a standard abstract pager, this applet displays multiple "taskbars", one for each virtual desktop/workspace. Window icons can be dragged between taskbars to move windows between virtual desktops.

Likely requires Plasma 6.6 or later.

### Full layout
![Full layout](https://raw.githubusercontent.com/rickybrent/plasmoid_taskbarpager/master/docs/images/full.png?raw=true)
### Compact layout
![Compact layout](https://raw.githubusercontent.com/rickybrent/plasmoid_taskbarpager/master/docs/images/compact.png?raw=true)

## Features

* **Per-Virtual Desktop Taskbars:** The main one: quickly see exactly which windows are open on which virtual desktop.
* **Also a Virtual Desktop Pager:** Click an empty space on a taskbar to switch to that virtual desktop; for the active desktop, clicking it can be configured to open the overview or show the desktop.
* **Drag-and-Drop Management:** Drag a window's taskbox from one desktop's taskbar to another to move the window between virtual desktops.
* **Options for Pinned Windows:** Windows set to show on all virtual desktops (pinned) can be shown on all taskbars, only the active taskbar, or in a dedicated section to the left.
* **Context Menus:** Right-click context menu support for window management and desktop-file additional application actions.
* **Window icon badges:** See the unread items count extracted from window titles or attention state.

## Installation

### Build dependencies

#### <u>Archlinux</u>
```
sudo pacman -S base-devel cmake extra-cmake-modules qt6-base qt6-declarative kwin \
  libplasma plasma-activities plasma-workspace --noconfirm
```

### <u>openSUSE Tumbleweed</u>
```
sudo zypper in -y cmake gcc-c++ cmake extra-cmake-modules qt6-base-devel qt6-declarative-devel \
  kf6-ki18n-devel kf6-kservice-devel kf6-kwindowsystem-devel libplasma6-devel \
  plasma6-activities-devel kwin6-devel wayland-devel libepoxy-devel \
  libdrm-devel plasma6-workspace-devel kf6-kitemmodels-devel
```

### <u>Fedora</u>
```
sudo dnf install -y cmake extra-cmake-modules g++ qt6-qtbase-devel qt6-qtdeclarative-devel \
  kf6-ki18n-devel kf6-kservice-devel kf6-kwindowsystem-devel libplasma-devel \
  plasma-activities-devel kwin-devel wayland-devel libepoxy-devel \
  libdrm-devel plasma-workspace-devel kf6-kitemmodels-devel
```

### <u>Debian14 (forky)</u>
```
sudo apt-get -y install cmake build-essential \
  qt6-declarative-dev extra-cmake-modules \
  qt6-base-dev libkf6i18n-dev libkf6service-dev \
  libkf6windowsystem-dev plasma-workspace-dev libplasmaactivities-dev \
  kwin-dev pkg-config libdrm-dev
```

### <u>KDE Neon (user)</u>
```
sudo apt-get -y install cmake build-essential \
  qt6-declarative-dev extra-cmake-modules \
  qt6-base-dev libkf6i18n-dev libkf6service-dev libkf6kio-dev \
  libkf6windowsystem-dev plasma-workspace-dev libkf6activities-dev \
  kwin-dev pkg-config libdrm-dev gettext
```

> [!NOTE]
> Running either the `dev.sh` or `install.sh` installs for the current user (no system-wide files) typically this is inside $HOME/.local/share/plasma/plasmoids

Clone the repository and choose one of the following scripts:

- **Development**: To test the applet without restarting your desktop, run:
  ```bash
  ./dev.sh
  ```
  This will build, install locally, and open the applet in `plasmoidviewer`.

- **Installation**: To install and apply changes to your live Plasma session, run:
  ```bash
  ./install.sh
  ```
  This will build, install locally, and restart `plasmashell`.

> [!WARNING]
> Due to the move to a c++ plugin environment which requires compilation, this KDE Plasma applet can no longer be installed directly from the KDE store.

# Other Projects / Credits

This project was originally forked from [compact_pager](https://github.com/tilorenz/compact_pager) -- well worth checking out if you'd like something that doesn't take up quite so much room on the panel.

Most of the C++ backend plugin work (as well as the compilation instructions and installation scripts above) were based on [kara](https://github.com/dhruv8sh/kara), a beautifully customizable pager.

Finally, the launcher and dynamic context menu code was adapted from the [Icons-and-Text Task Manager](https://github.com/KDE/plasma-desktop/tree/master/applets/taskmanager) from Plasma desktop.
