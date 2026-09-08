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

    SeparatorLine { orientation: Qt.Vertical; visible: parent.visible }

    FlatButton {
        id: commandKeyButton

 		text: "\u2318"
        icon: IconCode.NONE
        iconFont: ui.theme.toolbarIconsFont
		visible: parent.visible		

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
	    implicitWidth: 64
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
        
        MultiPointTouchArea {
			anchors.fill: parent
			
			// This stops Qt from converting the touch to a mouse point 
			// for underlying or parent items.
			minimumTouchPoints: 1
			
			onPressed: (touchPoints) => {
				commandKeyButton.pressed()
			}
			onReleased: (touchPoints) => {
				commandKeyButton.released()
			}
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
        id: optionKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
	    implicitWidth: 64
    	margins: 2
		visible: parent.visible		
		
		text: "\u2325"
        icon: IconCode.NONE
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

        MultiPointTouchArea {
			anchors.fill: parent
			
			// This stops Qt from converting the touch to a mouse point 
			// for underlying or parent items.
			minimumTouchPoints: 1
			
			onPressed: (touchPoints) => {
				optionKeyButton.pressed()
			}
			onReleased: (touchPoints) => {
				optionKeyButton.released()
			}
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
        id: controlKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
	    implicitWidth: 64
    	margins: 2
		visible: parent.visible		
		
		text: "\u2303"
        icon: IconCode.NONE
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

        MultiPointTouchArea {
			anchors.fill: parent
			
			// This stops Qt from converting the touch to a mouse point 
			// for underlying or parent items.
			minimumTouchPoints: 1
			
			onPressed: (touchPoints) => {
				controlKeyButton.pressed()
			}
			onReleased: (touchPoints) => {
				controlKeyButton.released()
			}
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
        id: shiftKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
	    implicitWidth: 64
    	margins: 2
		visible: parent.visible		
		
		text: "\u21E7"
        icon: IconCode.NONE
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

        MultiPointTouchArea {
			anchors.fill: parent
			
			// This stops Qt from converting the touch to a mouse point 
			// for underlying or parent items.
			minimumTouchPoints: 1
			
			onPressed: (touchPoints) => {
				shiftKeyButton.pressed()
			}
			onReleased: (touchPoints) => {
				shiftKeyButton.released()
			}
		}
    }
   
	SeparatorLine { orientation: Qt.Vertical; visible: parent.visible }
}
