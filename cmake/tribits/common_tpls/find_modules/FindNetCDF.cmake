# -*- mode: cmake -*-
# @HEADER
# *****************************************************************************
#            TriBITS: Tribal Build, Integrate, and Test System
#
# Copyright 2013-2016 NTESS and the TriBITS contributors.
# SPDX-License-Identifier: BSD-3-Clause
# *****************************************************************************
# @HEADER
#
# Based on the MSTK NetCDF Find Module which is from Amanzi open
# source code https://software.lanl.gov/ascem/trac #
# Usage:
#    Control the search through NetCDF_DIR or setting environment variable
#    NetCDF_ROOT to the NetCDF installation prefix.
#
#    This module does not search default paths!
#
#    Following variables are set:
#    NetCDF_FOUND            (BOOL)       Flag indicating if NetCDF was found
#    NetCDF_INCLUDE_DIR      (PATH)       Path to the NetCDF include file
#    NetCDF_INCLUDE_DIRS     (LIST)       List of all required include files
#    NetCDF_LIBRARY_DIR      (PATH)       Path to the NetCDF library
#    NetCDF_LIBRARY          (FILE)       NetCDF library
#    NetCDF_LIBRARIES        (LIST)       List of all required NetCDF libraries
#
#    Additional variables set
#    NetCDF_C_LIBRARY        (FILE)       NetCDF C library
#    NetCDF_CXX_LIBRARY      (FILE)       NetCDF C++ library
#
# #############################################################################

# Standard CMake modules see CMAKE_ROOT/Modules
include(FindPackageHandleStandardArgs)

# MSTK CMake functions see <root>/cmake/modules for source
include(AddPackageDependency)

if ( NetCDF_LIBRARIES AND NetCDF_INCLUDE_DIRS )

    # Do nothing. Variables are set. No need to search again

else()

    # If NetCDF_ROOT was defined in the environment, use it.
    # Definition from the command line will take precedence.
    if (NOT NetCDF_ROOT AND NOT $ENV{NetCDF_ROOT} STREQUAL "")
      set(NetCDF_ROOT $ENV{NetCDF_ROOT})
    endif()

    # NetCDF_DIR is DEPRECATED WARN THE USER if it is set
    if (NOT NetCDF_ROOT AND NetCDF_DIR )
      message(WARNING "The configuration parameter NetCDF_DIR is deprecated."
                      " Please use NetCDF_ROOT instead to define the NetCDF installation")
      set(NetCDF_ROOT ${NetCDF_DIR})
    endif()


    # Cache variables
    if(NetCDF_ROOT)
        set(NetCDF_ROOT "${NetCDF_ROOT}" CACHE PATH "Path to search for NetCDF include and library files")
    endif()

    if(NetCDF_INCLUDE_DIR)
        set(NetCDF_INCLUDE_DIR "${NetCDF_INCLUDE_DIR}" CACHE PATH "Path to search for NetCDF include files")
    endif()

    if(NetCDF_LIBRARY_DIR)
        set(NetCDF_LIBRARY_DIR "${NetCDF_LIBRARY_DIR}" CACHE PATH "Path to search for NetCDF library files")
    endif()

    # Search for include files
    # Search order preference:
    #  (1) NetCDF_INCLUDE_DIR - check existence of path AND if the include files exist
    #  (2) NetCDF_ROOT/<include>
    #  (3) Default CMake paths See cmake --html-help=out.html file for more information.
    #
    set(netcdf_inc_names "netcdf.h")
    if (NetCDF_INCLUDE_DIR)

        if (EXISTS "${NetCDF_INCLUDE_DIR}")

            find_path(cdf_test_include_path
                      NAMES ${netcdf_inc_names}
                      HINTS ${NetCDF_INCLUDE_DIR}
                      NO_DEFAULT_PATH)
            if(NOT cdf_test_include_path)
                message(SEND_ERROR "Can not locate ${netcdf_inc_names} in ${NetCDF_INCLUDE_DIR}")
            endif()
            set(NetCDF_INCLUDE_DIR "${cdf_test_include_path}")

        else()
            message(SEND_ERROR "NetCDF_INCLUDE_DIR=${NetCDF_INCLUDE_DIR} does not exist")
            set(NetCDF_INCLUDE_DIR "NetCDF_INCLUDE_DIR-NOTFOUND")
        endif()

    else()

        set(netcdf_inc_suffixes "include")
        if(NetCDF_ROOT)

            if (EXISTS "${NetCDF_ROOT}" )

                find_path(NetCDF_INCLUDE_DIR
                          NAMES ${netcdf_inc_names}
                          HINTS ${NetCDF_ROOT}/include
                          PATH_SUFFIXES ${netcdf_inc_suffixes}
                          NO_DEFAULT_PATH)

            else()
                 message(SEND_ERROR "NetCDF_ROOT=${NetCDF_ROOT} does not exist")
                 set(NetCDF_INCLUDE_DIR "NetCDF_INCLUDE_DIR-NOTFOUND")
            endif()


        else()

            find_path(NetCDF_INCLUDE_DIR
                      NAMES ${netcdf_inc_names}
                      PATH_SUFFIXES ${netcdf_inc_suffixes})

        endif()

    endif()


    if ( NOT NetCDF_INCLUDE_DIR )
        message(SEND_ERROR "Can not locate NetCDF include directory")
    endif()

    # Search for libraries
    # Search order preference:
    #  (1) NetCDF_LIBRARY_DIR - check existence of path AND if the include files exist
    #  (2) NetCDF_ROOT/<lib,Lib>
    #  (3) Default CMake paths See cmake --html-help=out.html file for more information.
    #
    if (NetCDF_LIBRARY_DIR)

        if (EXISTS "${NetCDF_LIBRARY_DIR}")

            find_library(NetCDF_C_LIBRARY
                         NAMES netcdf
                         HINTS ${NetCDF_LIBRARY_DIR}
                         NO_DEFAULT_PATH)

