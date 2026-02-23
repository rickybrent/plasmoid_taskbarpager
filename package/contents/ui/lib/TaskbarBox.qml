/*
 * Copyright 2021  Tino Lorenz <tilrnz@gmx.net>
 * Copyright 2022  Diego Miguel <hello@diegomiguel.me>
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
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQuickControlsAddonsComponents
import org.kde.kirigami as Kirigami
import com.github.rickybrent.taskbarpager as PagerMod

Rectangle {
	id: taskbarBox
	property alias text: numberText.text 
	property bool fontSizeChecked: plasmoid.configuration.fontSizeChecked
	property color fontColor: plasmoid.configuration.fontColorChecked ? 
			plasmoid.configuration.fontColor : Kirigami.Theme.textColor
	property bool showWindowIndicator: true
	property list<var> taskWindows: []

	border.width: plasmoid.configuration.displayBorder ? plasmoid.configuration.borderThickness : 0
	radius: height > width ? height * (plasmoid.configuration.borderRadius / 100) : width * (plasmoid.configuration.borderRadius / 100)

	TextMetrics {
		id: textMet
		text: numberText.text
		font: numberText.font
	}
	property real longways: Math.max(textMet.width + 10, taskbarBox.height * (plasmoid.configuration.windowCountPerDesktop + 1) + 7)
	property real shortways: textMet.height + 6
	implicitWidth: plasmoid.formFactor === PlasmaCore.Types.Vertical ? shortways : longways
	implicitHeight: plasmoid.formFactor === PlasmaCore.Types.Vertical ? longways : shortways

	Rectangle {
		id: windowIndicator
		visible: taskbarBox.showWindowIndicator

		anchors.left: numberText.right
		anchors.top: numberText.top

		width: 8
		height: 8
		border.color: taskbarBox.fontColor
		border.width: 1
		color: "transparent"
		radius: width * (plasmoid.configuration.windowIndicatorRadius / 100)
	}

	Text {
		id: numberText
		visible: plasmoid.configuration.stayVisible
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		text: pagerModel.currentPage + 1
		color: fontColor
		leftPadding: 5
		rightPadding: 5
		font {
			family: plasmoid.configuration.fontFamily || Kirigami.Theme.defaultFont.family
			bold: plasmoid.configuration.fontBold
			italic: plasmoid.configuration.fontItalic
			pixelSize: fontSizeChecked ? plasmoid.configuration.fontSize : Math.min(parent.height*0.7, parent.width*0.7)
		}
	}

	Grid {
		id: tasksGrid
		anchors.left: numberText.right
		anchors.verticalCenter: parent.verticalCenter
		visible: plasmoid.configuration.showWindowIcons
		columnSpacing: 4

		readonly property int maxIconCount: Math.floor(Math.max(taskbarBox.height, taskbarBox.width) / taskBoxSize)
		readonly property bool showIconsInColumn: plasmoid.formFactor === PlasmaCore.Types.Vertical
		readonly property bool showAllIcons: taskbarBox.taskWindows.length <= maxIconCount
		readonly property int taskBoxSize: Math.min(taskbarBox.height, taskbarBox.width)

		columns: (showIconsInColumn || !showAllIcons) ? 1 : maxIconCount
		rows: (showIconsInColumn && showAllIcons) ? maxIconCount : 1
		flow: showIconsInColumn ? Grid.TopToBottom : Grid.LeftToRight

		component TaskBox: Item {
			id: taskBoxRoot
			
			property alias source: innerIcon.source
			property string badgeText: "" 
			property bool isDemandingAttention: false
			property string appName: ""
			property string title: ""
			property bool isActive: false
			property int sourcePage: -1

			property bool isClosable: false
			property bool isMovable: false
			property bool isResizable: false
			property bool isMinimized: false
			property bool isMinimizable: false
			property bool isMaximized: false
			property bool isMaximizable: false

			property var virtualDesktops: []
			property string launcherUrlWithoutIcon: ""

			property bool isFullScreen: false
			property bool isFullScreenable: false
			property bool isShaded: false
			property bool isShadeable: false
			property bool hasNoBorder: false
			property bool canSetNoBorder: false
			property bool canLaunchNewInstance: false
			property bool isExcludedFromCapture: false
			property bool canExcludeFromCapture: true // Not a real property, will make configurable later.
			property bool isOnAllVirtualDesktops: false
			property bool isKeepAbove: false
			property bool isKeepBelow: false


			property var activateWindow
			property var closeWindow
			property var minimizeWindow
			property var maximizeWindow

			property var toggleKeepAbove
			property var toggleKeepBelow
			property var newInstance
			property var resize
			property var move
			property var toggleFullScreen
			property var toggleShaded
			property var toggleNoBorder
			property var toggleExcludeFromCapture
			property var togglePinToAllDesktops

			property var moveWindowToDesktopPage

			height: tasksGrid.taskBoxSize
			width: tasksGrid.taskBoxSize

			Drag.active: iconMouseArea.drag.active
			Drag.source: taskBoxRoot
			Drag.hotSpot.x: width / 2
			Drag.hotSpot.y: height / 2
			z: iconMouseArea.drag.active ? 100 : 0

			// Active task highlight: (TODO: make this configurable.)
			Rectangle {
				anchors.fill: parent
				visible: taskBoxRoot.isActive
				readonly property color color_: Kirigami.Theme.highlightColor
				color: Qt.rgba(color_.r, color_.g, color_.b, 0.3) 				
			}
			// Hovered task highlight:
			Rectangle {
				anchors.fill: parent
				visible: tooltipArea.containsMouse
				readonly property color color_: Kirigami.Theme.highlightColor
				color: Qt.rgba(color_.r, color_.g, color_.b, 0.2) 				
			}

			// Per-window tooltip (and hover events).
			PlasmaCore.ToolTipArea {
				id: tooltipArea
				anchors.fill: parent
				mainText: taskBoxRoot.title
				subText: taskBoxRoot.appName
				enabled: taskBoxRoot.appName !== "" && taskBoxRoot.title !== ""
			}

			Kirigami.Icon {
				id: innerIcon
        		width: parent.width * 0.8
		        height: parent.height * 0.8
				anchors.centerIn: parent
				opacity: taskBoxRoot.isMinimized ? 0.4 : 1.0
				roundToIconSize: false
			}

			TaskContextMenu {
				id: contextMenu
				visualParent: taskBoxRoot 
				taskBox: taskBoxRoot
			}

			// MouseArea to handle clicks
			MouseArea {
				id: iconMouseArea
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

				drag.target: taskBoxRoot
				drag.axis: tasksGrid.showIconsInColumn ? Drag.YAxis : Drag.XAxis
				property real dragStartX: 0
				property real dragStartY: 0

				onClicked: (mouse) => {
					if (mouse.button === Qt.LeftButton) {
						console.log("com.github.rickybrent.taskbarpager Left clicked: activate/focus", taskBoxRoot.appName, "-", taskBoxRoot.title);
						if (taskBoxRoot.isActive) {
							if (taskBoxRoot.minimizeWindow) {
								taskBoxRoot.minimizeWindow();
								console.log("com.github.rickybrent.taskbarpager min")
							}
						} else {
							if (taskBoxRoot.activateWindow) {
								taskBoxRoot.activateWindow();
							}
						}
					} else if (mouse.button === Qt.MiddleButton) {
						console.log("com.github.rickybrent.taskbarpager Middle clicked: close", taskBoxRoot.appName, "-", taskBoxRoot.title);
						if (taskBoxRoot.closeWindow) {
							taskBoxRoot.closeWindow();
						}
					} else if (mouse.button === Qt.RightButton) {
						console.log("com.github.rickybrent.taskbarpager Right clicked: context menu", taskBoxRoot.appName, "-", taskBoxRoot.title);
						console.log("com.github.rickybrent.taskbarpager Right clicked:" + taskBoxRoot.launcherUrlWithoutIcon);
						contextMenu.openRelative();
					}
				}

				onPressed: {
					taskbarBox.z = 100;
					dragStartX = taskBoxRoot.x;
					dragStartY = taskBoxRoot.y;				
				}

				onReleased: (mouse) => {
					taskbarBox.z = 0;
					if (taskBoxRoot.Drag.active) {
						taskBoxRoot.Drag.drop();
					}
					taskBoxRoot.x = dragStartX;
					taskBoxRoot.y = dragStartY;
				}
			}

			// Badge overlay (notification count, attention state)
			Rectangle {
				id: badge
				visible: taskBoxRoot.badgeText !== ""
				
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				
				height: parent.height * 0.55
				width: Math.max(height, badgeLabel.implicitWidth + 4)
				radius: height / 2
				
				color: taskBoxRoot.isDemandingAttention ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.highlightColor
				border.color: Kirigami.Theme.backgroundColor
				border.width: 1

				Text {
					id: badgeLabel
					anchors.centerIn: parent
					text: taskBoxRoot.badgeText
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					color: Kirigami.Theme.highlightedTextColor
					font.pixelSize: parent.height * 0.9
					font.bold: true
				}
			}
		}

		Repeater {
			model: taskbarBox.taskWindows
			TaskBox {
				visible: tasksGrid.showAllIcons
				source: modelData.source
				badgeText: modelData.badgeText
				isDemandingAttention: modelData.isDemandingAttention || false
				appName: modelData.appName || ""
				title: modelData.title || ""
				isActive: modelData.isActive || false
				sourcePage: modelData.sourcePage
				
				isClosable: modelData.isClosable || false
				isMovable: modelData.isMovable || false
				isResizable: modelData.isResizable || false
				isMinimized: modelData.isMinimized || false
				isMinimizable: modelData.isMinimizable || false
				isMaximized: modelData.isMaximized || false
				isMaximizable: modelData.isMaximizable || false

				virtualDesktops: modelData.virtualDesktops || []
				launcherUrlWithoutIcon: modelData.launcherUrlWithoutIcon

				isFullScreen: modelData.isFullScreen || false
				isFullScreenable: modelData.isFullScreenable || false
				isShaded: modelData.isShaded || false
				isShadeable: modelData.isShadeable || false
				hasNoBorder: modelData.hasNoBorder || false
				canSetNoBorder: modelData.canSetNoBorder || false
				canLaunchNewInstance: modelData.canLaunchNewInstance || false
				isExcludedFromCapture: modelData.isExcludedFromCapture || false
				isOnAllVirtualDesktops: modelData.isOnAllVirtualDesktops || false
				isKeepAbove: modelData.isKeepAbove || false
				isKeepBelow: modelData.isKeepBelow || false

				activateWindow: modelData.activateWindow
				closeWindow: modelData.closeWindow
				minimizeWindow: modelData.minimizeWindow
				maximizeWindow: modelData.maximizeWindow

				toggleKeepAbove: modelData.toggleKeepAbove
				toggleKeepBelow: modelData.toggleKeepBelow
				newInstance: modelData.newInstance
				resize: modelData.resize
				move: modelData.move
				toggleFullScreen: modelData.toggleFullScreen
				toggleShaded: modelData.toggleShaded
				toggleNoBorder: modelData.toggleNoBorder
				toggleExcludeFromCapture: modelData.toggleExcludeFromCapture
				togglePinToAllDesktops: modelData.togglePinToAllDesktops
				moveWindowToDesktopPage: modelData.moveWindowToDesktopPage
			}
		}

		TaskBox {
			visible: !tasksGrid.showAllIcons
			source: tasksGrid.showIconsInColumn ? "view-more-symbolic" : "view-more-horizontal-symbolic"
		}
	}

}
