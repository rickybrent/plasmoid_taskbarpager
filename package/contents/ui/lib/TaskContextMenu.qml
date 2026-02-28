/*
 * Copyright 2026  Ricky Brent <ricky@rickybrent.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

import com.github.rickybrent.taskbarpager as PagerMod

PlasmaExtras.Menu {
    id: contextMenu
    property PagerMod.LaunchBackend launchBackend

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
    property bool hasDynamicLaunchItems: false

    function popup(): void {
        Plasmoid.contextualActionsAboutToShow();
        if (!hasDynamicLaunchItems) {
            loadDynamicLaunchActions(taskBox.launcherUrlWithoutIcon);
        }
        openRelative();
    }


    function loadDynamicLaunchActions(launcherUrl: url): void {
        let sections = [];

        sections.push({
            title: i18nc("@title:group for section of menu items", "Actions"),
            group: "actions",
            actions: launchBackend.jumpListActions(launcherUrl, contextMenu)
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
        textMetrics.elideWidth = 200;

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
        hasDynamicLaunchItems = sections.length;
    }

    function newMenuItem(parent: QtObject): PlasmaExtras.MenuItem {
        return Qt.createQmlObject(`
            import org.kde.plasma.extras as PlasmaExtras

            PlasmaExtras.MenuItem {}
        `, parent) as PlasmaExtras.MenuItem;
    }

    PlasmaExtras.MenuItem {
        id: startNewInstanceItem
        visible: taskBox.canLaunchNewInstance
        text: i18nc("action:inmenu", "Open New Window")
        icon: "window-new"
        onClicked: {
            if (taskBox.newInstance) {
                taskBox.newInstance();
            }
        }
    }
    PlasmaExtras.MenuItem {
        separator: true
        visible: taskBox.canLaunchNewInstance || hasDynamicLaunchItems
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
            if (taskBox.resize) {
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
        text: taskBox.hasNoBorder ? "Show Titlebar && Frame" : "No Titlebar && Frame"
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
        icon: taskBox.isExcludedFromCapture ? "camera-symbolic" : "view-private-symbolic"
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