
if (NOT DEP_BUILD_MESA)
    return()
endif()

# We download the pre-built Mesa binaries for Windows.
# Using pal1000's distribution which is well-maintained and provides 
# the necessary software rendering DLLs for Windows.

if (DEPS_BITS EQUAL 64)
    set(_mesa_arch "x64")
else ()
    set(_mesa_arch "x86")
endif ()

# Ensure we use absolute native paths for Windows to avoid shell confusion 
# with relative paths or mixed slashes (e.g., in CI environments).
get_filename_component(_mesa_dest_abs "${DESTDIR}/usr/local/bin/mesa" ABSOLUTE)
file(TO_NATIVE_PATH "${_mesa_dest_abs}" MESA_INST_DIR)

ExternalProject_Add(dep_Mesa
    URL "https://github.com/pal1000/mesa-dist-win/releases/download/23.3.5/mesa3d-23.3.5-release-msvc.7z"
    URL_HASH SHA256=ce42bee2034f3dbd272f1d658040dfa678c0d8e653f260be8808f4e80f34c06a
    DOWNLOAD_DIR "${DEP_DOWNLOAD_DIR}/Mesa"
    DOWNLOAD_NO_EXTRACT TRUE
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND "${CMAKE_COMMAND}" -E make_directory "${MESA_INST_DIR}"
    # Use 7z for extraction as it's guaranteed to handle .7z and is present on GitHub Runners.
    # We extract during the install step because we're using DOWNLOAD_NO_EXTRACT to avoid 
    # CMake's internal tar limitations with .7z.
    COMMAND 7z x "<DOWNLOADED_FILE>" -y "-o<SOURCE_DIR>"
    COMMAND "${CMAKE_COMMAND}" -E copy "<SOURCE_DIR>/${_mesa_arch}/opengl32.dll" "${MESA_INST_DIR}/opengl32.dll"
    # Modern Mesa versions also need these companion DLLs
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different "<SOURCE_DIR>/${_mesa_arch}/libgallium_wgl.dll" "${MESA_INST_DIR}/libgallium_wgl.dll"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different "<SOURCE_DIR>/${_mesa_arch}/libglapi.dll" "${MESA_INST_DIR}/libglapi.dll"
)
