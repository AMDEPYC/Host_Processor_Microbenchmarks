cmake_minimum_required(VERSION 2.8.11)

project(bench)

#disable in source build
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

message(STATUS "cmake is building on a ${CMAKE_SYSTEM_NAME} system")
set(dir ${PROJECT_SOURCE_DIR})
message("project source dir" ${dir})

enable_language(CUDA)

##find_package(MYMPI ${MPI_MIN_VERSION} EXACT REQUIRED)


set(CMAKE_FILES_DIRECTORY ${dir}/build)
message("Files Directory" ${CMAKE_FILES_DIRECTORY})

#define some colors (Unix-based systems)

if(NOT WIN32)
  string(ASCII 27 Esc)
  set(ColourReset "${Esc}[m")
  set(ColourBold  "${Esc}[1m")
  set(Red         "${Esc}[31m")
  set(Green       "${Esc}[32m")
  set(Yellow      "${Esc}[33m")
  set(Blue        "${Esc}[34m")
  set(Magenta     "${Esc}[35m")
  set(Cyan        "${Esc}[36m")
  set(White       "${Esc}[37m")
  set(BoldRed     "${Esc}[1;31m")
  set(BoldGreen   "${Esc}[1;32m")
  set(BoldYellow  "${Esc}[1;33m")
  set(BoldBlue    "${Esc}[1;34m")
  set(BoldMagenta "${Esc}[1;35m")
  set(BoldCyan    "${Esc}[1;36m")
  set(BoldWhite   "${Esc}[1;37m")
endif()


# get the number of physical procesors 

message("project binary dir" ${EXECUTABLE_OUTPUT_PATH})
message("CMAKE SOURCE DIR:" ${CMAKE_SOURCE_DIR})
message("CMAKE_BINARY_DIR:" ${CMAKE_BINARY_DIR})

# Out-of-Source build is required by amrGem, this if statement prevents
# in-source-builds 

if ( ${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message( FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt." )
endif()


message("cmake Home Dir:" ${CMAKE_HOME_DIRECTORY})
message("cmake Build Dir:" ${CMAKE_BUILD_DIRECTORY})
message("cmake Binary Dir:" ${CMAKE_BINARY_DIR})
message("cmake source dir:" ${CMAKE_SOURCE_DIR})


############################################################################
#
#                    SECTION: FINDING-PACKAGE
#
#        1) HDF5 have native FindXXX.cmake's provided by cmake
#        2) For Zoltan and ParMETIS one needs to specify FindXXX.cmake 
#        3) These non-native to cmake modules are included in CMakeModules
#
############################################################################

###########################################################################
#
#                    SECTION: BUILD AND INSTALL
#
#        1) Build all the *.cpp and *.c files in "/src" directory
#        2) Link with external package libraries 
#        3) Install the final executable in "/bin"
#
############################################################################
set(CUDA_VERBOSE_BUILD "ON")

set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -arch=sm_90 -std=c++11")
message("flags files" ${CMAKE_CUDA_FLAGS})

include_directories(${dir}/src/include)
# dont forget to modify the address of the source files
## we can separate them to cpu and gpu groups
file(GLOB OBJ "${dir}/src/*.cpp" "${dir}/src/*.cu")
#set(CMAKE_BUILD_FILES_DIRECTORY ${dir})
#set(CMAKE_BUILD_DIRECTORY ${dir}/bin)      

set(EXECUTABLE_OUTPUT_PATH ${dir}/bin)

# Define all header files for linking, this is required such that one doesnt
# have to hardcode the directories for I/O operations and hence ensure
# portability

set(HEADER_FILES "${dir}/src/include/bindCpuToGpu.cuh" 
)


set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/CMakeModules/")

# find MPI
find_package(MPI ${MPI_MIN_VERSION} EXACT REQUIRED)
if(MPI_FOUND)
	include_directories(${MPI_INCLUDES} )
	include_directories(${MPI_C_HEADER_DIR} )
message( "${Red} MPI Include  : ${ColourReset}" ${MPI_INCLUDE})
message( "${Red} MPI Library  : ${ColourReset}" ${MPI_LIB} )
#message("${Green} 1. MPI Library : Found ${ColourReset}")
endif()


#find_package(AMGX)
#if(AMGX_FOUND)
#include_directories(${AMGX_INCLUDES})
#message( "${Red} AMGX Include  : ${ColourReset}" ${AMGX_INCLUDES})
#message( "${Red} AMGX Library  : ${ColourReset}" ${AMGX_LIB} )
#message("${Green} 1. MPI Library : Found ${ColourReset}")
#endif()


message("header files" ${HEADER_FILES})


# insert -pg instead of -g for checking with gprof
# gprof bin/amrGem > out.text  
if(UNIX)
   SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++1y -O3 -Wunused-variable ")
#    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++1y  -O3 -Wunused-variable ")
#    SET(CMAKE_EXEC_LINKER_FLAGS "${CMAKE_EXEC_LINKER_FLAGS} -Wall -std=gnu++0x" )
    SET(CMAKE_EXEC_LINKER_FLAGS "${CMAKE_EXEC_LINKER_FLAGS} -Wall -std=c++1y -Wunused-variable" )
endif()

# Generate Object Files
add_executable(bench ${OBJ} ${HEADER_FILES}) 
target_link_libraries(bench  ${HDF5_C_LIBRARIES} ${AMGX_LIB} ${MPI_mpi_LIBRARY})

#install(TARGETS amrGem DESTINATION ${dir/}bin)


