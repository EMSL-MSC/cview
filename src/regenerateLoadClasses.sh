#!/bin/bash

cd `dirname $0`/..

echo "/*

This file is port of the CVIEW graphics system, which is goverened by the following License

Copyright © 2008,2009, Battelle Memorial Institute
All rights reserved.

1.  Battelle Memorial Institute (hereinafter Battelle) hereby grants permission
    to any person or entity lawfully obtaining a copy of this software and
    associated documentation files (hereinafter “the Software”) to redistribute
    and use the Software in source and binary forms, with or without
    modification.  Such person or entity may use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and may permit
    others to do so, subject to the following conditions:

    •   Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimers. 
    •   Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
    •   Other than as used herein, neither the name Battelle Memorial
        Institute or Battelle may be used in any form whatsoever without the
        express written consent of Battelle.  
    •   Redistributions of the software in any form, and publications based
        on work performed using the software should include the following
        citation as a reference:

            (A portion of) The research was performed using EMSL, a
            national scientific user facility sponsored by the
            Department of Energy\'s Office of Biological and
            Environmental Research and located at Pacific Northwest
            National Laboratory.

2.  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE OR CONTRIBUTORS BE LIABLE FOR ANY
    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
    THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

3.  The Software was produced by Battelle under Contract No. DE-AC05-76RL01830
    with the Department of Energy.  The U.S. Government is granted for itself
    and others acting on its behalf a nonexclusive, paid-up, irrevocable
    worldwide license in this data to reproduce, prepare derivative works,
    distribute copies to the public, perform publicly and display publicly, and
    to permit others to do so.  The specific term of the license can be
    identified by inquiry made to Battelle or DOE.  Neither the United States
    nor the United States Department of Energy, nor any of their employees,
    makes any warranty, express or implied, or assumes any legal liability or
    responsibility for the accuracy, completeness or usefulness of any data,
    apparatus, product or process disclosed, or represents that its use would
    not infringe privately owned rights.  

*/
#import <Foundation/Foundation.h>
#import \"LoadClasses.h\"
"

for x in `find . -name "*.h" | sort`; do
	DIRNAME=`dirname $x`
	BASENAME=`basename $DIRNAME`
	if [ "$BASENAME" = "DataCenter" ]; then
		BASENAME="${BASENAME}/"
	else
		BASENAME=""
	fi
	if [ `basename $x` != AntTweakBarManager.h -a `basename $x` != AntTweakBarOverlay.h ]; then
		echo '#import '\"${BASENAME}`basename $x`\" ;
	fi
done

echo "
extern int aninteger;
extern int nsarray_integer;

@implementation LoadClasses
+(void)loadAllClasses {
    /* How to regenerate this class:  run: ./regenerateLoadClasses.sh
     */

/* These two statements do not impact how cview runs.  Rather,
 * they are here to get the linker to pull in some extra functions
 * that otherwise get stripped out on mingw
 */
aninteger++;
nsarray_integer++;

"

function contains() {
    local c
    for c in "${@:2}"
    do
        [[ "$c" == "$1" ]] && return 0
    done
    return 1
}

gendersclasses=(Vector Node Rack Locatable GLDataCenter)
ignoreclasses=(ATB_Node BarWrapper NumberObject SceneObject JobDataSetMutableInt AntTweakBarManager AntTweakBarOverlay IBLink IBPort GimpSegment IBChassis GraphVertex UpdateRunLoop)
#set -x
/bin/grep -n --color=auto @implementation `find libcview libcview-data -name "*.[hm]"` |sort| \
	(while read x; do
	 	c=`echo $x | sed 's+^.*@implementation ++g' | sed 's+ .*$++g'`
		if ! contains $c "${ignoreclasses[@]}"
        then
			DEFINE=""
			if contains $c "${gendersclasses[@]}"
            then
				DEFINE="HAVE_GENDERS"
			fi
			if [ "X$DEFINE" != "X" ] ; then
				echo '#if '"$DEFINE"
			fi
		 	echo '['$c' class];'
			if [ "X$DEFINE" != "X" ] ; then
				echo '#endif'
			fi
		fi
	done)

echo "}
@end"
