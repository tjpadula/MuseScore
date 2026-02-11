# set(ENV{QTDIR} "$ENV{HOME}/Qt/6.2.4/ios")

#set(ENV{QTDIR} "$ENV{HOME}/Code/qt6/ios/qtbase")

#message(STATUS "SCRIPT_ARGS: ${SCRIPT_ARGS}")

function(host_uname_machine var)
    execute_process(COMMAND uname -m
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_VARIABLE ${var})
    set(${var} ${${var}} PARENT_SCOPE)
endfunction()

host_uname_machine(UNAME_MACHINE)

# Go through script args to find QT_HOST_PATH:
set(i "1")
list(LENGTH SCRIPT_ARGS nargs)
while(i LESS "${nargs}")
    list(GET SCRIPT_ARGS "${i}" ARG)
    
    if (ARG MATCHES "QT_HOST_PATH")
        #message(STATUS "Arg for QT_HOST_PATH: ${ARG}")
        string(REPLACE "-DQT_HOST_PATH=" "" GIVEN_QT_HOST_PATH "${ARG}")
        message(STATUS "GIVEN_QT_HOST_PATH: ${GIVEN_QT_HOST_PATH}")
        break()
    endif()
    math(EXPR i "${i} + 1") # next argument
endwhile()


# Go through the script args to find CMAKE_OSX_SYSROOT:
set(i "1")
list(LENGTH SCRIPT_ARGS nargs)
while(i LESS "${nargs}")
    list(GET SCRIPT_ARGS "${i}" ARG)
    
    if (ARG MATCHES "CMAKE_OSX_SYSROOT")
        set(GIVEN_CMAKE_OSX_SYSROOT ${ARG})
        break()
    endif()
    math(EXPR i "${i} + 1") # next argument
endwhile()

if (GIVEN_CMAKE_OSX_SYSROOT MATCHES "iphoneos")
    set(ENV{QTDIR} "${GIVEN_QT_HOST_PATH}/../../qt6-build-ios-device-arm64/qtbase")
elseif(GIVEN_CMAKE_OSX_SYSROOT MATCHES "iphonesimulator")
    set(ENV{QTDIR} "${GIVEN_QT_HOST_PATH}/../../qt6-build-ios-simulator-${UNAME_MACHINE}/qtbase")
elseif(GIVEN_CMAKE_OSX_SYSROOT MATCHES "macosx")
    set(ENV{QTDIR} "${GIVEN_QT_HOST_PATH}/../../qt6-build-mac-${UNAME_MACHINE}-nonstatic/qtbase")
#    set(ENV{QTDIR} "${GIVEN_QT_HOST_PATH}/../../qt6-build-mac-${UNAME_MACHINE}/qtbase")
else()
# fixme: Make sure we can use the mac dir for mac builds.
    message(FATAL_ERROR "build_overrides.cmake is not set up for this sysroot. Unknown CMAKE_OSX_SYSROOT: ${ARG}")
endif()

if ( NOT DEFINED ENV{QTDIR} OR ENV{QTDIR} STREQUAL "" )
    set(ENV{QTDIR} "${GIVEN_QT_HOST_PATH}/../../qt6-build-mac-${UNAME_MACHINE}/qtbase")
endif ()

#        message(STATUS "iOS ENV{QTDIR}: $ENV{QTDIR}")

message(STATUS "ENV{QTDIR}: $ENV{QTDIR}")

set(QTDIR "${GIVEN_QT_HOST_PATH}/../qtbase")
