OBJC=gcc
AM_OBJCFLAGS=-g -Wall -pg  -fobjc-exceptions -O0 
OBJCDEPMODE = depmode=gcc

# set the include path found by configure
INCLUDES = $(all_includes) -I$(top_srcdir)/libcview-data

pkginclude_HEADERS = *.h

lib_LTLIBRARIES = libcview-data.la

libcview_data_la_SOURCES = DataSet.m SinDataSet.m UpdateThread.m \
	DictionaryExtra.m ListComp.m WebDataSet.m JobDataSet.m \
	calcdatasetkernel.c CalculatedDataSet.m 

libcview_data_la_OBJCFLAGS = $(AM_OBJCFLAGS)
libcview_data_la_LDFLAGS = $(FOUNDATION_LDFLAGS) 

