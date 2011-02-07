
CFLAGS= -I/usr/include/GNUstep -I/GNUstep/System/Library/Headers -L/GNUstep/System/Library/Libraries -L/mingw/lib -I/mingw/include -MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -D_REENTRANT -fPIC -Wall -DGSWARN -DGSDIAGNOSE -Wno-import -g -fconstant-string-class=NSConstantString -lgnustep-base -lobjc  

all:
	gcc -shared -Wl,-soname,libMYClass.so -o libMYClass.so MYClass.m $(CFLAGS)
	gcc -c -o test.o test.m $(CFLAGS)
	gcc test.o -L. -lMYClass $(CFLAGS)


clean:
	rm *.so
	rm *.o 
	rm a.out

