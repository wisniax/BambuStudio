
if (NOT DEP_BUILD_MESA)
    return()
endif()

# We download the pre-built Mesa binaries for Windows.
# Using pal1000's distribution which is well-maintained and provides 
# the necessary software rendering DLLs for Windows.
#
# NOTE: Compiling Mesa from source on Windows is a complex process requiring 
# Meson, Ninja, LLVM, and other dependencies not currently in the project's 
# dependency tree. Using these trusted pre-built binaries is the standard 
# approach for providing a software fallback in this application.

if (DEPS_BITS EQUAL 64)
    set(_mesa_arch "x64")
else ()
    set(_mesa_arch "x86")
endif ()

# Modern Windows tar (since Win10 1803) supports extracting .7z files.
ExternalProject_Add(dep_Mesa
    URL "https://github.com/pal1000/mesa-dist-win/releases/download/23.3.5/mesa3d-23.3.5-release-msvc.7z"
    URL_HASH SHA256=ce42bee2034f3dbd272f1d658040dfa678c0d8e653f260be8808f4e80f34c06a
    DOWNLOAD_DIR ${DEP_DOWNLOAD_DIR}/Mesa
    DOWNLOAD_NO_EXTRACT TRUE
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${DESTDIR}/usr/local/bin/mesa
    COMMAND ${CMAKE_COMMAND} -E tar xf <DOWNLOADED_FILE>
    COMMAND ${CMAKE_COMMAND} -E copy ${_mesa_arch}/opengl32.dll ${DESTDIR}/usr/local/bin/mesa/opengl32.dll
    # Optional: Newer Mesa versions might need these as well
    # COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_mesa_arch}/libgallium_wgl.dll ${DESTDIR}/usr/local/bin/mesa/libgallium_wgl.dll
    # COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_mesa_arch}/libglapi.dll ${DESTDIR}/usr/local/bin/mesa/libglapi.dll
    WORKING_DIRECTORY <SOURCE_DIR>
)