#            find_library(NetCDF_CXX_LIBRARY
#                         NAMES netcdf_c++
#                         HINTS ${NetCDF_LIBRARY_DIR}
#                         NO_DEFAULT_PATH)

        else()
            message(SEND_ERROR "NetCDF_LIBRARY_DIR=${NetCDF_LIBRARY_DIR} does not exist")
            set(NetCDF_LIBRARY "NetCDF_C_LIBRARY-NOTFOUND")
#            set(NetCDF_LIBRARY "NetCDF_CXX_LIBRARY-NOTFOUND")
        endif()

    else()

        if(NetCDF_ROOT)

            if (EXISTS "${NetCDF_ROOT}" )

                find_library(NetCDF_C_LIBRARY
                             NAMES netcdf
                             HINTS ${NetCDF_ROOT}
                             PATH_SUFFIXES "lib" "Lib"
                             NO_DEFAULT_PATH)

#                find_library(NetCDF_CXX_LIBRARY
#                             NAMES netcdf_c++
#                             HINTS ${NetCDF_ROOT}
#                             PATH_SUFFIXES "lib" "Lib"
#                             NO_DEFAULT_PATH)

            else()
                 message(SEND_ERROR "NetCDF_ROOT=${NetCDF_ROOT} does not exist")
                 set(NetCDF_LIBRARY "NetCDF_C_LIBRARY-NOTFOUND")
#                 set(NetCDF_LIBRARY "NetCDF_CXX_LIBRARY-NOTFOUND")
            endif()


        else()

            find_library(NetCDF_C_LIBRARY
                         NAMES netcdf
                         PATH_SUFFIXES ${netcdf_lib_suffixes})

#            find_library(NetCDF_CXX_LIBRARY
#                         NAMES netcdf_c++
#                         PATH_SUFFIXES ${netcdf_lib_suffixes})


        endif()

    endif()

    if ( NOT NetCDF_C_LIBRARY )
        message(SEND_ERROR "Can not locate NetCDF C library")
    endif()

#    if ( NOT NetCDF_CXX_LIBRARY )
#        message(SEND_ERROR "Can not locate NetCDF CXX library")
#    endif()



    # Define the LIBRARIES and INCLUDE_DORS
    set(NetCDF_INCLUDE_DIRS ${NetCDF_INCLUDE_DIR})
    set(NetCDF_LIBRARIES    ${NetCDF_CXX_LIBRARY} ${NetCDF_C_LIBRARY})
endif()

