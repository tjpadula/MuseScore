# Well, well, well, this file is included in the build twice. Yes, we intentionally
# misnamed the directory, because "turbo" doesn't appear anywhere else in the build.
# Ok, and turning off the extra fluidsynth build commands in 
# src/framework/audio/CMakeLists.txt leads to us only being included once. Progress...
message(STATUS "Processing src/framework/audio/thirdparty/turbosynth/CMakeLists.txt")

if (SOMETHING_BROKE_IN_THE_MERGE)

if (NOT IOS)
muse_create_thirdparty_module(fluidsynth)

include(${CMAKE_CURRENT_LIST_DIR}/fluidsynth.cmake)

target_sources(fluidsynth PRIVATE 
    ${FLUIDSYNTH_SRC}
    vorbis_decode.cpp
    )

target_include_directories(fluidsynth PUBLIC ${FLUIDSYNTH_INC})

set (MODULE_INCLUDE_PRIVATE
    ${SNDFILE_INCDIR}
    )

set (MODULE_DEF
    ${FLUIDSYNTH_DEF}
    )
endif()

# IOS_CONFIG_BUG
# This appears to be the place where we link libsndfile.a into the app, way down in
# third-party land. As a hack, add the ogg and vorbis libs here, since we have to do
# the libsndfile.a build outside the Xcodebuild anyway.
if (IOS)
	set(LIBOGG_LIBRARY "${LIBSNDFILE_LIBRARY_SEARCH_PATH}libogg.a")
	set(LIBVORBIS_LIBRARY "${LIBSNDFILE_LIBRARY_SEARCH_PATH}libvorbis.a")
    message(STATUS "Set up libogg.a: ${LIBOGG_LIBRARY}")
    message(STATUS "Set up libvorbis.a: ${LIBVORBIS_LIBRARY}")
endif (IOS)

set(MODULE_LINK
    ${SNDFILE_LIB} ${LIBOGG_LIBRARY} ${LIBVORBIS_LIBRARY}
    )

# Master has this:::
#target_compile_definitions(fluidsynth PUBLIC ${FLUIDSYNTH_DEF})

if (NOT MUSE_ENABLE_UNIT_TESTS_CODE_COVERAGE)
 #   target_compile_definitions(fluidsynth PRIVATE EXTERN_VORBIS_SUPPORT)
endif()
# Master ends here:::

endif(SOMETHING_BROKE_IN_THE_MERGE)

muse_create_thirdparty_module(fluidsynth)

include(${CMAKE_CURRENT_LIST_DIR}/fluidsynth.cmake)

target_sources(fluidsynth PRIVATE 
    ${FLUIDSYNTH_SRC}
    vorbis_decode.cpp
    )

target_include_directories(fluidsynth PUBLIC ${FLUIDSYNTH_INC})

target_compile_definitions(fluidsynth PUBLIC ${FLUIDSYNTH_DEF})

if (NOT MUSE_ENABLE_UNIT_TESTS_CODE_COVERAGE)
    target_compile_definitions(fluidsynth PRIVATE EXTERN_VORBIS_SUPPORT)
endif()

# if (FALSE)
#target_no_warning(fluidsynth -Wunused-const-variable=0)
target_no_warning(fluidsynth -Wno-deprecated)
target_no_warning(fluidsynth -Wno-unused-parameter)
target_no_warning(fluidsynth -Wno-unused-variable)
target_no_warning(fluidsynth -Wno-type-limits)
target_no_warning(fluidsynth -Wno-unknown-pragmas)
target_no_warning(fluidsynth -Wno-conversion)
target_no_warning(fluidsynth -Wno-uninitialized)
target_no_warning(fluidsynth -Wno-deprecated-declarations)
target_no_warning(fluidsynth -WMSVC-no-translation-unit-is-empty)
target_no_warning(fluidsynth -WMSVC-no-nonstandard-extension-used)
target_no_warning(fluidsynth -WMSVC-no-assignment-within-conditional-expression)
target_no_warning(fluidsynth -WMSVC-no-hides-previous)
target_no_warning(fluidsynth -WMSVC-no-undefined-assuming-extern)
target_no_warning(fluidsynth -WMSVC-named-type-definition-in-parentheses)
target_no_warning(fluidsynth -WMSVC-no-different-enum-types)
# endif()

