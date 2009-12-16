OBJC=gcc
AM_OBJCFLAGS=-g -Wall  -fobjc-exceptions -O0 -DPKG_DATA_DIR=\@\"$(pkgdatadir)/\"
OBJCDEPMODE = depmode=gcc

# set the include path found by configure
INCLUDES = $(all_includes) -I$(top_srcdir)/libcview -I$(top_srcdir)/libcview-data
pkginclude_HEADERS = *.h

lib_LTLIBRARIES = libcview.la

libcview_la_SOURCES = ColorMap.m GLImage.m DrawableObject.m Eye.m \
	GLGrid.m GLGridSurface.m GLScreen.m GLWorld.m Scene.m \
	utils.m GLPointGrid.m GLRibbonGrid.m \
	GLText.m DefaultGLScreenDelegate.m MultiGrid.m \
    DataCenter/Rack.m DataCenter/Node.m DataCenter/Locatable.m \
    DataCenter/Isle.m DataCenter/Location.m DataCenter/PMM.m \
    DataCenter/DrawableArray.m DataCenterLoader.m GLDataCenterGrid.m \
    DataCenter/IsleOffsets.m

if HAVE_ATB
libcview_la_SOURCES += AntTweakBarOverlay.m AntTweakBarManager.m 
endif

libcview_la_OBJCFLAGS = $(WAND_CFLAGS) $(AM_OBJCFLAGS) $(FTGL_CFLAGS)
libcview_la_LDFLAGS = $(FOUNDATION_LDFLAGS) $(OPENGL_LDFLAGS) $(WAND_LIBS) $(FTGL_LIBS)