# Parallel check here
if ( NetCDF_INCLUDE_DIR )
	set(NetCDF_PARALLEL False)
    find_path(meta_path
	          NAMES "netcdf_meta.h"
              HINTS ${NetCDF_INCLUDE_DIR}
              NO_DEFAULT_PATH)
    if(meta_path)
       # Search meta for NC_HAS_PARALLEL setting...
       # Note that there is both NC_HAS_PARALLEL and NC_HAS_PARALLEL4, only want first...
       file(STRINGS "${meta_path}/netcdf_meta.h" netcdf_par_string REGEX "NC_HAS_PARALLEL ")
       string(REGEX MATCH "[01]" netcdf_par_val "${netcdf_par_string}")
       if (netcdf_par_val EQUAL 1)
          set(NetCDF_PARALLEL True)
       endif()
    endif()
endif()

# Get information such as HDF5 dependency and parallel capability
if ( NetCDF_ROOT OR NetCDF_BIN_DIR )
    MESSAGE(STATUS "\tNetCDF_ROOT is ${NetCDF_ROOT}")
    # First, try to get this information from an installed CMake config file
    find_package(netCDF QUIET HINTS ${NetCDF_ROOT} NO_MODULE)
    if (netCDF_CONFIG)
        # If we find an installed config file, it can tell us these things
        MESSAGE(STATUS "\tnetCDF_CONFIG is ${netCDF_CONFIG}")
        set(NetCDF_NEEDS_HDF5 "${netCDF_HAS_HDF5}")
        set(NetCDF_VERSION "${netCDF_VERSION}")
        set(NetCDF_NEEDS_PNetCDF "${netCDF_HAS_PNETCDF}")
    else()
        # Otherwise, try calling the nc-config shell script
        if (WIN32)
            message(FATAL_ERROR "nc-config can't be used on Windows, please use CMake to install NetCDF")
        endif()
        find_program(netcdf_config nc-config
                       PATHS ${NetCDF_ROOT}/bin ${NetCDF_BIN_DIR}
		           NO_DEFAULT_PATH
		           NO_CMAKE_SYSTEM_PATH
                       DOC "NetCDF configuration script")

        if (netcdf_config)
            message(STATUS "Found NetCDF configuration script: ${netcdf_config}")
            execute_process(COMMAND sh -c "${netcdf_config} --has-hdf5"
                            RESULT_VARIABLE _ret_code
                            OUTPUT_VARIABLE _stdout
                            ERROR_VARIABLE  _stderr
                           )
            string(REGEX MATCH "yes|no" _hdf5_answer ${_stdout})
            message(STATUS "${netcdf_config} --has-hdf5 returned '${_hdf5_answer}'")
            string(COMPARE EQUAL "${_hdf5_answer}" "yes" _has_hdf5)
            if (${_has_hdf5} )
                set(NetCDF_NEEDS_HDF5 True)
            else()
                set(NetCDF_NEEDS_HDF5 False)
            endif()

            execute_process(COMMAND sh -c "${netcdf_config} --version"
                            RESULT_VARIABLE _ret_code
                            OUTPUT_VARIABLE _stdout
                            ERROR_VARIABLE  _stderr
                           )
            string(STRIP ${_stdout} NetCDF_VERSION)

	    # If --has-pnetcdf returns true, then add pnetcdf as dependent library.
            execute_process(COMMAND sh -c "${netcdf_config} --has-pnetcdf"
                            RESULT_VARIABLE _ret_code
                            OUTPUT_VARIABLE _stdout
                            ERROR_VARIABLE  _stderr
                           )
            string(REGEX MATCH "yes|no" _pnetcdf_answer ${_stdout})
            message(STATUS "${netcdf_config} --has-pnetcdf returned '${_pnetcdf_answer}'")
            string(COMPARE EQUAL "${_pnetcdf_answer}" "yes" _has_pnetcdf)
            if (${_has_pnetcdf} )
                set(NetCDF_NEEDS_PNetCDF True)
            else()
                set(NetCDF_NEEDS_PNetCDF False)
            endif()
        endif()
    endif()
endif()

if(NetCDF_NEEDS_HDF5)
    message(STATUS "NetCDF requires HDF5")
    add_package_dependency(NetCDF DEPENDS_ON HDF5)
else()
    message(STATUS "NetCDF does not require HDF5")
endif()

if(NetCDF_NEEDS_PNetCDF)
    message(STATUS "NetCDF requires PNetCDF")
    add_package_dependency(NetCDF DEPENDS_ON PNetCDF)
else()
    message(STATUS "NetCDF does not require PNetCDF")
endif()

# --- Search for NetCDF tools
if ( NetCDF_BINARY_DIR )
    # Do nothing. Variables are set. No need to search again
