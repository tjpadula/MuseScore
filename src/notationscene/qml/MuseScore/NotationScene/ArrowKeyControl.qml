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
	
	FlatButton {
        id: leftKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
	    implicitWidth: 64
    	margins: 2
		visible: parent.visible		
		
		text: "\u2190"
        icon: IconCode.NONE
        iconFont: ui.theme.toolbarIconsFont

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: root.navigationOrderMin

        onReleased: {
            root.sendAction("nav-left")
            root.sendAction("notation-move-left")
            root.sendAction("prev-text-element")
        }

        MultiPointTouchArea {
			anchors.fill: parent
			
			minimumTouchPoints: 1
			
			onReleased: (touchPoints) => {
				parent.released()
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
        id: upKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
	    implicitWidth: 64
    	margins: 2
		visible: parent.visible		
		
		text: "\u2191"
        icon: IconCode.NONE
        iconFont: ui.theme.toolbarIconsFont

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: escapeKeyButton.navigation.order + 1

        onReleased: {
            root.sendAction("nav-up")
            root.sendAction("pitch-up")
            root.sendAction("prev-lyric-verse")
            root.sendAction("string-above")            
        }
        
        MultiPointTouchArea {
			anchors.fill: parent
			
			minimumTouchPoints: 1
			
			onReleased: (touchPoints) => {
				parent.released()
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
    	visible: true 
    }

    FlatButton {
        id: downKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
	    implicitWidth: 64
    	margins: 2
		
		text: "\u2193"
        icon: IconCode.NONE
        iconFont: ui.theme.toolbarIconsFont

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: shiftKeyButton.navigation.order + 1

        onReleased: {
            root.sendAction("nav-down")
            root.sendAction("pitch-down")
            root.sendAction("next-lyric-verse")
            root.sendAction("string-below")            
        }

        MultiPointTouchArea {
			anchors.fill: parent
			
			minimumTouchPoints: 1
			
			onReleased: (touchPoints) => {
				parent.released()
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
        id: rightKeyButton

	    buttonType: FlatButton.Horizontal
    	isNarrow: true
	    implicitWidth: 64
    	margins: 2
		visible: parent.visible		
		
		text: "\u2192"
        icon: IconCode.NONE
        iconFont: ui.theme.toolbarIconsFont

        height: 28
        transparent: true

        navigation.panel: root.navigationPanel
        navigation.order: controlKeyButton.navigation.order + 1

        onReleased: {
            root.sendAction("nav-right")
            root.sendAction("notation-move-right")
            root.sendAction("next-text-element")
        }

        MultiPointTouchArea {
			anchors.fill: parent
			
			minimumTouchPoints: 1
			
			onReleased: (touchPoints) => {
				parent.released()
			}
		}
	}

    SeparatorLine { orientation: Qt.Vertical; visible: parent.visible }
}
