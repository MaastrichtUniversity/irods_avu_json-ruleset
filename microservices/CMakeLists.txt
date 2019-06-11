# We are very grateful to Utrecht University for inspiration on CMake procedures
# https://github.com/UtrechtUniversity/irods-uu-microservices (feature branch 4.2.3)

# Note: Microservices for iRODS >= 4.2 need to be built with the compiler and
# standard library provided by iRODS-externals packages.
# The following packages need to be installed to build the irods-microservices:
#
# irods-externals-clang-runtime3.8-0
# irods-externals-clang3.8-0
# irods-externals

# Specify the minimum version for CMake
cmake_minimum_required(VERSION 3.3.0 FATAL_ERROR)

# Set global CMAKE variables
set(MSI_RELEASE_VERSION "2.0.0")

 # Specify iRODS version manually
set(IRODS_VERSION "4.2.6")

# Set additional modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/CMakeModules")

# Set some paths for dependencies from irods-externals
set(BOOST_ROOT "/opt/irods-externals/boost1.60.0-0")
set(IRODS_EXTERNALS_FULLPATH_CLANG /opt/irods-externals/clang3.8-0)
set(JANSSON_ROOT /opt/irods-externals/jansson2.7-0)

# Set compiler options
add_compile_options(-std=c++14
                    -Os
                    -fPIC
                    -DRODS_SERVER
                    -nostdinc++
                    -Wall
                    -Wextra
                    -Wpedantic
                    -Wcast-align
                    -Wredundant-decls
                    -Wuninitialized
                    -Wconversion
                    -Wno-missing-field-initializers
                    -Wno-unused-parameter
                    -Wno-gnu-zero-variadic-macro-arguments)

# Use shared libraries in this project
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -stdlib=libc++")
link_libraries(c++abi)

# Specify which C and C++ compiler to use
set(CMAKE_C_COMPILER ${IRODS_EXTERNALS_FULLPATH_CLANG}/bin/clang)
set(CMAKE_CXX_COMPILER ${IRODS_EXTERNALS_FULLPATH_CLANG}/bin/clang++)

# Set the project's name and which compiler(s) to use
project(irods-microservices C CXX)

# Check installed iRODS version
find_package(IRODS ${IRODS_VERSION} EXACT REQUIRED)
message(STATUS "Building microservices version ${MSI_RELEASE_VERSION} for irods-server version ${IRODS_VERSION}")

# Include the header files into the project
include_directories("${IRODS_EXTERNALS_FULLPATH_CLANG}/include/c++/v1")

find_package(Boost REQUIRED)
include_directories(SYSTEM ${Boost_INCLUDE_DIR})

include_directories("/usr/include/irods")

# Generate the shared Library (= binary) from the source code
# Note: unlike an Executable, a library does not contain a main method. It just contains the classes
add_library(msi_add_avu               SHARED msi_add_avu/msi_add_avu.cpp)
add_library(msi_rmw_avu               SHARED msi_rmw_avu/msi_rmw_avu.cpp)

# Link the generated library to dependency libraries
target_link_libraries(msi_add_avu             LINK_PUBLIC ${Boost_LIBRARIES})
target_link_libraries(msi_rmw_avu             LINK_PUBLIC ${Boost_LIBRARIES})

# Set the location for library installation
install(CODE "MESSAGE(\"Installing microservices to iRODS plugins folder...\")")
install(TARGETS
        msi_add_avu
        msi_rmw_avu
        DESTINATION
        /usr/lib/irods/plugins/microservices)


# Packaging {{{

# Make sure your umask is set correctly when packaging:
# The default umask on CentOS 7 is 0002, which results in e.g. rwxrwxr-x
# directories within generated RPMs, which will conflict with existing
# directories from irods packages, which will be rwxr-xr-x.
# To create packages on CentOS 7, set your umask to 0022 first (`umask 0022`).

set(CPACK_MONOLITHIC_INSTALL 1)
set(CPACK_CMAKE_GENERATOR "Unix Makefiles")

# Run custom CMake module to detect OS family
include(${CMAKE_MODULE_PATH}/DetectOS.cmake)
message(STATUS "Found Linux distro ${DETECTED_OS}")

# Determine which type of package should be generated
if(DETECTED_OS MATCHES "^(Ubuntu|Debian)$")
    set(CPACK_GENERATOR "DEB")
    set(CPACK_PACKAGE_VERSION "${IRODS_VERSION}-${MSI_RELEASE_VERSION}")
elseif(DETECTED_OS MATCHES "^(CentOS|RedHatCompatible)$")
    set(CPACK_GENERATOR "RPM")
    set(CPACK_PACKAGE_VERSION "${IRODS_VERSION}_${MSI_RELEASE_VERSION}")
endif()
message(STATUS "Using CPACK generator ${CPACK_GENERATOR}")

set(CPACK_PACKAGE_NAME "irods_avu_json-microservices")
set(CPACK_PACKAGE_VENDOR "DataHub Maastricht University <datahub@maastrichtuniversity.nl>")
set(CPACK_PACKAGE_CONTACT "DataHub Maastricht University <datahub@maastrichtuniversity.nl>")

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "iRODS microservices for the irods_avu_json project")

set(CPACK_RESOURCE_FILE_README  "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

set(CPACK_RPM_PACKAGE_RELEASE "1")
set(CPACK_RPM_PACKAGE_LICENSE "LGPLv3")
set(CPACK_RPM_PACKAGE_REQUIRES "irods-server = ${IRODS_VERSION}, irods-runtime = ${IRODS_VERSION}, libcurl >= 7.29.0, libxml2 >= 2.9.1, irods-externals-jansson2.7-0 >= 1.0")
set(CPACK_RPM_PACKAGE_URL "https://github.com/MaastrichtUniversity/irods_avu_json-ruleset")
set(CPACK_RPM_PACKAGE_AUTOREQ 0)
set(CPACK_RPM_PACKAGE_AUTOPROV 0)

set(CPACK_DEBIAN_PACKAGE_DEPENDS "irods-server (= ${IRODS_VERSION}), irods-runtime (= ${IRODS_VERSION}), libcurl3 (>= 7.29.0), libxml2 (>= 2.9.1), irods-externals-jansson2.7-0")
set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://github.com/MaastrichtUniversity/irods_avu_json-ruleset")
set(CPACK_DEBIAN_PACKAGE_SECTION "contrib/science")

set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_RPM_PACKAGE_RELEASE}")

include(CPack)
