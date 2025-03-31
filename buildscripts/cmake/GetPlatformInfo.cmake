# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2023 MuseScore Limited
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

if (PLATFORM_DETECTED)
    return()
endif()

if(${CMAKE_CXX_COMPILER} MATCHES "/em\\+\\+(-[a-zA-Z0-9.])?$")
    set(OS_IS_WASM 1)
elseif(${CMAKE_HOST_SYSTEM_NAME} MATCHES "Windows")
    set(OS_IS_WIN 1)
elseif(${CMAKE_HOST_SYSTEM_NAME} MATCHES "Linux")
    set(OS_IS_LIN 1)
elseif(${CMAKE_HOST_SYSTEM_NAME} MATCHES "FreeBSD")
    set(OS_IS_FBSD 1)
elseif(${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
    set(OS_IS_MAC 1)
else()
    message(FATAL_ERROR "Unsupported platform: ${CMAKE_HOST_SYSTEM_NAME}")
endif()

# architecture detection
# based on QT5 processor detection code
# qtbase/blobs/master/src/corelib/global/qprocessordetection.h

# we only have binary blobs compatible with x86_64, aarch64, and armv7l

# IOS_CONFIG_BUG
# This "program" used to always print the last error 'unknown' no matter what,
# which leads to the system falling back to x86_64. So we fixed it.
set(archdetect_c_code "
    #if defined(__arm__) || defined(__TARGET_ARCH_ARM) || defined(_M_ARM) || defined(__aarch64__) || defined(__ARM64__)
        #if defined(__aarch64__) || defined(__ARM64__)
            #error cmake_ARCH aarch64
        #elif defined(__ARM_ARCH_7A__)
            #error cmake_ARCH armv7l
        #endif
    #elif defined(__x86_64) || defined(__x86_64__) || defined(__amd64) || defined(_M_X64)
        #error cmake_ARCH x86_64
    #else
        #error cmake_ARCH unknown
    #endif
    ")

if(CMAKE_C_COMPILER_LOADED)
    set(TA_EXTENSION "c")
elseif(CMAKE_CXX_COMPILER_LOADED)
    set(TA_EXTENSION "cpp")
elseif(CMAKE_FORTRAN_COMPILER_LOADED)
    set(TA_EXTENSION "F90")
else()
    message(FATAL_ERROR "You must enable a C, CXX, or Fortran compiler to use TargetArch.cmake")
endif()

file(WRITE "${CMAKE_BINARY_DIR}/arch.${TA_EXTENSION}" "${archdetect_c_code}")

#message(STATUS "Running test app: ${CMAKE_BINARY_DIR}/arch.${TA_EXTENSION}")

try_run(
    run_result_unused
    compile_result_unused
    "${CMAKE_BINARY_DIR}"
    "${CMAKE_BINARY_DIR}/arch.${TA_EXTENSION}"
    COMPILE_OUTPUT_VARIABLE ARCH
    CMAKE_FLAGS ${TA_CMAKE_FLAGS}
)

#message (STATUS "COMPILE_OUTPUT_VARIABLE: ARCH=${ARCH}")
#message (STATUS "CMAKE_FLAGS: TA_CMAKE_FLAGS=${TA_CMAKE_FLAGS}")

string(REGEX MATCH "cmake_ARCH ([a-zA-Z0-9_]+)" ARCH "${ARCH}")

string(REPLACE "cmake_ARCH " "" ARCH "${ARCH}")

# IOS_CONFIG_BUG
# The above applet gets run with the compiler being told which CPU to use, so it always
# indicates that both x86_64 and aarm64 are available. The two run in parallel, so the
# answer we get depends on a race condition. Since we're on an M1, we spike the CPU:
#set(ARCH "aarch64")
set(ARCH "x86_64")

message(STATUS "Detected CPU Architecture: ${ARCH}")

if(${ARCH} MATCHES "armv7l")
    set(ARCH_IS_ARMV7L 1)
elseif(${ARCH} MATCHES "aarch64")
    set(ARCH_IS_AARCH64 1)
elseif(${ARCH} MATCHES "x86_64")
    set(ARCH_IS_X86_64 1)
else()
    set(ARCH_IS_X86_64 1)
    message(WARNING "Architecture could not be detected. Using x86_64 as a fallback.")
endif()

set(PLATFORM_DETECTED 1)
