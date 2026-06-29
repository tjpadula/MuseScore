include(GetPlatformInfo)

if (OS_IS_WIN AND (NOT MINGW))
    find_path(SNDFILE_INCDIR sndfile.h PATHS ${DEPENDENCIES_INC};)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".lib")
    find_library(SNDFILE_LIB NAMES sndfile libsndfile-1 PATHS ${DEPENDENCIES_LIB_DIR} NO_DEFAULT_PATH)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".dll")
    find_library(SNDFILE_DLL NAMES sndfile libsndfile-1 PATHS ${DEPENDENCIES_LIB_DIR} NO_DEFAULT_PATH)
    message(STATUS "Found sndfile DLL: ${SNDFILE_DLL}")

elseif (OS_IS_WASM)
    set(LIBSND_PATH "" CACHE PATH "Path to libsnd sources")
    set(LIBOGG_PATH "" CACHE PATH "Path to libogg sources")
    set(LIBVORBIS_PATH "" CACHE PATH "Path to libogg sources")
    set(SNDFILE_INCDIR LIBSND_PATH)

    muse_create_thirdparty_module(sndfile)

    target_sources(sndfile PRIVATE
        ${LIBSND_PATH}/sndfile.c
        ${LIBSND_PATH}/sndfile.hh
        ${LIBSND_PATH}/command.c
        ${LIBSND_PATH}/common.c
        ${LIBSND_PATH}/common.h
        ${LIBSND_PATH}/au.c
        ${LIBSND_PATH}/caf.c
        ${LIBSND_PATH}/file_io.c
        ${LIBSND_PATH}/ogg.c
        ${LIBSND_PATH}/ogg_vorbis.c

        #ogg
        ${LIBOGG_PATH}/include/ogg/ogg.h
        ${LIBOGG_PATH}/include/ogg/os_types.h
        ${LIBOGG_PATH}/src/bitwise.c
        ${LIBOGG_PATH}/src/framing.c

        #vorbis
        ${LIBVORBIS_PATH}/lib/vorbisenc.c
        ${LIBVORBIS_PATH}/lib/info.c
        ${LIBVORBIS_PATH}/lib/analysis.c
        ${LIBVORBIS_PATH}/lib/bitrate.c
        ${LIBVORBIS_PATH}/lib/block.c
        ${LIBVORBIS_PATH}/lib/codebook.c
        ${LIBVORBIS_PATH}/lib/envelope.c
        ${LIBVORBIS_PATH}/lib/floor0.c
        ${LIBVORBIS_PATH}/lib/floor1.c
        ${LIBVORBIS_PATH}/lib/lookup.c
        ${LIBVORBIS_PATH}/lib/lpc.c
        ${LIBVORBIS_PATH}/lib/lsp.c
        ${LIBVORBIS_PATH}/lib/mapping0.c
        ${LIBVORBIS_PATH}/lib/mdct.c
        ${LIBVORBIS_PATH}/lib/psy.c
        ${LIBVORBIS_PATH}/lib/registry.c
        ${LIBVORBIS_PATH}/lib/res0.c
        ${LIBVORBIS_PATH}/lib/sharedbook.c
        ${LIBVORBIS_PATH}/lib/smallft.c
        ${LIBVORBIS_PATH}/lib/vorbisfile.c
        ${LIBVORBIS_PATH}/lib/window.c
        ${LIBVORBIS_PATH}/lib/synthesis.c
    )

    target_include_directories(sndfile PRIVATE
        ${LIBSND_PATH}
        ${LIBOGG_PATH}/include
        ${LIBVORBIS_PATH}/include
        ${LIBVORBIS_PATH}/lib
    )

