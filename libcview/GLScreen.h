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
#import "GLScreenDelegate.h"

@class AScreen;
/**
GLScreen manages The main screen of the world, it contains a number of GLWorld objects which are represented as 2d rectangles within the GLScreen main window.  These Worlds are managed using a container: AScreen

@dot
digraph ascreenmanage {
	rankdir=LR;
	edge [fontsize=10];
	node [ shape=box fontsize=10 ];
	g [ label="GLScreen" URL="\ref GLScreen" ];
	a [ label="AScreen" URL="\ref AScreen" ];	
	w [ label="GLWorld" URL="\ref GLWorld" ];
	g -> a [headlabel="*" taillabel="1"];
	a -> w [headlabel="1" taillabel=" 1"];
}
@enddot
@ingroup cview3d
@author Evan Felix
*/
@interface GLScreen:NSObject <PList> {
	int mainwin; /**< glut window ID of container window*/
	id delegate; /**< GLScreenDelegate for input event handling */
	NSMutableSet *worlds; /**< set of world or screens that managed. Should contain AScreen objects*/
	int width,height; 
	BOOL redrawNeeded,isFullscreen;
	int oldWidth,oldHeight;
	NSAutoreleasePool *pool;
	NSString *myName;
	BOOL logDrawClocks;
}
/** initializer that creates a window of size 800x600*/
-initName: (NSString *)name;

/** Initializer to setup a basic window with given size
@param w width of window
@param h height of window
@param name Title of window, may be show in title bars, etc
*/
-initName: (NSString *)name withWidth: (int) w andHeight:(int)h;
-resizeWidth:(int)w Height:(int)h;
-(int)makeGLWindow: (AScreen *)s;

/**
Add a world into a new window specified by the layout parameters
@param name name for the window for identification
@param _row Row to put the world in
@param _col Column to place the world in
@param _rowp Percentage of the whole window that the world should request
@param _colp Percentage of the whole row that the world should request
@return returns a newly allocated GLWorld that can then be used for adding objects to
*/
-(GLWorld *)addWorld: (NSString *)name row: (int)_row col: (int)_col rowPercent: (int)_rowp colPercent: (int)_colp; -dumpScreens;
/**
 Return a list of all currently managed worlds
 */
-(NSArray *)getWorlds;
/** Run the Screen system. Not expected to return */
-run;

-doLayout;

/**
Return an AScreen which is itentified by the glut window id
	@param window glut window id
	@return AScreen object or nil if not found
*/
-(AScreen *)findWindow:(int)window;

/** redraw a specified window id
	@param window glut window id
*/
-renderWindow:(int)window;

/** set the current delegate for recieveing input events */
-setDelegate: (id)adelegate;

/** return current instance recieveing input events */
-(id)delegate;
-keyPress: (unsigned char)key atX: (int)x andY: (int)y withWindow: (int)window;
-specialKeyPress: (int)key atX: (int)x andY: (int)y withWindow: (int)window;
-mouseButton: (int)button withState: (int)state atX: (int)x andY: (int)y withWindow: (int)window;
-mouseActiveMoveAtX: (int)x andY: (int)y withWindow: (int)window;
-mousePassiveMoveAtX: (int)x andY: (int)y withWindow: (int)window;

/** adjust world location */
-moveWorld: (GLWorld *)world Row: (int)rowchange Col: (int)colchange;
/** adjust world view size: these changes will be added to the row and column percentages */
-resizeWorld:(GLWorld *)world Width: (int)widthchange Height: (int)heightchange;

/** which window is on top at passed (x,y) coordinates */
-(int)getWindowAtX: (int)x andY: (int)y;

/** do the actual work of telling glut to re-draw every window */
-postRedrawAll;
-checkState;
-causeFullRedraw: (NSNotification *)notification;
-toggleFullscreen;

/** @return The singleton master GLScreen for glut events */
+(GLScreen *)getMaster;

/** @param m the new singleton master for handling all glut events */
+setMaster: (GLScreen *)m;

/** empty the autorelease pool */
-resetPool;
@end
