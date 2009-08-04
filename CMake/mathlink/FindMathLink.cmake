# - this module looks for Mathematica's MathLink API
# Defines:
#  MathLink_INCLUDE_DIR:      include path for mathlink.h
#  MathLink_LIBRARIES:        required libraries: libML32i3, etc.
#  MathLink_LIBRARY_DIR:      path for required libraries
#  MathLink_MPREP_EXECUTABLE: path to mprep

SET(MathLink_FOUND 0)
IF( MathLink_FIND_VERSION )
  set(_mathlink_version "${MathLink_FIND_VERSION_MAJOR}.${MathLink_FIND_VERSION_MINOR}")
ELSE ( MathLink_FIND_VERSION)
  MESSAGE( FATAL_ERROR "Invalid Mathematica version string given." )
ENDIF( MathLink_FIND_VERSION )

if (WIN32)
  IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set (MathLink_SYS Windows)
  ELSE(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(MathLink_SYS Windows-x86-64)
  ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(MathLink_ROOT_DIR "$ENV{ProgramFiles}\\Wolfram Research\\Mathematica\\${MathLink_FIND_VERSION_MAJOR}.${MathLink_FIND_VERSION_MINOR}\\SystemFiles\\Links\\MathLink\\DeveloperKit\\${MathLink_SYS}")
endif(WIN32)

if(UNIX)
  IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set (MathLink_SYS Linux)
  ELSE(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(MathLink_SYS Linux-x86-64)
  ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(MathLink_ROOT_DIR /usr/local/Wolfram/Mathematica/${MathLink_FIND_VERSION_MAJOR}.${MathLink_FIND_VERSION_MINOR}/SystemFiles/Links/MathLink/DeveloperKit/${MathLink_SYS})
endif(UNIX)

if(APPLE)
  set(MathLink_ROOT_DIR /Applications/Mathematica.app/SystemFiles/Links/MathLink/DeveloperKit)
endif(APPLE)

find_path(MathLink_INCLUDE_DIR
  NAMES mathlink.h
  PATHS ${MathLink_ROOT_DIR}/CompilerAdditions
        ${MathLink_ROOT_DIR}/CompilerAdditions/mldev32/include
        ${MathLink_ROOT_DIR}/CompilerAdditions/mldev64/include
      )
        
IF(UNIX)
  set(MathLink_LIBRARY_DIR ${MathLink_ROOT_DIR}/CompilerAdditions )
ELSE(UNIX)
  IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(MathLink_LIBRARY_DIR ${MathLink_ROOT_DIR}\\CompilerAdditions\\mldev32\\lib )
  ELSE(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(MathLink_LIBRARY_DIR ${MathLink_ROOT_DIR}\\CompilerAdditions\\mldev64\\lib )
  ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 4)
ENDIF(UNIX)

find_program(MathLink_MPREP_EXECUTABLE 
  NAME  mprep
  PATHS ${MathLink_ROOT_DIR}/CompilerAdditions
        ${MathLink_ROOT_DIR}\\CompilerAdditions\\mldev32\\bin
        ${MathLink_ROOT_DIR}\\CompilerAdditions\\mldev64\\bin
      )
mark_as_advanced(MathLink_MPREP_EXECUTABLE)

IF(WIN32)
  IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    FIND_LIBRARY( MathLink_ML_LIBRARY 
      NAME  ml32i3m
      PATHS ${MathLink_LIBRARY_DIR}
            ${MathLink_ROOT_DIR}\\SystemAdditions
          )
  ELSE(CMAKE_SIZEOF_VOID_P EQUAL 4)
    FIND_LIBRARY( MathLink_ML_LIBRARY 
      NAME  ml64i3m
      PATHS ${MathLink_LIBRARY_DIR}
            ${MathLink_ROOT_DIR}\\SystemAdditions
          )
  ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 4)
  SET( MathLink_LIBRARIES ${MathLink_ML_LIBRARY} )
ENDIF(WIN32)

IF(APPLE)
  FIND_LIBRARY( MathLink_ML_LIBRARY 
    NAME  MLi3
    PATH  ${MathLink_LIBRARY_DIR}
  )
  SET( MathLink_LIBRARIES ${MathLink_ML_LIBRARY}
    stdc++
  )
ENDIF(APPLE)

IF(UNIX AND NOT APPLE)
  IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    FIND_LIBRARY( MathLink_ML_LIBRARY 
      NAME  ML32i3
      PATH  ${MathLink_LIBRARY_DIR}
    )
  ELSE(CMAKE_SIZEOF_VOID_P EQUAL 4)
    FIND_LIBRARY( MathLink_ML_LIBRARY 
      NAME  ML64i3
      PATH  ${MathLink_LIBRARY_DIR}
    )
  ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 4)

  SET( MathLink_LIBRARIES ${MathLink_ML_LIBRARY}
    m
    pthread
    rt
    stdc++
  )
ENDIF(UNIX AND NOT APPLE)

MACRO (MathLink_ADD_TM infile )
 GET_FILENAME_COMPONENT(outfile ${infile} NAME_WE)
 GET_FILENAME_COMPONENT(abs_infile ${infile} ABSOLUTE)
 SET(outfile ${CMAKE_CURRENT_BINARY_DIR}/${outfile}.tm.c)
 ADD_CUSTOM_COMMAND(
   OUTPUT   ${outfile}
   COMMAND  ${MathLink_MPREP_EXECUTABLE}
   ARGS     -o ${outfile} ${abs_infile}
   MAIN_DEPENDENCY ${infile})
ENDMACRO (MathLink_ADD_TM)

IF(MathLink_INCLUDE_DIR AND MathLink_LIBRARIES)
  SET(MathLink_FOUND 1)
ENDIF(MathLink_INCLUDE_DIR AND MathLink_LIBRARIES)

MARK_AS_ADVANCED(
  MathLink_LIBRARIES 
  MathLink_INCLUDE_DIR 
  MathLink_LIBRARY_DIR
  MathLink_FOUND
)
