/*

This file is part of the CVIEW graphics system, which is goverened by the following License

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
/**
Implementation of the eye or camera in a 3D world. 
\author Evan Felix
\ingroup cview3d
*/
@interface Eye: NSObject <PList> {
	float x,y,z,hangle,vangle;
	float lx,ly,lz;
	float rx,ry,rz;
	float ux,uy,uz;
	int emove;
	float strafe_speed,rotate_speed,move_speed;
}
-init;
/** set location and orientation of eye
@param _x x component
@param _y y component
@param _z z component
@param h Horizontal angle that the camera is looking
@param v Vertical angle that the camera is looking
*/
-setX:(float)_x Y: (float)_y Z: (float)_z Hangle: (float)h Vangle: (float)v;
/** internal function to calculate stuff when changes are made */
-setLooks;
/** @param h Horizontal angle that the camera is looking */
-setHangle:(float)h;
/** @param v Vertical angle that the camera is looking */
-setVangle:(float)v;
/** call the gluLookAt call with the eye's current parameters */
-lookAt;
/**rotate in the horizontal direction(turn left or right)*/
-hrotate: (float)delta;
/**rotate in the vertical direction(look up or down)*/
-vrotate: (float)delta;
/**move forward or backward*/
-moveDistance: (float)dist;
/**move in a parallel to the screen motion up or down*/
-strafeVertical: (float)dist;
/**move in a parallel to the screen motion left or right*/
-strafeHorizontal: (float)dist;
-description;
/**dump the Eye positions to the debug log*/
-debug;
@end 
