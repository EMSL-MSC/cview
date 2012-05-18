
ADD_DEFINITIONS(${FOUNDATION_FLAGS})
INCLUDE_DIRECTORIES(${GLUT_INCLUDE_DIR})
INCLUDE_DIRECTORIES(${GL_H_INCLUDE} ${OPENGL_INCLUDE_DIR})
INCLUDE_DIRECTORIES(${FTGL_INCLUDE_DIRS})
INCLUDE_DIRECTORIES(${ImageMagick_MagickWand_INCLUDE_DIR})


MACRO(ADD_PROG name)
	MESSAGE("Adding executable ${name}")
	ADD_EXECUTABLE(${name} ${ARGN})
	TARGET_LINK_LIBRARIES(${name} libcview libcview-data)
	INSTALL(TARGETS ${name} DESTINATION bin COMPONENT Binaries)
ENDMACRO(ADD_PROG)

IF(HAVE_GENDERS) 
	LIST(APPEND CVIEW_EXTRA_SRC DataCenterCViewScreenDelegate.m)
ENDIF()
ADD_PROG(cview cview.m CViewScreenDelegate.m CViewScreenDelegate.m CViewScreenDelegate.m LoadClasses.m ObjectTracker.m ${CVIEW_EXTRA_SRC})
ADD_PROG(cviewall cviewall.m CViewScreenDelegate.m LoadClasses.m CViewAllScreenDelegate.m) 
IF(OSMESA_FOUND)
	ADD_PROG(oscview oscview.m glutstub.c)
	TARGET_LINK_LIBRARIES(oscview ${OSMESA_LIBRARIES})
ENDIF(OSMESA_FOUND)
