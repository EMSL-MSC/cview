# not a GNU package. You can remove this line, if
AM_OBJCFLAGS=-pg

# have all needed files, that a GNU package needs
AUTOMAKE_OPTIONS = foreign 1.4

SUBDIRS = libcview libcview-data data src man $(OPTBUILD)
DIST_SUBDIRS = libcview libcview-data data src man tests

EXTRA_DIST = autogen.sh contrib/*.desktop \
             docs/cview.dox docs/copying.txt docs/images/sample.png \
             $(wildcard scripts/*) cview.spec cview.spec.in

docs: docs/html/index.html
docs/html/index.html: */*.h */*.m */*.c docs/*.dox Doxyfile Doxyfile.in
	doxygen
