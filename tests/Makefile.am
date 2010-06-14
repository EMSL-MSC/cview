OBJC=gcc
AM_OBJCFLAGS=-g -Wall $(WAND_CFLAGS) $(FTGL_CFLAGS)
AM_LDFLAGS=$(FOUNDATION_LDFLAGS) $(OPENGL_LDFLAGS) $(WAND_LIBS) $(ATB_LDFLAGS) $(top_srcdir)/libcview/libcview.la $(top_srcdir)/libcview-data/libcview-data.la
OBJCDEPMODE = depmode=gcc

# set the include path found by configure
INCLUDES = $(all_includes) -I$(top_srcdir)/libcview -I$(top_srcdir)/libcview-data

# the library search path.
noinst_PROGRAMS = datasettest glgridtest glscreentest webdatasettest calcdatasettest calcdatatest xydatasettest iddatabasetest glimagetest
EXTRA_DIST = funcdata
noinst_DATA = testdata.xy

calcdatasettest_SOURCES = calcdatasettest.m

calcdatatest_SOURCES = calcdatatest.c

glscreentest_SOURCES = glscreentest.m

datasettest_SOURCES = datasettest.m 

webdatasettest_SOURCES = webdatasettest.m

xydatasettest_SOURCES = xydatasettest.m

glgridtest_SOURCES = glgridtest.m

glimagetest_SOURCES = glimagetest.m

testdata.xy: funcdata
	python funcdata xy > testdata.xy

iddatabasetest_SOURCES = iddatabasetest.m
