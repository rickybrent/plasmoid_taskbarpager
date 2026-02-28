/*
 * Copyright 2021-2024  Tino Lorenz <tilrnz@gmx.net>
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


RowLayout {
	id: reprLayout
	Layout.alignment: Qt.AlignTop
	property bool isFullRep: true
	spacing: 3

	property color bgColorHighlight: plasmoid.configuration.activeBgColorChecked ?
		plasmoid.configuration.activeBgColor : Kirigami.Theme.backgroundColor

	property color fontColor: plasmoid.configuration.fontColorChecked ? 
			plasmoid.configuration.fontColor : Kirigami.Theme.textColor

	// Dim backgrounds of all but current desktop
	property color bgColor: plasmoid.configuration.inactiveBgColorChecked ?
		plasmoid.configuration.inactiveBgColor :
		Qt.rgba(
			Math.max(0, bgColorHighlight.r * 0.5),
			Math.max(0, bgColorHighlight.g * 0.5),
			Math.max(0, bgColorHighlight.b * 0.5),
			bgColorHighlight.a
		)
	property color bgColorWithoutWindows: plasmoid.configuration.inactiveBgColorWithoutWindowsChecked ?
		plasmoid.configuration.inactiveBgColorWithoutWindows : bgColor
	property color borderColorHighlight: plasmoid.configuration.sameBorderColorAsFont ? 
			fontColor : plasmoid.configuration.borderColor

	// Dim borders of all but current desktop
	property color borderColor: Qt.rgba(
		Math.max(0, borderColorHighlight.r - 0.4),
		Math.max(0, borderColorHighlight.g - 0.4),
		Math.max(0, borderColorHighlight.b - 0.4),
		borderColorHighlight.a
	)

	function modelColumns() {
		return Math.ceil(pagerModel.count / pagerModel.layoutRows)
	}

	// if we have the space to lay the desktops out like the model says
	function properLayoutFits(cols) {
		let pinnedCols = plasmoid.configuration.pinnedWindowBehavior === 2 ? 1 : 0
		let wantedWidth = 25 * (cols + pinnedCols)
		let wantedHeight = 25 * pagerModel.layoutRows
		return width >= wantedWidth && height >= wantedHeight
	}

	function handleDesktopClick(targetIndex) {
		if (targetIndex === pagerModel.currentPage) {
			if (reprLayout.shouldShowFullLayout || plasmoid.configuration.actionOnCompactLayout) {
				switch (plasmoid.configuration.currentDesktopSelected) {
					case 0: break;
					case 1: pagerModel.changePage(pagerModel.currentPage); break;
					case 2: runOverview(); break;
				}
				root.expanded = false;
			} else {
				root.expanded = !root.expanded;
			}
		} else {
			pagerModel.changePage(targetIndex);
			root.expanded = false;
		}
	}

	property bool shouldShowFullLayout: {
		if (isFullRep) {
			return true
		}
		switch (plasmoid.configuration.forceLayout) {
			case 0: return properLayoutFits(modelColumns()) // adaptive
			case 1: return true // full
			case 2: return false // compact
		}
	}

	// Map tasks for the repeater.
	// TODO: check if there's a better way to do this now since we're writing a cpp plugin anyway.
	component TaskMapper : Item {
		id: mapperRoot
		property var tasksModel: null
		property int pageIndex: 0
		property bool onlyPinned: false
		property bool excludePinned: false

		property list<var> taskWindows: {
			const result = [];
			for (let i = 0; i < proxyRepeater.count; i++) {
				const taskProxy = proxyRepeater.itemAt(i);
				if (!taskProxy) continue;
				if (onlyPinned && !taskProxy.isOnAllVirtualDesktops) continue;
				if (!onlyPinned &&plasmoid.configuration.pinnedWindowBehavior === 1 && taskProxy.isOnAllVirtualDesktops && index !== pagerModel.currentPage) continue;
				if (excludePinned && taskProxy.isOnAllVirtualDesktops) continue;

				let badgeString = "";
				const numberMatch = taskProxy.title.match(/\((\d+)\)/);
				if (numberMatch) {
					badgeString = numberMatch[1];
				} else if (taskProxy.title.startsWith("•") || taskProxy.title.endsWith("•")) {
					badgeString = "•";
				} else if (taskProxy.isDemandingAttention) {
					badgeString = "!";
				}
				result.push({
					source: taskProxy.iconSource,
					title: taskProxy.title,
					appName: taskProxy.appName,
					badgeText: badgeString,
					isDemandingAttention: taskProxy.isDemandingAttention,
					isActive: taskProxy.isActive,
					sourcePage: pageIndex,

					isClosable: taskProxy.isClosable,
					isMovable: taskProxy.isMovable,
					isResizable: taskProxy.isResizable,
					isMinimized: taskProxy.isMinimized,
					isMinimizable: taskProxy.isMinimizable,
					isMaximized: taskProxy.isMaximized,
					isMaximizable: taskProxy.isMaximizable,

					virtualDesktops: taskProxy.virtualDesktops,
					launcherUrlWithoutIcon: taskProxy.launcherUrlWithoutIcon,

					isFullScreen: taskProxy.isFullScreen,
					isFullScreenable: taskProxy.isFullScreenable,
					isShaded: taskProxy.isShaded,
					isShadeable: taskProxy.isShadeable,
					hasNoBorder: taskProxy.hasNoBorder,
					canSetNoBorder: taskProxy.canSetNoBorder,
					canLaunchNewInstance: taskProxy.canLaunchNewInstance,
					isExcludedFromCapture: taskProxy.isExcludedFromCapture,
					isOnAllVirtualDesktops: taskProxy.isOnAllVirtualDesktops,
					isKeepAbove: taskProxy.isKeepAbove,
					isKeepBelow: taskProxy.isKeepBelow,

					activateWindow: () => {
						pagerModel.changePage(pageIndex);
						mapperRoot.tasksModel.requestActivate(mapperRoot.tasksModel.index(i, 0)); 
					},
					closeWindow: () => {
						mapperRoot.tasksModel.requestClose(mapperRoot.tasksModel.index(i, 0));
					},
					minimizeWindow: () => {
						mapperRoot.tasksModel.requestToggleMinimized(mapperRoot.tasksModel.index(i, 0));
					},
					maximizeWindow: () => {
						mapperRoot.tasksModel.requestToggleMaximized(mapperRoot.tasksModel.index(i, 0));
					},
					toggleKeepAbove: () => {
						mapperRoot.tasksModel.requestToggleKeepAbove(mapperRoot.tasksModel.index(i, 0));
					},
					toggleKeepBelow: () => {
						mapperRoot.tasksModel.requestToggleKeepBelow(mapperRoot.tasksModel.index(i, 0));
					},
					newInstance: () => {
						mapperRoot.tasksModel.requestNewInstance(mapperRoot.tasksModel.index(i, 0));
					},
					resize: () => {
						// Interactive window resize.
						mapperRoot.tasksModel.requestResize(mapperRoot.tasksModel.index(i, 0));
					},
					move: () => {
						// Interactive window move.
						mapperRoot.tasksModel.requestMove(mapperRoot.tasksModel.index(i, 0));
					},
					toggleFullScreen: () => {
						mapperRoot.tasksModel.requestToggleFullScreen(mapperRoot.tasksModel.index(i, 0));
					},
					toggleShaded: () => {
						mapperRoot.tasksModel.requestToggleShaded(mapperRoot.tasksModel.index(i, 0));
					},
					toggleNoBorder: () => {
						mapperRoot.tasksModel.requestToggleNoBorder(mapperRoot.tasksModel.index(i, 0));
					},
					toggleExcludeFromCapture: () => {
						mapperRoot.tasksModel.requestToggleExcludeFromCapture(mapperRoot.tasksModel.index(i, 0));
					},
					togglePinToAllDesktops: () => {
						if (taskProxy.isOnAllVirtualDesktops) {
							mapperRoot.tasksModel.requestVirtualDesktopPage(mapperRoot.tasksModel.index(i, 0), pageIndex);
						} else {
							mapperRoot.tasksModel.requestVirtualDesktops(mapperRoot.tasksModel.index(i, 0), []);
						}
					},
					moveWindowToDesktopPage: (page) => {
						mapperRoot.tasksModel.requestVirtualDesktopPage(mapperRoot.tasksModel.index(i, 0), page);
					}
				});
			}
			return result;
		}

		Repeater {
			id: proxyRepeater
			model: mapperRoot.tasksModel
			Item {
				visible: false
				property var iconSource: model.decoration
				property string title: model.display || ""
				property string appName: model.AppName || ""
				property bool isDemandingAttention: model.IsDemandingAttention
				property bool isActive: model.IsActive

				property bool isClosable: model.IsClosable
				property bool isMovable: model.IsMovable
				property bool isResizable: model.IsResizable
				property bool isMinimized: model.IsMinimized
				property bool isMinimizable: model.IsMinimizable
				property bool isMaximized: model.IsMaximized
				property bool isMaximizable: model.IsMaximizable

				property var virtualDesktops: model.VirtualDesktops
				property string launcherUrlWithoutIcon: model.LauncherUrlWithoutIcon || ""

				property bool isFullScreen: model.IsFullScreen
				property bool isFullScreenable: model.IsFullScreenable
				property bool isShaded: model.IsShaded
				property bool isShadeable: model.IsShadeable
				property bool hasNoBorder: model.HasNoBorder
				property bool canSetNoBorder: model.CanSetNoBorder
				property bool canLaunchNewInstance: model.CanLaunchNewInstance
				property bool isExcludedFromCapture: model.IsExcludedFromCapture
				property bool isOnAllVirtualDesktops: model.IsOnAllVirtualDesktops
				property bool isKeepAbove: model.IsKeepAbove
				property bool isKeepBelow: model.IsKeepBelow
			}
		}
	}


	TaskbarBox {
		id: pinnedBox
		visible: plasmoid.configuration.pinnedWindowBehavior === 2
		text: "🖈"
		
		Layout.fillWidth: false
		Layout.fillHeight: true
		Layout.minimumWidth: implicitWidth
		Layout.preferredHeight: implicitHeight 
		Layout.minimumHeight: 25
		Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

		color: bgColorWithoutWindows
		border.color: borderColor

		// Fetch the TasksModel from the first regular virtual desktop to get the master list
		TaskMapper {
			id: pinnedMapper
			tasksModel: dRep.count > 0 && dRep.itemAt(0) ? dRep.itemAt(0).desktopTasksModel : null
			pageIndex: pagerModel.currentPage
			onlyPinned: true
		}
		DropArea {
			anchors.fill: parent
			onDropped: (drop) => {
				if (drop.source && drop.source.moveWindowToDesktopPage) {
					drop.source.visible = false
					drop.source.togglePinToAllDesktops()
					drop.accept();
				}
			}
		}
		onDesktopClicked: {
			handleDesktopClick(pagerModel.currentPage);
		}

		taskWindows: pinnedMapper.taskWindows
		targetWindowCount: taskWindows.length
	}


	GridLayout {
		id: pagerGrid
		Layout.fillWidth: true
		Layout.fillHeight: true
		Layout.alignment: Qt.AlignTop
		rowSpacing: 0
		columnSpacing: 3

		columns: {
			let cols = modelColumns()
			switch (Plasmoid.formFactor) {
				case 2: { // horizontal
					let availableRows = Math.floor(height / 25)
					let targetRows = Math.max(Math.min(availableRows, pagerModel.layoutRows), 1)
					return Math.ceil(pagerModel.count / targetRows)
				}
				case 3: { // vertical
					let availableColumns = Math.floor(width / 25)
					return Math.max(Math.min(availableColumns, cols), 1)
				}
				default:
					return cols
			}
		}

		Repeater {
			id: dRep
			model: pagerModel

			TaskbarBox {
				id: tBox
				// Expose this so the PinnedBox can grab it
				property var desktopTasksModel: TasksModel

				visible: reprLayout.shouldShowFullLayout || index === pagerModel.currentPage
				text: (plasmoid.configuration.showDesktopNames && model.display != "") ? model.display : index + 1
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.minimumWidth: implicitWidth
				Layout.preferredHeight: implicitHeight 
				Layout.minimumHeight: 25
				Layout.preferredWidth: Math.max(implicitWidth, height)
				Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

				TaskMapper {
					id: taskMapper
					tasksModel: tBox.desktopTasksModel
					pageIndex: index
					excludePinned: plasmoid.configuration.pinnedWindowBehavior === 2
				}

				taskWindows: taskMapper.taskWindows

				//highlight the current desktop
				color: index === pagerModel.currentPage ? bgColorHighlight : ((taskMapper.taskWindows.length > 0) ? bgColor : bgColorWithoutWindows)
				border.color: index === pagerModel.currentPage ? borderColorHighlight : borderColor

				onDesktopClicked: {
					handleDesktopClick(index);
				}

				DropArea {
					anchors.fill: parent
					onDropped: (drop) => {
						if (drop.source && drop.source.moveWindowToDesktopPage) {
							if (drop.source.sourcePage !== index) {
								drop.source.visible = false
							}
							drop.source.moveWindowToDesktopPage(index);
							drop.accept();
						}
					}
				}
			}
		}
	}
}
