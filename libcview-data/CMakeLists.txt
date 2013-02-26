
SET(CVIEW_DATA_CLASSES
	CalculatedDataSet
	DataSet
	Defaults
	DictionaryExtra
	JobDataSet
	ListComp
	SinDataSet
	StreamDataSet
	UpdateRunLoop
	ValueStore
	ValueStoreDataSet
	WebDataSet
	XYDataSet
)

SET(CVIEW_DATA_HDRS cview-data.h calcdataset.h debug.h PList.h)

SET(CVIEW_DATA_SRCS 
	datautils.m
	calcdatasetkernel.c
)

FOREACH (OBJ ${CVIEW_DATA_CLASSES})
  LIST(APPEND CVIEW_DATA_SRCS "${OBJ}.m")
  LIST(APPEND CVIEW_DATA_HDRS "${OBJ}.h")
ENDFOREACH(OBJ)

ADD_DEFINITIONS(${FOUNDATION_FLAGS})
ADD_LIBRARY(libcview-data ${LIB_TYPE} ${CVIEW_DATA_SRCS} ${CVIEW_DATA_HDRS} )
ADD_DEPENDENCIES(libcview-data DataFiles)
SET_TARGET_PROPERTIES(libcview-data PROPERTIES OUTPUT_NAME cview-data)
TARGET_LINK_LIBRARIES(libcview-data ${FOUNDATION_LIBRARIES})

SET_TARGET_PROPERTIES(libcview-data PROPERTIES SOVERSION 0.1)
INSTALL(TARGETS libcview-data DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT "libcview_data_library")
INSTALL(FILES ${CVIEW_DATA_HDRS} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${CMAKE_PROJECT_NAME}" COMPONENT "libcview_data_Header_Files")

CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/cview-data.pc.in ${CMAKE_CURRENT_BINARY_DIR}/cview-data.pc)
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/cview-data.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig COMPONENT "libcview_data_pkg_config_file") 
