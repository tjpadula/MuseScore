# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-CLA-applies
#
# MuseScore
# Music Composition & Notation
#
# Copyright (C) 2021 MuseScore Limited and others
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

muse_create_module(muse_uicomponents ALIAS muse::uicomponents)

if (BLIBBERHISH)

if (NOT IOS)

# Here's the problem: ${MODULE} is empty, so qt_add_shaders gets confused.
# Maybe none of this belongs here at all, it's almost entirely different
# from Sept9.
	message(STATUS "Adding shaders, MODULE: ${MODULE}")

qt_add_shaders(${MODULE} "${MODULE}_shaders"
    FILES
        "qml/Muse/GraphicalEffects/shaders/roundcorners.frag" )
endif()

endif(BLIBBERHISH)

target_sources(muse_uicomponents PRIVATE
    uicomponentsmodule.cpp
    uicomponentsmodule.h
    view/modelutils.h
    view/topleveldialog.cpp
    view/topleveldialog.h
    view/widgets/radiobuttongroupbox.cpp
    view/widgets/radiobuttongroupbox.h
)

target_link_libraries(muse_uicomponents PRIVATE Qt::Widgets Qt::Quick Qt::QmlIntegration)

if (MUSE_MODULE_UI_QML)
    add_subdirectory(qml/Muse/UiComponents)
    add_subdirectory(qml/Muse/GraphicalEffects)
endif()

if (MUSE_MODULE_UI_API)
    add_subdirectory(api/MuseApi/Controls)
endif()