else()
    if(NetCDF_BINARY_DIR)
        set(NetCDF_BINARY_DIR "${NetCDF_BINARY_DIR}" CACHE PATH "Path to search for NetCDF tools")
    endif()

    set(netcdf_bin_names "ncdump" "ncdump.exe")
    if (NetCDF_BINARY_DIR)

        if (EXISTS "${NetCDF_BINARY_DIR}")

            find_path(cdf_test_bin_path
                      NAMES ${netcdf_bin_names}
                      HINTS ${NetCDF_BINARY_DIR}
                      NO_DEFAULT_PATH)
            if(NOT cdf_test_bin_path)
                message(SEND_ERROR "Can not locate ${netcdf_bin_names} in ${NetCDF_BINARY_DIR}")
            endif()
            set(NetCDF_BINARY_DIR "${cdf_test_bin_path}")

        else()
            message(SEND_ERROR "NetCDF_BINARY_DIR=${NetCDF_BINARY_DIR} does not exist")
            set(NetCDF_BINARY_DIR "NetCDF_BINARY_DIR-NOTFOUND")
        endif()

    else()

        set(netcdf_bin_suffixes "bin")
        if(NetCDF_ROOT)

            if (EXISTS "${NetCDF_ROOT}" )

                find_path(NetCDF_BINARY_DIR
                          NAMES ${netcdf_bin_names}
                          HINTS ${NetCDF_ROOT}
                          PATH_SUFFIXES ${netcdf_bin_suffixes}
                          NO_DEFAULT_PATH)

            else()
                 message(SEND_ERROR "NetCDF_ROOT=${NetCDF_ROOT} does not exist")
                 set(NetCDF_BINARY_DIR "NetCDF_BINARY_DIR-NOTFOUND")
            endif()


        else()

            find_path(NetCDF_BINARY_DIR
                      NAMES ${netcdf_bin_names}
                      PATH_SUFFIXES ${netcdf_bin_suffixes})

        endif()
    endif()

    if ( NOT NetCDF_BINARY_DIR )
        message(STATUS "Can not locate NetCDF bin directory")
    endif()
endif()

set(_netcdf_TOOLS ncdump ncgen nccopy)
set(NETCDF_TOOLS_FOUND)
foreach( tool ${_netcdf_TOOLS})
  string(TOUPPER "${tool}" tool_uc)
  set(_netcdf_VAR_NAME NETCDF_${tool_uc}_BINARY)
  find_program(${_netcdf_VAR_NAME}
               ${tool}
               HINTS ${NetCDF_BINARY_DIR})
  if (${_netcdf_VAR_NAME})
    list(APPEND NETCDF_TOOLS_FOUND ${tool})
  endif()
endforeach()

# Send useful message if everything is found
find_package_handle_standard_args(NetCDF DEFAULT_MSG
                                           NetCDF_LIBRARIES
                                           NetCDF_INCLUDE_DIRS)

# find_package)handle)standard_args should set NetCDF_FOUND but it does not!
if ( NetCDF_LIBRARIES AND NetCDF_INCLUDE_DIRS)
    set(NetCDF_FOUND TRUE)
else()
    set(NetCDF_FOUND FALSE)
endif()

# --- Provide a summary of what the module found
if ( NOT NetCDF_FIND_QUIETLY )

  # Create a not found list

  message(STATUS "NetCDF Version: ${NetCDF_VERSION}")
  message(STATUS "\tNetCDF_NEEDS_HDF5        = ${NetCDF_NEEDS_HDF5}")
  message(STATUS "\tNetCDF_NEEDS_PNetCDF     = ${NetCDF_NEEDS_PNetCDF}")
  message(STATUS "\tNetCDF_PARALLEL          = ${NetCDF_PARALLEL}")
  message(STATUS "\tNetCDF_INCLUDE_DIRS      = ${NetCDF_INCLUDE_DIRS}")
  message(STATUS "\tNetCDF_LIBRARIES         = ${NetCDF_LIBRARIES}")
  message(STATUS "\tNetCDF_BINARIES          = ${NETCDF_TOOLS_FOUND}")

endif()

mark_as_advanced(
  NetCDF_INCLUDE_DIR
  NetCDF_INCLUDE_DIRS
  NetCDF_C_LIBRARY
  NetCDF_CXX_LIBRARY
  NetCDF_LIBRARIES
  NetCDF_LIBRARY_DIR
)
