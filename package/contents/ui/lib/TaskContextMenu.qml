import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

import com.github.rickybrent.taskbarpager as PagerMod
PlasmaExtras.Menu {
    id: contextMenu
    property PagerMod.Backend backend

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

    function popup(): void {
        Plasmoid.contextualActionsAboutToShow();

        loadDynamicLaunchActions(taskBox.launcherUrlWithoutIcon);
        openRelative();
    }


    function loadDynamicLaunchActions(launcherUrl: url): void {
        let sections = [];

        sections.push({
            title: i18nc("@title:group for section of menu items", "Actions"),
            group: "actions",
            actions: backend.jumpListActions(launcherUrl, contextMenu)
        });

        // C++ can override section heading by returning a QString as first action
        sections.forEach((section) => {
            if (typeof section.actions[0] === "string") {
                section.title = section.actions.shift(); // take first
            }
        });

        // QMenu does not limit its width automatically. Even if we set a maximumWidth
        // it would just cut off text rather than eliding. So we do this manually.
        const textMetrics = Qt.createQmlObject("import QtQuick; TextMetrics {}", contextMenu);
        textMetrics.elide = Qt.ElideRight;
        textMetrics.elideWidth = TaskManagerApplet.LayoutMetrics.maximumContextMenuTextWidth();

        sections.forEach(section => {
            if (section["actions"].length > 0 || section["group"] === "actions") {
                // Don't add the "Actions" header if the menu has nothing but actions
                // in it, because then it's redundant (all menus have actions)
                if (section.group !== "actions" || sections.length > 1) {
                    var sectionHeader = newMenuItem(contextMenu);
                    sectionHeader.text = section["title"];
                    sectionHeader.section = true;
                    contextMenu.addMenuItem(sectionHeader, startNewInstanceItem);
                }
            }

            for (var i = 0; i < section["actions"].length; ++i) {
                var item = newMenuItem(contextMenu);
                item.action = section["actions"][i];

                textMetrics.text = item.action.text.replace("&", "&&");
                item.action.text = textMetrics.elidedText;

                contextMenu.addMenuItem(item, startNewInstanceItem);
            }
        });
    }


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