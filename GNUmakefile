include $(GNUSTEP_MAKEFILES)/common.make



LIBRARY_NAME = libMYClass
libMYClass_HEADER_FILES = MYClass.h
libMYClass_HEADER_FILES_INSTALL_DIR = MYClass
libMYClass_OBJC_FILES = MYClass.m

include $(GNUSTEP_MAKEFILES)/library.make

TOOL_NAME = test
test_OBJC_FILES = test.m
test_TOOL_LIBS += -Lobj -lMYClass

include $(GNUSTEP_MAKEFILES)/tool.make

