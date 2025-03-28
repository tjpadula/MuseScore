
include(GetUtilsFunctions) # library of CMake functions ("fn__" namespace)

message(STATUS "PATH: $ENV{PATH}")
# Print Qt version or fail the build if Qt (qmake) is not in PATH.
fn__require_program(QMAKE Qt --version "https://musescore.org/en/handbook/developers-handbook/compilation" qmake6 qmake)

# IOS_CONFIG_BUG
if(IOS)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
else(IOS)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
endif(IOS)

# IOS_CONFIG_BUG
# We removed LinguistTools from this list, as it's not available on iOS.
# We removed PrintSupport because there's no real printing from iOS. Perhaps at some
# point when we will want to print to PDF, we may need it then.

set(_components
    Core
    Gui
    Widgets
    Network
    NetworkAuth
    Qml
    Xml
    OpenGL
    Core5Compat
    Quick
    QuickControls2
    QuickTemplates2
    QuickWidgets
    Svg

)

if (NOT (OS_IS_MAC AND IOS))
    set(_components
        ${_components}
        LinguistTools
        PrintSupport
    )
endif()

if (NOT OS_IS_WASM)
    set(_components
        ${_components}
        Concurrent
    )
endif()

if (OS_IS_LIN)
    set(_components
        ${_components}
        DBus
    )
endif()

if (QT_ADD_STATEMACHINE)
    set(_components ${_components}
        # Note: only used in ExampleView class.
        # When that class is removed, don't forget to remove this dependency.
        StateMachine
    )
endif()

if (QT_ADD_WEBSOCKET)
    set(_components ${_components}
        WebSockets
    )
endif()

foreach(_component ${_components})
    
    message(STATUS "    CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
    find_package(Qt6${_component} REQUIRED NO_CMAKE_FIND_ROOT_PATH)
    message(STATUS "    Qt6${_component}_DIR: ${Qt6${_component}_DIR}")

    list(APPEND QT_LIBRARIES ${Qt6${_component}_LIBRARIES})
    list(APPEND QT_INCLUDES ${Qt6${_component}_INCLUDE_DIRS})
    add_definitions(${Qt6${_component}_DEFINITIONS})
endforeach()

include_directories(${QT_INCLUDES})

find_program(QT_QMAKE_EXECUTABLE qmake)
set(_qmake_vars
    QT_INSTALL_ARCHDATA
    QT_INSTALL_BINS
    QT_INSTALL_CONFIGURATION
    QT_INSTALL_DATA
    QT_INSTALL_DOCS
    QT_INSTALL_EXAMPLES
    QT_INSTALL_HEADERS
    QT_INSTALL_IMPORTS
    QT_INSTALL_LIBEXECS
    QT_INSTALL_LIBS
    QT_INSTALL_PLUGINS
    QT_INSTALL_PREFIX
    QT_INSTALL_QML
    QT_INSTALL_TESTS
    QT_INSTALL_TRANSLATIONS
)
foreach(_var ${_qmake_vars})
    execute_process(COMMAND ${QT_QMAKE_EXECUTABLE} "-query" ${_var}
        RESULT_VARIABLE _return_val
        OUTPUT_VARIABLE _out
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(_return_val EQUAL 0)
        set(${_var} "${_out}")
    endif(_return_val EQUAL 0)
endforeach(_var)

#add_definitions(-DQT_DISABLE_DEPRECATED_BEFORE=0)
