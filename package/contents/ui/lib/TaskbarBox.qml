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
	property list<var> iconSources: []

	border.width: plasmoid.configuration.displayBorder ? plasmoid.configuration.borderThickness : 0
	radius: height > width ? height * (plasmoid.configuration.borderRadius / 100) : width * (plasmoid.configuration.borderRadius / 100)

	TextMetrics {
		id: textMet
		text: numberText.text
		font: numberText.font
	}

	implicitWidth: Math.max(textMet.width + 10, taskbarBox.height * (plasmoid.configuration.windowCountPerDesktop + 1) + 7)
	implicitHeight: textMet.height + 6

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
		id: iconGrid
		anchors.left: numberText.right
		anchors.verticalCenter: parent.verticalCenter
		visible: plasmoid.configuration.showWindowIcons
		columnSpacing: 4

		readonly property int maxIconCount: Math.floor(Math.max(taskbarBox.height, taskbarBox.width) / boxIconSize)
		readonly property bool showIconsInColumn: taskbarBox.height > taskbarBox.width
		readonly property bool showAllIcons: taskbarBox.iconSources.length <= maxIconCount
		readonly property int boxIconSize: Math.min(taskbarBox.height, taskbarBox.width)

		columns: (showIconsInColumn || !showAllIcons) ? 1 : maxIconCount
		rows: (showIconsInColumn && showAllIcons) ? maxIconCount : 1
		flow: showIconsInColumn ? Grid.TopToBottom : Grid.LeftToRight

		component BoxIcon: Item {
			id: boxIconRoot
			
			property alias source: innerIcon.source
			property string badgeText: "" 
			property bool isDemandingAttention: false
			property string appName: ""
			property string title: ""
			property bool isActive: false
			property bool isMinimized: false
			property var activateWindow
			property var closeWindow
			property var minimizeWindow

			height: iconGrid.boxIconSize
			width: iconGrid.boxIconSize

			// Active task highlight: (TODO: make this configurable.)
			Rectangle {
				anchors.fill: parent
				visible: boxIconRoot.isActive
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
				mainText: boxIconRoot.title
				subText: boxIconRoot.appName
				enabled: boxIconRoot.appName !== "" && boxIconRoot.title !== ""
			}

			Kirigami.Icon {
				id: innerIcon
        		width: parent.width * 0.8
		        height: parent.height * 0.8
				anchors.centerIn: parent
				opacity: boxIconRoot.isMinimized ? 0.4 : 1.0
				roundToIconSize: false
			}

			// MouseArea to handle clicks
			MouseArea {
				id: iconMouseArea
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
				
				onClicked: (mouse) => {
					if (mouse.button === Qt.LeftButton) {
						console.log("com.github.rickybrent.taskbarpager Left clicked: activate/focus", boxIconRoot.appName, "-", boxIconRoot.title);
						if (boxIconRoot.isActive) {
							if (boxIconRoot.minimizeWindow) {
								boxIconRoot.minimizeWindow();
								console.log("com.github.rickybrent.taskbarpager min")
							}
						} else {
							if (boxIconRoot.activateWindow) {
								boxIconRoot.activateWindow();
							}
						}
					} else if (mouse.button === Qt.MiddleButton) {
						console.log("com.github.rickybrent.taskbarpager Middle clicked: close", boxIconRoot.appName, "-", boxIconRoot.title);
						if (boxIconRoot.closeWindow) {
							boxIconRoot.closeWindow();
						}
					} else if (mouse.button === Qt.RightButton) {
						console.log("com.github.rickybrent.taskbarpager Right clicked: context menu", boxIconRoot.appName, "-", boxIconRoot.title);
					}
				}
			}

			// Badge overlay (notification count, attention state)
			Rectangle {
				id: badge
				visible: boxIconRoot.badgeText !== ""
				
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				
				height: parent.height * 0.55
				width: Math.max(height, badgeLabel.implicitWidth + 4)
				radius: height / 2
				
				color: boxIconRoot.isDemandingAttention ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.highlightColor
				border.color: Kirigami.Theme.backgroundColor
				border.width: 1

				Text {
					id: badgeLabel
					anchors.centerIn: parent
					text: boxIconRoot.badgeText
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					color: Kirigami.Theme.highlightedTextColor
					font.pixelSize: parent.height * 0.9
					font.bold: true
				}
			}
		}

		Repeater {
			model: taskbarBox.iconSources
			BoxIcon {
				visible: iconGrid.showAllIcons
				source: modelData.source
				badgeText: modelData.badgeText
				isDemandingAttention: modelData.isDemandingAttention || false
				appName: modelData.appName || ""
				title: modelData.title || ""
				isActive: modelData.isActive || false
				isMinimized: modelData.isMinimized || false
				activateWindow: modelData.activateWindow
				closeWindow: modelData.closeWindow
				minimizeWindow: modelData.minimizeWindow
			}
		}

		BoxIcon {
			visible: !iconGrid.showAllIcons
			source: iconGrid.showIconsInColumn ? "view-more-symbolic" : "view-more-horizontal-symbolic"
		}
	}

}
