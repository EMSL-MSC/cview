OBJC=gcc
AM_OBJCFLAGS=-g -Wall $(WAND_CFLAGS) -pg  -fobjc-exceptions $(FTGL_CFLAGS)
OBJCDEPMODE = depmode=gcc
BASELDFLAGS = $(FOUNDATION_LDFLAGS) $(WAND_LIBS) \
	$(top_srcdir)/libcview/libcview.la $(top_srcdir)/libcview-data/libcview-data.la \
	$(ATB_LDFLAGS) $(FTGL_LIBS)

# set the include path found by configure
INCLUDES = $(all_includes) -I$(top_srcdir)/libcview -I$(top_srcdir)/libcview-data

# the library search path.
bin_PROGRAMS = cview cviewall $(SRC_COND_COMPILES)
EXTRA_PROGRAMS=oscview

EXTRA_DIST = *.h

cview_SOURCES = ObjectTracker.m cview.m CViewScreenDelegate.m
cview_LDFLAGS = $(OPENGL_LDFLAGS) $(BASELDFLAGS)
cviewall_SOURCES = cviewall.m CViewScreenDelegate.m 
cviewall_LDFLAGS = $(OPENGL_LDFLAGS) $(BASELDFLAGS)
oscview_SOURCES =  oscview.m glutstub.c
oscview_LDFLAGS = -lOSMesa -lGL -lGLU $(BASELDFLAGS)


