/*

This file is port of the CVIEW graphics system, which is goverened by the following License

Copyright © 2008,2009, Battelle Memorial Institute
All rights reserved.

1.	Battelle Memorial Institute (hereinafter Battelle) hereby grants permission
	to any person or entity lawfully obtaining a copy of this software and
	associated documentation files (hereinafter “the Software”) to redistribute
	and use the Software in source and binary forms, with or without
	modification.  Such person or entity may use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and may permit
	others to do so, subject to the following conditions:

	•	Redistributions of source code must retain the above copyright
		notice, this list of conditions and the following disclaimers. 
	•	Redistributions in binary form must reproduce the above copyright
		notice, this list of conditions and the following disclaimer in the
		documentation and/or other materials provided with the distribution.
	•	Other than as used herein, neither the name Battelle Memorial
		Institute or Battelle may be used in any form whatsoever without the
		express written consent of Battelle.  
	•	Redistributions of the software in any form, and publications based
		on work performed using the software should include the following
		citation as a reference:

			(A portion of) The research was performed using EMSL, a
			national scientific user facility sponsored by the
			Department of Energy's Office of Biological and
			Environmental Research and located at Pacific Northwest
			National Laboratory.

2.	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE OR CONTRIBUTORS BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
	THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

3.	The Software was produced by Battelle under Contract No. DE-AC05-76RL01830
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
#import "PList.h"
/* useful Information on GGR's
http://c-cpp.r3dcode.com/files/GIMP/2/7.3/devel-docs/ggr.txt
http://nedbatchelder.com/code/modules/ggr.py
*/


/** 
This class implements the a Gimp Gradient (ggr) interface for reading, and then generating RGBA color values fromt he gradient.

We do not surrently support HSV coloring Types.

@author Evan Felix <evan.felix@pnl.gov>, (C) 2012
@ingroup cview3d
*/
typedef enum {FROMNONE=0, FROMFILE, FROMSTRING} GGRsource;
#define FROMFILE_STRING @"file"
#define FROMSTRING_STRING @"string"
@interface GimpGradient: NSObject <PList> {
	GGRsource source;
    NSString *name;
	/** holds either a filename or the full GGR string depending on source type */
	NSString *dataSource;
	NSMutableArray *segments;
    float lastcolor;
    float lastRGBA[4];
}
-init;
-initWithFile: (NSString*)filename;
-initWithString: (NSString*)string;
-parseGGR: (NSString *)ggr;
/**return the Red component of the gradient at position from 0.0 to 1.0 */
-(float)getR: (float)i;
/**return the Red component of the gradient at position from 0.0 to 1.0 */
-(float)getG: (float)i;
/**return the Red component of the gradient at position from 0.0 to 1.0 */
-(float)getB: (float)i;
/**return the Red component of the gradient at position from 0.0 to 1.0 */
-(float)getA: (float)i;
/**return the Red,Green,Blue,Alpha component of the gradient at position from 0.0 to 1.0 into a float[4] array */
-putRGBA: (float)i into: (float*)array;
@end