elseif (IOS)

    # IOS_CONFIG_BUG
    # For the moment, we are going to presume a pre-built libsndfile.a. It will be found at
    # ${PROJECT_SOURCE_DIR}/ios_libs/[iphoneos|iphonesimulator]/[arm64|x86_64]/ as appropriate.
    # The header is at ${PROJECT_SOURCE_DIR}/ios_libs/include.
    #
    # For 4.6.0a and later, Qt 6.9 is required, but it doesn't build for arm simulator.
    # However, the Rosetta simulator still works for iOS 16, so we can build to target
    # that on x86_64. Yes, this is silly.
    #
    # Update on 23 June 2026: We may have succeeded in building Qt 6.9.3 for ARM64 simulator,
    # so we're trying that with today's TOT. But, by the time we get to here, CMAKE_OSX_SYSROOT
    # has already been set to iphoneos.
    
    message(STATUS "SetupSndFile.cmake: CMAKE_OSX_SYSROOT: ${CMAKE_OSX_SYSROOT}")
    message(STATUS "SetupSndFile.cmake: ARCH_IS_X86_64: ${ARCH_IS_X86_64}")
    message(STATUS "SetupSndFile.cmake: ARCH_IS_AARCH64: ${ARCH_IS_AARCH64}")
    message(STATUS "SetupSndFile.cmake: QT_HOST_PATH: ${QT_HOST_PATH}")
    message(STATUS "SetupSndFile.cmake: PLATFORM: ${PLATFORM}")
    message(STATUS "SetupSndFile.cmake: CMAKE_OSX_ARCHITECTURES: ${CMAKE_OSX_ARCHITECTURES}")
    message(STATUS "SetupSndFile.cmake: CMAKE_XCODE_SCHEME_ENVIRONMENT: ${CMAKE_XCODE_SCHEME_ENVIRONMENT}")
    
    # The above gives this on arm64 building for Rosetta simulator:
