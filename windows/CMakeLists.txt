# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(shard_xl LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "shard_xl")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# === ShardXL-Lib Rust FFI Configuration ===
set(SHARDXL_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../external/ShardXL-Lib")
set(SHARDXL_LIB_NAME "lighty_launcher")
set(SHARDXL_LIB_OUTPUT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../lib")
set(SHARDXL_LIB_DLL "${SHARDXL_LIB_OUTPUT_DIR}/${SHARDXL_LIB_NAME}.dll")

# Find cargo (Rust compiler)
# Try common installation paths
set(CARGO_SEARCH_PATHS
    "$ENV{USERPROFILE}\\.cargo\\bin"
    "$ENV{HOME}\\.cargo\\bin"
    "C:\\Users\\$ENV{USERNAME}\\.cargo\\bin"
)
find_program(CARGO_EXECUTABLE 
    NAMES cargo 
    PATHS ${CARGO_SEARCH_PATHS}
    DOC "Path to cargo executable"
)
mark_as_advanced(CARGO_EXECUTABLE)

# Build ShardXL-Lib Rust library
# Only build if DLL doesn't exist (to avoid memory/process issues with CMake)
# Users should manually run: cd external/ShardXL-Lib && cargo build --release
if(CARGO_EXECUTABLE AND NOT EXISTS ${SHARDXL_LIB_DLL})
    message(STATUS "Found cargo: ${CARGO_EXECUTABLE}")
    message(STATUS "Building ShardXL-Lib Rust library...")
    
    # Build ShardXL-Lib Rust library
    add_custom_target(build_shardxl_lib
        COMMAND ${CARGO_EXECUTABLE} build --release --manifest-path=${SHARDXL_LIB_DIR}/Cargo.toml
        WORKING_DIRECTORY ${SHARDXL_LIB_DIR}
        COMMENT "Building ShardXL-Lib Rust library"
    )

    # Copy DLL to lib directory (runs after build)
    add_custom_target(copy_shardxl_dll
        COMMAND ${CMAKE_COMMAND} -E make_directory ${SHARDXL_LIB_OUTPUT_DIR}
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${SHARDXL_LIB_DIR}/target/release/${SHARDXL_LIB_NAME}.dll
            ${SHARDXL_LIB_DLL}
        DEPENDS build_shardxl_lib
        COMMENT "Copying ShardXL-Lib DLL to lib directory"
    )
elseif(EXISTS ${SHARDXL_LIB_DLL})
    message(STATUS "ShardXL-Lib DLL found at ${SHARDXL_LIB_DLL}")
    message(STATUS "To rebuild Rust library, run: cd external/ShardXL-Lib && cargo build --release")
    message(STATUS "Then copy: target/release/lighty_launcher.dll -> lib/")
else()
    message(WARNING "cargo not found and DLL not found - ShardXL-Lib will not be available")
    message(WARNING "Install Rust from https://rustup.rs or manually build the DLL")
endif()

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()
# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Make ShardXL-Lib build part of the app build (after target is defined)
if(CARGO_EXECUTABLE AND NOT EXISTS ${SHARDXL_LIB_DLL})
    add_dependencies(${BINARY_NAME} copy_shardxl_dll)
endif()


# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)


# === Installation ===
# Support files are copied into place next to the executable, so that it can
# run in place. This is done instead of making a separate bundle (as on Linux)
# so that building and running from within Visual Studio will work.
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
# Make the "install" step default, as it's required to run.
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/windows/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  CONFIGURATIONS Profile;Release
  COMPONENT Runtime)
