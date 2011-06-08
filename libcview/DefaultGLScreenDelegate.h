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
/**
	Default Delegate for basic FPS like viewing of the world.  Supports an AntTweakBarManager if the library is available.

	Move World commands move the GLWorld under the cursor by rows or columns. These keys will probably change focus, so subsequent keys may be passed to whatever window is now under the cursor.

	Keys:
@dot
digraph keymap {
	node [shape=record]
	dir [ label="{w|a|s|d}|{Strafe Up|Strafe Down|Strafe Left|Strafe Right}" ];
	rot [ label="{PageUp|PageDown|UpArrow|DownArrow|LeftArrow|RightArrow}|{Pitch Upward|Pitch Downward|Move Forward|Move Backward|Turn Left|Turn Right}"];
	win [ label="{h|j|k|l}|{Move World Left|Move World Down|Move World Up|Move World Right}"];
	extra [ label="{q|z|f|p|t}|{Quit Program|Dump Screen to file|Full Screen toggle|Print Current Eye|toggle AntTweakBar}"];
}
@enddot		
	@author Evan Felix
	@ingroup cview3d
*/
#ifndef DEFAULTGLSCREENDELEGATE_H
#define DEFAULTGLSCREENDELEGATE_H
#import <Foundation/Foundation.h>
#import "GLScreenDelegate.h"
#import "GLWorld.h"
#import "GLScreen.h"

#if HAVE_ANTTWEAKBAR
#import "AntTweakBarManager.h"
#import "AntTweakBarOverlay.h"
#endif

@interface DefaultGLScreenDelegate: NSObject <GLScreenDelegate> {
	GLScreen *myScreen;
	float mouseX,mouseY;
	BOOL mouseSlide;
	BOOL mouseZoom;
	BOOL mouseRotate;
#if HAVE_ANTTWEAKBAR
	AntTweakBarManager *tweaker;
#else
	id tweaker;
#endif
	NSMutableSet *tweakoverlays;
}
-initWithScreen: (GLScreen *)screen;
#if HAVE_ANTTWEAKBAR
-setupTweakers;
-cleanTweakers;
#endif
/**
    This selector is called from [GLWorld glPickDraw] to allow the 
    screen delegate to decide what to do with the selections that were made
    @param hitCount the number of selections returned by glRenderMode()
    @param selectBuf an OpenGL selection buffer (see gl docs for more info)
    @param buffSize is the size of the selectBuf array
  */
-processHits: (GLint) hitCount buffer: (GLuint*) selectBuf andSize: (GLint) buffSize inWorld: (GLWorld*) world;
@end
#endif
