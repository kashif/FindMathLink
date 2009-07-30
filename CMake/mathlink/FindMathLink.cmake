IF( MathLink_FIND_VERSION )
  set(_mathlink_version "${MathLink_FIND_VERSION_MAJOR}.${MathLink_FIND_VERSION_MINOR}")
ELSE ( MathLink_FIND_VERSION)
  MESSAGE( FATAL_ERROR "Invalid Mathematica version string given." )
ENDIF( MathLink_FIND_VERSION )

if (WIN32)
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

set(MathLink_INCLUDE_DIRS ${MathLink_ROOT_DIR}/CompilerAdditions )
set(MathLink_LIBRARY_DIRS ${MathLink_ROOT_DIR}/CompilerAdditions )

find_program(MathLink_MPREP_EXECUTABLE NAME mprep
  PATHS ${MathLink_ROOT_DIR}/CompilerAdditions
  NO_DEFAULT_PATH)
mark_as_advanced(MathLink_MPREP_EXECUTABLE)

IF(APPLE)
  FIND_LIBRARY( MathLink_ML_LIBRARY NAMES MLi3
    PATHS ${MathLink_LIBRARY_DIRS}
    )
    
  SET( MathLink_LIBRARIES
    ${MathLink_ML_LIBRARY}
    stdc++
  )
ENDIF(APPLE)

IF(UNIX AND NOT APPLE)
  IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    FIND_LIBRARY( MathLink_ML_LIBRARY NAMES ML32i3
      PATHS ${MathLink_LIBRARY_DIRS}
    )
  ELSE(CMAKE_SIZEOF_VOID_P EQUAL 4)
    FIND_LIBRARY( MathLink_ML_LIBRARY NAMES ML64i3
      PATHS ${MathLink_LIBRARY_DIRS}
    )
  ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 4)
  
  SET( MathLink_LIBRARIES
    ${MathLink_ML_LIBRARY}
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
 ADD_CUSTOM_COMMAND(OUTPUT ${outfile}
   COMMAND ${MathLink_MPREP_EXECUTABLE}
   ARGS -o ${outfile} ${abs_infile}
   MAIN_DEPENDENCY ${infile})
ENDMACRO (MathLink_ADD_TM)

MARK_AS_ADVANCED(MathLink_INCLUDE_DIRS MathLink_LIBRARY_DIRS)

