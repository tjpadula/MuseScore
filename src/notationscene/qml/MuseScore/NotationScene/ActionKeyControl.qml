/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-Studio-CLA-applies
 *
 * MuseScore Studio
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore Limited and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
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
import QtQuick.Window

import Muse.Ui
import Muse.UiComponents

RowLayout {
    id: root

    property var metaKeyState: 0

    property NavigationPanel navigationPanel: null
    property int navigationOrderMin: 0
    readonly property int metaKeyOrderMax: commandKeyButton.navigation.order + 1

    signal metaKeyChange(var metaKeyName, bool state)
    signal sendAction(var inAction)

    spacing: 0

	width: 257
	
    SeparatorLine { orientation: Qt.Vertical; visible: parent.visible }

    FlatButton {
        id: escapeKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
	    implicitWidth: 64
    	margins: 2
		visible: parent.visible		

		text: "\u238B"
        icon: IconCode.NONE
        iconFont: ui.theme.toolbarIconsFont

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: root.navigationOrderMin
//        accessible.name: qsTrc("notation", "Escape Meta")

        onPressed: {
//            root.sendAction("action://cancel")
        }

        onReleased: {
            root.sendAction("action://cancel")
        }
    }

    SeparatorLine {
    	Layout.fillHeight: false
        Layout.leftMargin: 2
        Layout.rightMargin: 2
        Layout.topMargin: 4
        Layout.bottomMargin: 7
    	orientation: Qt.Vertical
		visible: parent.visible		
    }

    FlatButton {
        id: deleteKeyButton

 		text: "\u232B"
        icon: IconCode.NONE
        iconFont: ui.theme.toolbarIconsFont

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
	    implicitWidth: 64
    	margins: 2
		visible: parent.visible		

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: commandKeyButton.navigation.order + 1
//        accessible.name: qsTrc("notation", "Delete Meta")

        onPressed: {
//            root.sendAction("action://delete")
        }

        onReleased: {
            root.sendAction("action://delete")
        }
	}
	
    SeparatorLine { orientation: Qt.Vertical; visible: parent.visible }
}
