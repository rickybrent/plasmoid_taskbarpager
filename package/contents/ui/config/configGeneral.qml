/*
 * Copyright 2013  David Edmundson <davidedmundson@kde.org>
 * Copyright 2016  Eike Hein <hein@kde.org>
 * Copyright 2021-2024  Tino Lorenz <tilrnz@gmx.net>
 * Copyright 2022  Diego Miguel <hello@diegomiguel.me>
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
import QtQuick.Controls as QtControls
import QtQuick.Layouts as QtLayouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
	id: layoutGeneralRoot

	property alias cfg_forceLayout: pagerLayout.currentIndex
	property alias cfg_desktopLabels: desktopLabelsBox.currentIndex
	property alias cfg_enableScrolling: enableScrolling.checked
	property alias cfg_invertScrollDirection: invertScrollDirection.checked
	property alias cfg_wrapPage: wrapPage.checked
	property alias cfg_currentDesktopSelected: currentDesktopSelectedBox.currentIndex
	property alias cfg_actionOnCompactLayout: actionOnCompactLayout.checked
	property alias cfg_compactShowInactive: compactShowInactive.checked
	property alias cfg_showOnlyCurrentScreen: showOnlyCurrentScreen.checked
	property alias cfg_windowCountPerDesktop: windowCountPerDesktop.value
	property alias cfg_pinnedWindowBehavior: pinnedWindowBehaviorBox.currentIndex
	property alias cfg_taskSort: taskSort.currentIndex

	Kirigami.FormLayout {
		id: layoutGeneral

		//anchors.fill: parent
		Item {
			Kirigami.FormData.isSection: true
		}

		QtControls.ComboBox {
			id: desktopLabelsBox
			Kirigami.FormData.label: i18n("Desktop labels:")
			model: [i18n("None"), i18n("Desktop number"), i18n("Desktop name")]
		}

		Item {
			Kirigami.FormData.isSection: true
		}

		QtControls.CheckBox {
			id: enableScrolling
			text: i18n("Enable scrolling to change the active desktop")
			Kirigami.FormData.label: i18n("Scrolling:")
		}

		QtControls.CheckBox {
			id: invertScrollDirection
			text: i18n("Invert scroll direction")
		}

		QtControls.CheckBox {
			id: wrapPage
			enabled: cfg_enableScrolling
			text: i18n("Navigation wraps around")
		}

		Item {
			Kirigami.FormData.isSection: true
		}

		Item {
			Kirigami.FormData.isSection: true
		}

		QtLayouts.RowLayout {
			QtLayouts.Layout.fillWidth: true

			Kirigami.FormData.label: i18n("Layout:")
			QtControls.ComboBox {
				id: pagerLayout
				model: ["Adaptive", "Full", "Compact"]
			}

			QtControls.Button {
				id: infoButton
				icon.name: "dialog-information"
				QtControls.ToolTip.visible: hovered
				QtControls.ToolTip.text: "<b>Adaptive</b>:<br>Switch the layout depending on available space.<br><br>" +
										 "<b>Full</b>:<br>Always show full layout.<br><br>" +
										 "<b>Compact</b>:<br>Always show compact layout."
			}
		}
		

		QtControls.CheckBox {
			id: compactShowInactive
			text: i18n("Show inactive desktop labels in compact layout.")
		}

		Item {
			Kirigami.FormData.isSection: true
		}

		QtControls.ComboBox {
			id: currentDesktopSelectedBox
			Kirigami.FormData.label: i18n("Selecting current virtual desktop:")

			model: ["Does nothing", "Shows the desktop", "Shows overview"]
		}

		QtControls.CheckBox {
			id: actionOnCompactLayout
			text: i18n("Directly do selected action in compact layout\ninstead of expanding full layout")
		}

		Item {
			Kirigami.FormData.isSection: true
		}

		QtControls.ComboBox {
			id: taskSort
			Kirigami.FormData.label: i18n("Window order:")
			model: [i18n("Do not sort"), i18n("Manually"), i18n("Alphabetically"), i18n("By horizontal window position"),  i18n("By vertical window position")]
		}

		Item {
			Kirigami.FormData.isSection: true
		}

		QtControls.SpinBox {
			id: windowCountPerDesktop
			Kirigami.FormData.label: i18n("Windows visible per desktop:")
			from: 0
			to: 10
			stepSize: 1
		}

		QtControls.CheckBox {
			id: showOnlyCurrentScreen
			text: i18n("Show only windows from the current screen.")
		}

		Item {
			Kirigami.FormData.isSection: true
		}

		QtControls.ComboBox {
			id: pinnedWindowBehaviorBox
			Kirigami.FormData.label: i18n("Windows on all desktops:")
			model: [i18n("Show on all desktops"), i18n("Show only on active desktop"), i18n("Show in dedicated Pin section")]
		}		
	}
}
