# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
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
# along with this program. If not, see <https://www.gnu.org/licenses/>.

muse_create_module(muse_shortcuts ALIAS muse::shortcuts)

set(MODULE_QRC shortcuts.qrc)

target_sources(muse_shortcuts PRIVATE
    shortcutsmodule.cpp
    shortcutsmodule.h
    shortcutstypes.h
    shortcutcontext.h
    ishortcutsregister.h
    ishortcutscontroller.h
    ishortcutsconfiguration.h
    imidiremote.h

    api/shortcutsapi.cpp
    api/shortcutsapi.h

    internal/shortcutsregister.cpp
    internal/shortcutsregister.h
    internal/shortcutscontroller.cpp
    internal/shortcutscontroller.h
    internal/shortcutsconfiguration.cpp
    internal/shortcutsconfiguration.h
    internal/midiremote.cpp
    internal/midiremote.h
)

if (OS_IS_MAC)

# IOS_CONFIG_BUG
if(IOS)
    message(STATUS "Bypassing CARBON_LIBRARY for iOS.")

else(IOS)
    find_library(CARBON_LIBRARY Carbon)

    set(MODULE_SRC ${MODULE_SRC}
        ${CMAKE_CURRENT_LIST_DIR}/internal/platform/macos/macosshortcutsinstancemodel.mm
        ${CMAKE_CURRENT_LIST_DIR}/internal/platform/macos/macosshortcutsinstancemodel.h
    )

    set_source_files_properties(
        ${CMAKE_CURRENT_LIST_DIR}/internal/platform/macos/macosshortcutsinstancemodel.mm
        PROPERTIES
        SKIP_UNITY_BUILD_INCLUSION ON
        SKIP_PRECOMPILE_HEADERS ON
    )

    set(MODULE_INCLUDE_PRIVATE
        ${CARBON_LIBRARY}
    )

endif(IOS)

target_link_libraries(muse_shortcuts PRIVATE Qt::Gui)

if (MUSE_MODULE_SHORTCUTS_QML)
    add_subdirectory(qml/Muse/Shortcuts)
endif()

else (OS_IS_MAC)

target_link_libraries(muse_shortcuts PRIVATE Qt::Gui)

if (MUSE_MODULE_SHORTCUTS_QML)
    add_subdirectory(qml/Muse/Shortcuts)
endif()

endif(OS_IS_MAC)

