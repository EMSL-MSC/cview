
CFLAGS= -I/GNUstep/System/Library/Headers  

CFLAGS+= -L/GNUstep/System/Library/Libraries -L/mingw/lib -I/mingw/include -MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -D_REENTRANT -fPIC -Wall -DGSWARN -DGSDIAGNOSE -Wno-import -g -fconstant-string-class=NSConstantString -lgnustep-base -lobjc  
all:
	gcc -c -o MYClass.o MYClass.m $(CFLAGS)
	gcc -c -o test.o test.m $(CFLAGS)
	gcc test.o MYClass.o  $(CFLAGS)
