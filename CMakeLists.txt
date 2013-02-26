PROJECT(cview)
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.0)
MARK_AS_ADVANCED(CMAKE_BACKWARDS_COMPATIBILITY)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(GNUInstallDirs)

SET(VERSION_MAJOR 0)
SET(VERSION_MINOR 3)
SET(VERSION_PATCH 3)
SET(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
EXECUTE_PROCESS(COMMAND git show-ref -s HEAD COMMAND cut -c 1-10 WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE GIT_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
#options
OPTION(CVIEW_TEST_BUILD "Build CView Testing Applications" OFF)
OPTION(GCOBJECTDEBUG "Enable Tracking of Object Allocations" OFF)
OPTION(SOURCE_BUILD_ONLY "Only Configure enough to build a source tar ball" OFF)

SET(LIB_TYPE SHARED)

IF (NOT SOURCE_BUILD_ONLY) 

#detect libraries
IF (APPLE)
	SET(FOUNDATION_LIBRARIES "-framework Foundation")
ELSEIF (UNIX OR MINGW)
	FIND_PROGRAM(GNUSTEP_CONFIG gnustep-config)
	MESSAGE("Found gnustep-config at: ${GNUSTEP_CONFIG}")
	IF(NOT DEFINED GNUSTEP_CONFIG)
		MESSAGE(FATAL_ERROR "Error: gnustep-config not found. exiting")
	ENDIF()
	#for some silly reason we have to force this command to a shell on windows....
	EXECUTE_PROCESS(COMMAND sh -c "${GNUSTEP_CONFIG} --base-libs"  OUTPUT_VARIABLE FOUNDATION_LIBRARIES OUTPUT_STRIP_TRAILING_WHITESPACE)
	EXECUTE_PROCESS(COMMAND sh -c "${GNUSTEP_CONFIG} --objc-flags" OUTPUT_VARIABLE FOUNDATION_FLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
	#lets control Optimization and debug on our own please
	STRING(REPLACE "-g -O2" "-DHEYTHERE" FOUNDATION_FLAGS ${FOUNDATION_FLAGS})
	MARK_AS_ADVANCED(GNUSTEP_CONFIG)
ENDIF()
IF (MINGW)
	FILE(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/mingw)
	EXECUTE_PROCESS(
			COMMAND ${CMAKE_COMMAND} -G "MSYS Makefiles" ${CMAKE_SOURCE_DIR}/mingw
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/mingw
			RESULT_VARIABLE MINGW_CMAKE_RESULT
			)
	EXECUTE_PROCESS(
			COMMAND ${CMAKE_MAKE_PROGRAM} mingw-libs
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/mingw
			RESULT_VARIABLE MINGW_MAKE_RESULT
			)
	IF (MINGW_CMAKE_RESULT OR MINGW_MAKE_RESULT)
		MESSAGE(FATAL_ERROR "
							*************************************************
							MinGW library build failed.  please check output.
							*************************************************
							")
	ENDIF()
	SET(CMAKE_INCLUDE_PATH ${CMAKE_BINARY_DIR}/mingw/include C:/GNUStep/include/ C:/GNUstep/GNUstep/System/Library/Headers/ )	
	INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/mingw/include ${CMAKE_BINARY_DIR}/mingw/include/GL/ C:/GNUStep/include/ C:/GNUstep/GNUstep/System/Library/Headers/ )	
	SET(CMAKE_LIBRARY_PATH ${CMAKE_BINARY_DIR}/mingw/libs)	
	ADD_SUBDIRECTORY(mingw)	
	SET(LIB_TYPE STATIC)
	SET(ON_MINGW_WIN32 ON)
ENDIF ()

FIND_PACKAGE(Doxygen)
FIND_PACKAGE(GLUT REQUIRED)
FIND_PACKAGE(OpenGL REQUIRED)
FIND_PACKAGE(ImageMagick COMPONENTS MagickWand REQUIRED MagickCore)
MARK_AS_ADVANCED(ImageMagick_EXECUTABLE_DIR ImageMagick_MagickWand_INCLUDE_DIR ImageMagick_MagickWand_LIBRARY)
FIND_PACKAGE(PkgConfig)
PKG_CHECK_MODULES(FTGL REQUIRED ftgl)
PKG_CHECK_MODULES(OSMESA osmesa)

FIND_LIBRARY(GENDERS genders)
IF(GENDERS)
	MESSAGE("Using Genders Library at: ${GENDERS}")
	SET(HAVE_GENDERS YES)
ELSE()
	MESSAGE("Genders Library Not Found")
	SET(HAVE_GENDERS NO)
ENDIF()

FIND_LIBRARY(ATB AntTweakBar)
IF(ATB)
    SET(HAVE_ANTTWEAKBAR YES)
	IF(MINGW)
		STRING(REPLACE ".dll" ".lib" ATB ${ATB})
	ENDIF(MINGW)
    MESSAGE("Using AntTweakBar Library at: ${ATB}")
ELSE()
	MESSAGE("AntTweakBar Library Not Found")
    SET(HAVE_ANTTWEAKBAR NO)
ENDIF()

SET(CMAKE_REQUIRED_INCLUDES ${ImageMagick_MagickWand_INCLUDE_DIR})
SET(CMAKE_REQUIRED_LIBRARIES ${ImageMagick_MagickWand_LIBRARY})
CHECK_FUNCTION_EXISTS(MagickExportImagePixels HAVE_MAGICKEXPORTIMAGEPIXELS)

FIND_PATH(GL_H_INCLUDE "gl.h" PATH_SUFFIXES GL)
MARK_AS_ADVANCED(GL_H_INCLUDE)

SET(PKG_DATA_DIR "${CMAKE_INSTALL_FULL_DATADIR}/${PROJECT_NAME}/")

IF(DOXYGEN_FOUND)
	CONFIGURE_FILE(Doxyfile.in ${CMAKE_BINARY_DIR}/Doxyfile)
	SET(DOXYGEN_OUTPUT ${CMAKE_BINARY_DIR}/html/index.html)
	FILE(GLOB DOXYGEN_INPUT */*.h */*.m */*.c docs/*.dox Doxyfile.in)
	ADD_CUSTOM_COMMAND(OUTPUT ${DOXYGEN_OUTPUT} COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/Doxyfile DEPENDS ${DOXYGEN_INPUT})
	ADD_CUSTOM_TARGET(doc DEPENDS ${DOXYGEN_OUTPUT})
	INSTALL(DIRECTORY ${CMAKE_BINARY_DIR}/docs/html DESTINATION ${PKG_DATA_DIR} COMPONENT "Doxygen_Documentation" OPTIONAL)
ENDIF()


FILE(GLOB DATA_FILES "${CMAKE_SOURCE_DIR}/data/*.ttf*" "${CMAKE_SOURCE_DIR}/data/*.svg" "${CMAKE_SOURCE_DIR}/data/*.ggr" "${CMAKE_SOURCE_DIR}/data/gov.pnnl.emsl.cview.plist")
#this is for in tree testing
ADD_CUSTOM_TARGET(DataFiles ALL
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/data ${CMAKE_BINARY_DIR}/data 
	SOURCES ${DATA_FILES}
	COMMENT "Copying Data File directory"
)
#fixme: These reaslly should installed properly with an install target.
FILE(GLOB CONTRIB_FILES "${CMAKE_SOURCE_DIR}/contrib/*")
ADD_CUSTOM_TARGET(ContribFiles ALL
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/contrib ${CMAKE_BINARY_DIR}/contrib 
	SOURCES ${CONTRIB_FILES}
	COMMENT "Copying Contrib File directory"
)

#this is for install
INSTALL(FILES ${DATA_FILES} DESTINATION "${CMAKE_INSTALL_DATADIR}/${CMAKE_PROJECT_NAME}" COMPONENT "Data_Files")  # should we be more specific about which files?
FILE(GLOB MAN_FILES "${CMAKE_SOURCE_DIR}/man/*.1")
INSTALL(FILES ${MAN_FILES} DESTINATION "${CMAKE_INSTALL_MANDIR}/man1" COMPONENT "Man_Pages")
FILE(COPY "${CMAKE_SOURCE_DIR}/cview.ico" DESTINATION ${CMAKE_BINARY_DIR})
FILE(GLOB CVIEW_FILES_INTERNAL "${CMAKE_SOURCE_DIR}/cviews/pnl/pic-view.cview")
FILE(GLOB CVIEW_FILES "${CMAKE_SOURCE_DIR}/cviews/pnl/chinook-hallway.cview")
INSTALL(FILES ${CVIEW_FILES} ${CVIEW_FILES_INTERNAL} DESTINATION "${CMAKE_INSTALL_DATADIR}/cview/cviews" COMPONENT "CVIEW_Files")
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR})
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/libcview-data)
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/libcview)

ADD_SUBDIRECTORY(libcview-data)
LINK_DIRECTORIES(${CMAKE_BINARY_DIR}/libcview-data)
ADD_SUBDIRECTORY(libcview)
LINK_DIRECTORIES(${CMAKE_BINARY_DIR}/libcview)
#ADD_SUBDIRECTORY(data)
IF (CVIEW_TEST_BUILD)
	ADD_SUBDIRECTORY(tests)
ENDIF()
ADD_SUBDIRECTORY(src)

ENDIF() # SOURCE_BUILD_ONLY


#-------------------------------------------------------
#Packgaing settings for cpack
SET(CPACK_PACKAGE_NAME ${CMAKE_PROJECT_NAME})
SET(CPACK_PACKAGE_VENDOR "www.emsl.pnl.gov")
SET(CPACK_PACKAGE_DESCRIPTION "CView - Graphics engine for displaying information in a 3 dimensional interactive environment. Somewhat targeted at time series performance data, and cluster displays.")
SET(CPACK_PACKAGE_VERSION "${VERSION}")
SET(CPACK_PACKAGE_VERSION_MAJOR "${VERSION_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR "${VERSION_MINOR}")
SET(CPACK_PACKAGE_VERSION_PATCH "${VERSION_PATCH}")
SET(CPACK_PACKAGE_ICON ${CMAKE_SOURCE_DIR}\\\\cview.ico)
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/docs/copying.txt")
SET(CPACK_PACKAGE_EXECUTABLES "cview;CView;cviewall;Cview ALL")
SET(CPACK_NSIS_MODIFY_PATH "ON")
SET(CPACK_SOURCE_GENERATOR "TBZ2")
SET(CPACK_SOURCE_PACKAGE_FILE_NAME
  "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")
ADD_CUSTOM_TARGET(dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

#Windows Installer Stuff - can we put this in the mingw/CMakeFile.txt?
IF(MINGW)

SET(CPACK_PACKAGE_INSTALL_DIRECTORY "CView")
SET(CPACK_NSIS_DISPLAY_NAME CView)
SET(CPACK_NSIS_PACKAGE_NAME "CView Graphics System")
SET(CPACK_NSIS_URL_INFO_ABOUT https://github.com/EMSL-MSC/cview)
SET(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\cview.exe")
SET(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
SET(CPACK_NSIS_EXTRA_INSTALL_COMMANDS "

	WriteRegStr HKCR \\\".cview\\\" \\\"\\\" \\\"PNNL.Cview\\\"
	WriteRegStr HKCR \\\"PNNL.Cview\\\" \\\"\\\" \\\"CVIEW Config File\\\"
	WriteRegStr HKCR \\\"PNNL.Cview\\\\DefaultIcon\\\" \\\"\\\" \\\"\\\$INSTDIR\\\\bin\\\\cview.exe,0\\\"
	WriteRegStr HKCR \\\"PNNL.Cview\\\\shell\\\" \\\"\\\" \\\"open\\\"
	WriteRegStr HKCR \\\"PNNL.Cview\\\\shell\\\\open\\\\command\\\" \\\"\\\" '\\\"$INSTDIR\\\\bin\\\\cview.exe\\\" -c \\\"%1\\\"'
	
	WriteRegStr HKCR \\\".cviewall\\\" \\\"\\\" \\\"PNNL.Cviewall\\\"
	WriteRegStr HKCR \\\"PNNL.Cviewall\\\" \\\"\\\" \\\"CVIEWALL Property-List File\\\"
	WriteRegStr HKCR \\\"PNNL.Cviewall\\\\DefaultIcon\\\" \\\"\\\" \\\"$INSTDIR\\\\bin\\\\cviewall.exe,0\\\"
	WriteRegStr HKCR \\\"PNNL.Cviewall\\\\shell\\\" \\\"\\\" \\\"open\\\"
	WriteRegStr HKCR \\\"PNNL.Cviewall\\\\shell\\\\open\\\\command\\\" \\\"\\\" '\\\"$INSTDIR\\\\bin\\\\cviewall.exe\\\" \\\"%1\\\"'

	!include FileFunc.nsh	
	\\\${RefreshShellIcons}
")
SET(CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS "
	DeleteRegKey HKCR \\\"PNNL.Cview\\\"
	DeleteRegKey HKCR \\\"PNNL.Cviewall\\\"
	\\\${RefreshShellIcons}
")
SET(CPACK_NSIS_CREATE_ICONS_EXTRA "
	CreateDirectory \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\cviews\\\"
	CreateShortCut \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\cviews\\\\pic-view.lnk\\\" \\\"$INSTDIR\\\\share\\\\cviews\\\\pic-view.cview\\\"
")
SET(CPACK_NSIS_DELETE_ICONS_EXTRA "
	!insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP
	DELETE \\\"$SMPROGRAMS\\\\$MUI_TEMP\\\\cviews\\\\pic-view.lnk\\\"
")
ENDIF()


SET(CPACK_SOURCE_IGNORE_FILES "/${CMAKE_PROJECT_NAME}-${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.*tar.*;/_CPack_Packages/;/.git/;~$;.rpm$")
INCLUDE(CPack)

CONFIGURE_FILE(cview.spec.in ${CMAKE_BINARY_DIR}/cview.spec)
CONFIGURE_FILE(config.h.in ${CMAKE_BINARY_DIR}/config.h)
#GET_CMAKE_PROPERTY(res VARIABLES)
#FOREACH(var ${res})
#MESSAGE("${var}=${${var}}")
#ENDFOREACH()
