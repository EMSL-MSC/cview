OBJC=gcc
AM_OBJCFLAGS=-g -Wall -fobjc-exceptions -O0 -DPKG_DATA_DIR=\@\"$(pkgdatadir)/\"
OBJCDEPMODE = depmode=gcc

# set the include path found by configure
INCLUDES = $(all_includes) -I$(top_srcdir)/libcview -I$(top_srcdir)/libcview-data
pkginclude_HEADERS = $(wildcard *.h) $(wildcard DataCenter/*.h)

lib_LTLIBRARIES = libcview.la 

libcview_la_SOURCES = ColorMap.m GLImage.m DrawableObject.m Eye.m \
	GLGrid.m  GLScreen.m GLWorld.m Scene.m \
	utils.m GLBar.m\
	GLText.m DefaultGLScreenDelegate.m \
    IdDatabase.m Identifiable.m GLTooltip.m \
    Graph.m GLInfinibandNetwork.m GimpGradient.m
if HAVE_ATB
libcview_la_SOURCES += AntTweakBarOverlay.m AntTweakBarManager.m 
endif

if COMPILE_GLDATACENTER
libcview_la_SOURCES += GLDataCenter.m DataCenter/Rack.m DataCenter/Node.m \
    DataCenter/Locatable.m DataCenter/Vector.m
endif


libcview_la_OBJCFLAGS = $(WAND_CFLAGS) $(AM_OBJCFLAGS) $(FTGL_CFLAGS)
libcview_la_LDFLAGS = $(FOUNDATION_LDFLAGS) $(OPENGL_LDFLAGS) $(WAND_LIBS) $(FTGL_LIBS) $(GENDERS_LDFLAGS)
