import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

PlasmaExtras.Menu {
    id: contextMenu

    placement: {
        if (Plasmoid.location === PlasmaCore.Types.LeftEdge) {
            return PlasmaExtras.Menu.RightPosedTopAlignedPopup;
        } else if (Plasmoid.location === PlasmaCore.Types.TopEdge) {
            return PlasmaExtras.Menu.BottomPosedLeftAlignedPopup;
        } else if (Plasmoid.location === PlasmaCore.Types.RightEdge) {
            return PlasmaExtras.Menu.LeftPosedTopAlignedPopup;
        } else {
            return PlasmaExtras.Menu.TopPosedLeftAlignedPopup;
        }
    }

    property var taskBox
    
    PlasmaExtras.MenuItem {
        text: "Open New Window"
        icon: taskBox.source
        visible: taskBox.canLaunchNewInstance
        onClicked: {
        }
    }
    PlasmaExtras.MenuItem {
        separator: true
        visible: taskBox.canLaunchNewInstance
    }

    PlasmaExtras.MenuItem {
        text: taskBox.isMinimized ? "Restore" : "Minimize"
        icon: taskBox.isMinimized ? "window-restore" : "window-minimize"
        visible: taskBox.isMinimizable
        onClicked: {
            if (taskBox.minimizeWindow) {
                taskBox.minimizeWindow();
            }
        }
    }
    
    PlasmaExtras.MenuItem {
        text: taskBox.isMaximized ? "Restore" : "Maximize"
        icon: taskBox.isMaximized ? "window-restore" : "window-maximize"
        visible: taskBox.isMaximizable
        onClicked: {
            if (taskBox.maximizeWindow) {
                taskBox.maximizeWindow();
            }
        }
    }
    
    PlasmaExtras.MenuItem {
        text: "Move"
        icon: "transform-move"
        visible: taskBox.isMovable
        onClicked: {
            if (taskBox.move) {
                taskBox.move();
            }
        }
    }

    PlasmaExtras.MenuItem {
        text: "Resize"
        icon: "image-resize-symbolic"
        visible: taskBox.isResizable
        onClicked: {
            console.log("com.github.rickybrent.taskbarpager resizing soon")
            if (taskBox.resize) {
                console.log("com.github.rickybrent.taskbarpager resizing")
                taskBox.resize();
            }
        }
    }

    PlasmaExtras.MenuItem {
        checkable: true
        checked: taskBox.isKeepAbove
        text: "Always on Top"
        icon: taskBox.isKeepAbove ? "window-keep-above" : "window-keep-above"
        onClicked: {
            if (taskBox.toggleKeepAbove) {
                taskBox.toggleKeepAbove();
            }
        }
    }

    PlasmaExtras.MenuItem {
        checkable: true
        checked: taskBox.isOnAllVirtualDesktops
        text: "On All Desktops"
        icon: taskBox.isOnAllVirtualDesktops ? "window-unpin" : "window-pin"
        onClicked: {
            console.log('com.github.rickybrent.taskbarpager togglePinToAllDesktops' + taskBox.virtualDesktops);
            if (taskBox.togglePinToAllDesktops) {
                taskBox.togglePinToAllDesktops();
            }
        }
    }

    PlasmaExtras.MenuItem {
        visible: taskBox.isResizable || taskBox.isMovable || taskBox.isMaximizable || taskBox.isMinimizable
        separator: true
    }
        
    PlasmaExtras.MenuItem {
        text: taskBox.hasNoBorder ? "Set Titlebar" : "No Titlebar"
        icon: taskBox.hasNoBorder ? "window" : "checkbox-symbolic"
        visible: taskBox.canSetNoBorder
        onClicked: {
            if (taskBox.toggleNoBorder) {
                taskBox.toggleNoBorder();
            }
        }
    }

    // I think this is disabled for all windows now, but:
    PlasmaExtras.MenuItem {
        text: taskBox.isShaded ? "Unshade" : "Shade"
        icon: taskBox.isShaded ? "window-unshade" : "window-shade"
        visible: taskBox.isShadeable
        onClicked: {
            if (taskBox.toggleShaded) {
                taskBox.toggleShaded();
            }
        }
    }

    PlasmaExtras.MenuItem {
        text: taskBox.isExcludedFromCapture ? "Show in ScreenCasts" : "Hide from ScreenCasts"
        icon: taskBox.isExcludedFromCapture ? "camera-symbolic" : "camera-disabled-symbolic"
        visible: taskBox.canExcludeFromCapture
        onClicked: {
            if (taskBox.toggleExcludeFromCapture) {
                taskBox.toggleExcludeFromCapture();
            }
        }
    }

    PlasmaExtras.MenuItem {
        visible: taskBox.isShadeable || taskBox.canSetNoBorder || taskBox.canExcludeFromCapture
        separator: true
    }
    
    PlasmaExtras.MenuItem {
        text: "Close"
        icon: "window-close"
        onClicked: {
            if (taskBox.closeWindow) {
                taskBox.closeWindow();
            }
        }
    }
}