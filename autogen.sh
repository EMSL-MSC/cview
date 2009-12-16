#!/bin/sh -xe

if test "$(uname -s)" == "Darwin" ;
then 
	glibtoolize -c ;
	aclocal -I /opt/local/share/aclocal;
else 
	libtoolize -c ;
	aclocal;
fi
autoheader
automake --add-missing --copy 
autoconf --force
./configure $*
