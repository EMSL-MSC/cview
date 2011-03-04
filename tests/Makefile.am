OBJC=gcc
AM_OBJCFLAGS=-g -Wall $(WAND_CFLAGS) $(FTGL_CFLAGS)
AM_LDFLAGS= $(OPENGL_LDFLAGS) $(WAND_LIBS) $(top_builddir)/libcview/libcview.la $(top_builddir)/libcview-data/libcview-data.la $(ATB_LDFLAGS) $(FOUNDATION_LDFLAGS)
OBJCDEPMODE = depmode=gcc
LIBS=

# set the include path found by configure
INCLUDES = $(all_includes) -I$(top_srcdir)/libcview -I$(top_srcdir)/libcview-data

# the library search path.
noinst_PROGRAMS = datasettest glgridtest glscreentest webdatasettest \
                  calcdatasettest calcdatatest xydatasettest iddatabasetest \
                  glimagetest streamdatasettest glbartest ibtest graphtest
EXTRA_DIST = funcdata
noinst_DATA = testdata.xy

calcdatasettest_SOURCES = calcdatasettest.m

#we have to link this test strange since the gnustep portions of the libcview-data cause issues if main was not compiled with an objective C compiler on some platforms.
calcdatatest_SOURCES = calcdatatest.c 
calcdatatest_LDFLAGS = $(top_builddir)/libcview-data/calcdatasetkernel.o

glscreentest_SOURCES = glscreentest.m

datasettest_SOURCES = datasettest.m 

webdatasettest_SOURCES = webdatasettest.m

xydatasettest_SOURCES = xydatasettest.m

glgridtest_SOURCES = glgridtest.m

glbartest_SOURCES = glbartest.m

glimagetest_SOURCES = glimagetest.m

streamdatasettest_SOURCES  = streamdatasettest.m

testdata.xy: funcdata
	python funcdata xy > testdata.xy

iddatabasetest_SOURCES = iddatabasetest.m

ibtest_SOURCES = ibtest.m

graphtest_SOURCES = graphtest.m
