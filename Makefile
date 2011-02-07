

CFLAGS= -MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -D_REENTRANT -fPIC -Wall -DGSWARN -DGSDIAGNOSE -Wno-import -g -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -fgnu-runtime -fconstant-string-class=NSConstantString -I. -I/home/berwin/GNUstep/Library/Headers -I/usr/local/include/GNUstep -I/usr/include/GNUstep   -lOSMesa -lGL -lGLU -rdynamic -Wl,-Bsymbolic-functions -shared-libgcc -fexceptions -fgnu-runtime -L/home/berwin/GNUstep/Library/Librarie -L/usr/local/lib -L/usr/lib -lgnustep-base -lpthread -lobjc  
all:
	gcc -c -o MYClass.o MYClass.m $(CFLAGS)
	gcc -c -o test.o test.m $(CFLAGS)
	gcc test.o MYClass.o  $(CFLAGS)
