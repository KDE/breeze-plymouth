# SPDX-FileCopyrightText: 2016 Harald Sitter <sitter@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause.

include(FindPkgConfig)

pkg_check_modules(Plymouth ply-boot-client ply-splash-core)
exec_program(${PKG_CONFIG_EXECUTABLE}
    ARGS ply-splash-core --variable=pluginsdir
    OUTPUT_VARIABLE Plymouth_PLUGINSDIR)
exec_program(${PKG_CONFIG_EXECUTABLE}
    ARGS ply-splash-core --variable=themesdir
    OUTPUT_VARIABLE Plymouth_THEMESDIR)

find_package_handle_standard_args(Plymouth
    FOUND_VAR
        Plymouth_FOUND
    REQUIRED_VARS
        Plymouth_LIBRARIES
    VERSION_VAR
        Plymouth_VERSION
    HANDLE_COMPONENTS
)

include(FeatureSummary)
set_package_properties(Plymouth PROPERTIES
    URL "https://www.freedesktop.org/wiki/Software/Plymouth/"
    DESCRIPTION "Plymouth development files."
)