# -- SetupSndFile.cmake: CMAKE_OSX_SYSROOT: iphoneos
# -- SetupSndFile.cmake: ARCH_IS_X86_64:
# -- SetupSndFile.cmake: ARCH_IS_AARCH64: 1
# -- SetupSndFile.cmake: QT_HOST_PATH: ~/Code/qt6-693/qt6-build-mac-x86_64/qtbase
# -- SetupSndFile.cmake: PLATFORM: x86_64
# -- SetupSndFile.cmake: CMAKE_OSX_ARCHITECTURES: x86_64
# -- SetupSndFile.cmake: CMAKE_XCODE_SCHEME_ENVIRONMENT: ARCHS=x86_64

    # Use PLATFORM and ARCH_IS_AARCH64 to determine if we're on arm64 building for Rosetta simulator

    if(CMAKE_OSX_SYSROOT MATCHES "imulator")
        set(LIBSNDFILE_TARGET_OS "iphonesimulator")
    elseif(CMAKE_OSX_SYSROOT MATCHES "phone")
        set(LIBSNDFILE_TARGET_OS "iphoneos")
	else()
        message(FATAL_ERROR "Unable to determine iOS target for libsndfile.")
    endif()

    if (ARCH_IS_X86_64)
        if (LIBSNDFILE_TARGET_OS MATCHES "iphoneos")
            set(LIBSNDFILE_ARCHITECTURE "arm64")
        else()
            set(LIBSNDFILE_ARCHITECTURE "x86_64")
        endif()
    elseif(ARCH_IS_AARCH64)
        # Here is where things get sticky. Arm64 simulator doesn't build for the required
        # version of Qt, so we build it for x86_64 and run the Rosetta simulator.
        # Something somewhere is changing LIBSNDFILE_TARGET_OS to 'iphoneos' before the build
        # gets here. We're done with searching for a needle in a haystack and we're using
        # a workaround.
        #if(LIBSNDFILE_TARGET_OS MATCHES "iphonesimulator")
        if(PLATFORM MATCHES "x86_64")       # We must be building for Rosetta simulator.
            set(LIBSNDFILE_ARCHITECTURE "x86_64")
            set(LIBSNDFILE_TARGET_OS "iphonesimulator")
        else()
            set(LIBSNDFILE_ARCHITECTURE "arm64")
        endif()
    else()
        message(FATAL_ERROR "Unable to determine iOS processor architecture for libsndfile.")
    endif()

    message(STATUS "SetupSndFile.cmake: LIBSNDFILE_TARGET_OS: ${LIBSNDFILE_TARGET_OS}")
    message(STATUS "SetupSndFile.cmake: LIBSNDFILE_ARCHITECTURE: ${LIBSNDFILE_ARCHITECTURE}")

    # Include dir
    set (LIBSNDFILE_INCLUDE_DIR_SEARCH_PATH ${PROJECT_SOURCE_DIR}/ios_libs/include/)
    message(STATUS "LIBSNDFILE_INCLUDE_DIR_SEARCH_PATH: ${LIBSNDFILE_INCLUDE_DIR_SEARCH_PATH}")
 
    set(LIBSNDFILE_INCLUDE_DIR ${LIBSNDFILE_INCLUDE_DIR_SEARCH_PATH})

    # Library
    set (LIBSNDFILE_LIBRARY_SEARCH_PATH ${PROJECT_SOURCE_DIR}/ios_libs/${LIBSNDFILE_TARGET_OS}/${LIBSNDFILE_ARCHITECTURE}/)
    message(STATUS "LIBSNDFILE_LIBRARY_SEARCH_PATH: ${LIBSNDFILE_LIBRARY_SEARCH_PATH}")
    
    set(LIBSNDFILE_LIBRARY "${LIBSNDFILE_LIBRARY_SEARCH_PATH}libsndfile.a")

    if (LIBSNDFILE_LIBRARY AND LIBSNDFILE_INCLUDE_DIR)
        set(SNDFILE_LIB ${LIBSNDFILE_LIBRARY})
        set(SNDFILE_INCDIR ${LIBSNDFILE_INCLUDE_DIR})
        set(SNDFILE_FOUND 1)
        
        target_link_libraries(muse_audio PRIVATE ${LIBSNDFILE_LIBRARY})

        message(STATUS "Found libsndfile: ${LIBSNDFILE_LIBRARY}")
        message(STATUS "Found libsndfile include dir: ${LIBSNDFILE_INCLUDE_DIR_SEARCH_PATH}")
    endif()
    
#        message(FATAL_ERROR "Halt and catch fire.")
 
 else()
    find_package(SndFile)

    if (SNDFILE_FOUND)
        set(SNDFILE_LIB ${SNDFILE_LIBRARY})
        set(SNDFILE_INCDIR ${SNDFILE_INCLUDE_DIR})
    else()
        # Use pkg-config to get hints about paths
        find_package(PkgConfig)
        if(PKG_CONFIG_FOUND)
            pkg_check_modules(LIBSNDFILE_PKGCONF sndfile>=1.0.25 QUIET)
        endif()

        # Include dir
        find_path(LIBSNDFILE_INCLUDE_DIR
            NAMES sndfile.h
            PATHS ${LIBSNDFILE_PKGCONF_INCLUDEDIR}
            NO_DEFAULT_PATH
        )

        # Library
        find_library(LIBSNDFILE_LIBRARY
            NAMES sndfile libsndfile-1
            PATHS ${LIBSNDFILE_PKGCONF_LIBDIR}
            NO_DEFAULT_PATH
        )

        if (LIBSNDFILE_LIBRARY)
            set(SNDFILE_LIB ${LIBSNDFILE_LIBRARY})
            set(SNDFILE_INCDIR ${LIBSNDFILE_INCLUDE_DIR})
        endif()
    endif()
endif()

if (SNDFILE_INCDIR)
    message(STATUS "Found sndfile: ${SNDFILE_LIB} in ${SNDFILE_INCDIR}")
else ()
    message(FATAL_ERROR "Could not find: sndfile")
endif ()
