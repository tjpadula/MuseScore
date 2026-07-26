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

    spacing: 0

    FlatButton {
        id: escapeKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
    	margins: 2
		
		text: "Esc"
        icon: IconCode.NONE
  //      icon: IconCode.ESCAPE_META_KEY
        iconFont: ui.theme.toolbarIconsFont

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: root.navigationOrderMin
//        accessible.name: qsTrc("notation", "Escape Meta")

        onPressed: {
            root.metaKeyChange("escape", true)
        }

        onReleased: {
            root.metaKeyChange("escape", false)
        }
    }

    SeparatorLine {
    	Layout.fillHeight: false
        Layout.leftMargin: 2
        Layout.rightMargin: 2
        Layout.topMargin: 4
        Layout.bottomMargin: 7
    	orientation: Qt.Vertical
    	visible: true 
    }

    FlatButton {
        id: shiftKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
    	margins: 2
		
		text: "Shft"
        icon: IconCode.NONE
  //      icon: IconCode.SHIFT_META_KEY
        iconFont: ui.theme.toolbarIconsFont

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: escapeKeyButton.navigation.order + 1
//        accessible.name: qsTrc("notation", "Shift Meta")

        onPressed: {
            root.metaKeyChange("shift", true)
        }

        onReleased: {
            root.metaKeyChange("shift", false)
        }
    }

    SeparatorLine {
    	Layout.fillHeight: false
        Layout.leftMargin: 2
        Layout.rightMargin: 2
        Layout.topMargin: 4
        Layout.bottomMargin: 7
    	orientation: Qt.Vertical
    	visible: true 
    }

    FlatButton {
        id: controlKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
    	margins: 2
		
		text: "Ctrl"
        icon: IconCode.NONE
  //      icon: IconCode.CONTROL_META_KEY
        iconFont: ui.theme.toolbarIconsFont

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: shiftKeyButton.navigation.order + 1
//        accessible.name: qsTrc("notation", "Control Meta")

        onPressed: {
            root.metaKeyChange("control", true)
        }

        onReleased: {
            root.metaKeyChange("control", false)
        }
    }

    SeparatorLine {
    	Layout.fillHeight: false
        Layout.leftMargin: 2
        Layout.rightMargin: 2
        Layout.topMargin: 4
        Layout.bottomMargin: 7
    	orientation: Qt.Vertical
    	visible: true 
    }

    FlatButton {
        id: optionKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
    	margins: 2
		
		text: "Opt"
        icon: IconCode.NONE
  //      icon: IconCode.OPTION_META_KEY
        iconFont: ui.theme.toolbarIconsFont

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: controlKeyButton.navigation.order + 1
//        accessible.name: qsTrc("notation", "Option Meta")

        onPressed: {
            root.metaKeyChange("option", true)
        }

        onReleased: {
            root.metaKeyChange("option", false)
        }
    }

    SeparatorLine {
    	Layout.fillHeight: false
        Layout.leftMargin: 2
        Layout.rightMargin: 2
        Layout.topMargin: 4
        Layout.bottomMargin: 7
    	orientation: Qt.Vertical
    	visible: true 
    }

    FlatButton {
        id: commandKeyButton

		text: "Cmd"
        icon: IconCode.NONE
//       icon: IconCode.COMMAND_META_KEY
        iconFont: ui.theme.toolbarIconsFont

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
    	margins: 2

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: optionKeyButton.navigation.order + 1
//        accessible.name: qsTrc("notation", "Command Meta")

        onPressed: {
            root.metaKeyChange("command", true)
        }

        onReleased: {
            root.metaKeyChange("command", false)
        }
    }
    
    SeparatorLine {
    	Layout.fillHeight: false
        Layout.leftMargin: 2
        Layout.rightMargin: 2
        Layout.topMargin: 4
        Layout.bottomMargin: 7
    	orientation: Qt.Vertical
    	visible: true 
    }

    FlatButton {
        id: deleteKeyButton

		text: "Del"
        icon: IconCode.NONE
//       icon: IconCode.DELETE_META_KEY
        iconFont: ui.theme.toolbarIconsFont

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
    	margins: 2

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: commandKeyButton.navigation.order + 1
//        accessible.name: qsTrc("notation", "Delete Meta")

        onPressed: {
            root.metaKeyChange("delete", true)
        }

        onReleased: {
            root.metaKeyChange("delete", false)
        }
	}
}
