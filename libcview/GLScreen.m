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
/**
@author Evan Felix
@ingroup cview3d
*/

#import <gl.h>
#import <glut.h>
#import <Foundation/Foundation.h>
#include <unistd.h>
#include <sys/time.h>
#include "debug.h"
#import "cview.h"
#import "ListComp.h"
#import "PList.h"

@interface AScreen: NSObject <PList> {
	@public
	NSString *name;
	int window;
	GLWorld * world;
	int row,col,rowp,colp; //layout parameters
	int x,y,w,h; //calculated by layout
}
-setDelegate:(id)_delegate;
@end

@implementation AScreen
-getPList {
	NSLog(@"AScreen: %@ %d %d %d %d",world,row,col,rowp,colp);
	NSLog(@"world: %@",[world getPList]);
	return [NSDictionary dictionaryWithObjectsAndKeys: 
		[world getPList],@"world",
		[NSNumber numberWithInt: row],@"row",
		[NSNumber numberWithInt: col],@"col",
		[NSNumber numberWithInt: rowp],@"rowp",
		[NSNumber numberWithInt: colp],@"colp",
		name,@"name",
		nil];
}

-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
	row = [[list objectForKey: @"row"] intValue];
	col = [[list objectForKey: @"col"] intValue];
	rowp = [[list objectForKey: @"rowp"] intValue];
	colp = [[list objectForKey: @"colp"] intValue];
	name = [[list objectForKey: @"name"] retain];	/// @todo release this somewheres

	world=[GLWorld alloc];
	[world initWithPList: [list objectForKey: @"world"]];
	return self;
}
-setDelegate:(id)_delegate {
    [world setDelegate: _delegate];
    return self;
}
@end

//GLUT glue Code
void _processNormalKeys(unsigned char key, int x, int y) {
	//NSLog(@"processNormalKeys: %c (%d,%d):%d",key,x,y,glutGetWindow());	
	[[GLScreen getMaster] keyPress: key atX: x andY: y withWindow: glutGetWindow()];
}
void _processSpecialKeys(int key, int x, int y) {
	//NSLog(@"processSpecialKeys: %x (%d,%d):%d",key,x,y,glutGetWindow());	
	[[GLScreen getMaster] specialKeyPress: key atX: x andY: y withWindow: glutGetWindow()];
}
void _processMouse(int button, int state, int x, int y) {
	//NSLog(@"processMouse: %d %d (%d,%d)",button,state,x,y);
	[[GLScreen getMaster] mouseButton: button withState: state atX: x andY: y withWindow: glutGetWindow()];
}
void _processMouseActiveMotion(int x, int y) {
	//NSLog(@"processMouseActiveMotion: (%d,%d)",x,y);
	[[GLScreen getMaster] mouseActiveMoveAtX: x andY: y withWindow: glutGetWindow()];
}
void _processMousePassiveMotion(int x, int y) {
	//NSLog(@"processMousePassiveMotion: (%d,%d)",x,y);
	[[GLScreen getMaster] mousePassiveMoveAtX: x andY: y withWindow: glutGetWindow()];
}
void _changeSize(int w, int h) {
	//NSLog(@"_changeSize (%d,%d)",w,h);
	[[GLScreen getMaster] resizeWidth: w Height: h];
}
void _renderScene() {
	//NSLog(@"_renderScene:%d",glutGetWindow());
	[[GLScreen getMaster] renderWindow: glutGetWindow()];
}
void _renderSceneBackground() {
	//NSLog(@"_renderScene:%d",glutGetWindow());
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glutSwapBuffers();	
}
void _renderSceneAll() {
	usleep(1000);
	//NSLog(@"_renderSceneAll");
}
void _periodicTimer(int value) {
	[[GLScreen getMaster] checkState];
//	NSLog(@"periodic timer");
	glutTimerFunc(100,_periodicTimer,0);
}
void _periodicPoolTimer(int value) {
	[[GLScreen getMaster] resetPool];
	glutTimerFunc(3000,_periodicPoolTimer,0);
}
//end glut glue

static GLScreen *_theMaster_ = nil;

/** sort helper function that compares two AScreen objects
	@relates AScreen
 */
int compareScreenColumns(id one,id two,void *context) {
	AScreen *o=one;
	AScreen *t=two;
	if (o->col < t->col)
		return -1;
	if (o->col > t->col)
		return 1;
	return 0;
}

@implementation GLScreen
+(void)initialize {
	[[NSUserDefaults standardUserDefaults] registerDefaults: 
		[NSDictionary dictionaryWithObject: @"no" forKey:@"GLScreenLogDrawClocks"]];
}

-initName: (NSString *)name {
	[self initName:name withWidth: 800 andHeight: 600];
	return self;
}

/**@objcdef 
	- GLScreenLogDrawClocks - Output the time taked in the draw code for a GLWorld
*/
-initName: (NSString *)name withWidth: (int) w andHeight:(int)h {
	if ([GLScreen getMaster] == nil)
		[GLScreen setMaster: self];
	else
		return nil;
	int c=0;

	isFullscreen = NO;

	myName = [name retain];

	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];

	logDrawClocks = [defs boolForKey:@"GLScreenLogDrawClocks"];

	glutInit(&c,NULL);
	glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA );
	glutInitWindowSize(w,h);
	width = w;
	height = h;
	mainwin = glutCreateWindow([myName UTF8String]);
	glutReshapeFunc(_changeSize);
	glutDisplayFunc(_renderSceneBackground);
	//glutIdleFunc(_renderSceneAll);

	//Gl init stuffage
    glShadeModel(GL_SMOOTH);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_POINT_SMOOTH);
    //glEnable(GL_LINE_SMOOTH);
   	
    glDepthFunc(GL_LEQUAL);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClearDepth(1.0);

	worlds = [NSMutableSet setWithCapacity: 4];
	[worlds retain];
	
	delegate = [[DefaultGLScreenDelegate alloc] initWithScreen: self];

	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(causeFullRedraw:) name: @"DataSetUpdate" object: nil];
	glutTimerFunc(500,_periodicTimer,0);

//We have to hack a little here for non-apple glut implementations that dont know anything about release pools, so dont periodically release the pool in glutMainLoop
#ifndef __APPLE__
	pool = [[NSAutoreleasePool alloc] init];
	glutTimerFunc(3000,_periodicPoolTimer,1);
#endif
	glutPostRedisplay();
	return self;
}

-getPList {
	NSLog(@"GLScreen getPList: %@",self);

	NSArray *ws = [[worlds allObjects] arrayObjectsFromPerformedSelector: @selector(getPList)];
	return [NSDictionary dictionaryWithObjectsAndKeys: ws, @"worlds", 
		[NSNumber numberWithInt: width],@"width",
		[NSNumber numberWithInt: height],@"height",
		myName,@"name",
		nil];
}

-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);

	[self initName: [list objectForKey: @"name"]
			withWidth: [[list objectForKey: @"width"] intValue]
			andHeight: [[list objectForKey: @"height"] intValue]
	];

	NSArray *ws = [list objectForKey: @"worlds"];
	//NSLog(@"%@",ws);
	AScreen *s;
	id l;
	NSEnumerator *e;
	e = [ws objectEnumerator];
	while ((l = [e nextObject])) {
		s=[AScreen alloc];
		[s initWithPList: l];
		[worlds addObject: s];
		[self doLayout];
		s->window = [self makeGLWindow: s];
	}
	return self;
}


-(void)dealloc {
	AScreen *s;
	NSEnumerator *list;
	NSLog(@"GLScreen dealloc");
	list = [worlds objectEnumerator];
	while ((s = [list nextObject])) {
		[s->world autorelease];
		[s autorelease];
	}
	[worlds autorelease];
	[myName autorelease];
	[delegate autorelease];
	[super dealloc];
	return;
}

-resizeWidth:(int)w Height:(int)h {
	AScreen *s;
	NSEnumerator *list;
	double ratio;

	//if ( abs(w-width)+abs(h-height) < 5 )
	//	return self;

	width = w;
	height = h;


	[self doLayout];

	list = [worlds objectEnumerator];
	while ((s = [list nextObject])) {
		if (s->window<0)
			break;
		glutSetWindow(s->window);
		glutPositionWindow(s->x,s->y);
		glutReshapeWindow(s->w,s->h);
	
		glViewport(0, 0, s->w, s->h);
		ratio = 1.0f*s->w/s->h;
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();	
		
		gluPerspective(20.0,ratio,0.1,9000);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		//glutPostRedisplay();
	}
	[[NSNotificationCenter defaultCenter] postNotificationName: @"GLScreenWindowSizeChanged" object: self];

	return self;
}
/**Internal Function*/
-(int)makeGLWindow: (AScreen *)s {
	int win = glutCreateSubWindow(mainwin,s->x,s->y,s->w,s->h);
	glutDisplayFunc(_renderScene);
	glutKeyboardFunc(_processNormalKeys);
	glutSpecialFunc(_processSpecialKeys);
	glutMouseFunc(_processMouse);
	glutMotionFunc(_processMouseActiveMotion);
	glutPassiveMotionFunc(_processMousePassiveMotion);
	glEnable(GL_DEPTH_TEST);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	//Gl init stuffage
	glEnable(GL_POINT_SMOOTH);
	glEnable(GL_LINE_SMOOTH);

	glEnable(GL_POLYGON_OFFSET_FILL);

	glDepthFunc(GL_LEQUAL);
	glClearDepth(1.0);

	glClearColor(0.0, 0.0, 0.0, 1.0);
	return win;
}

-(GLWorld *)addWorld: (NSString *)name row: (int)_row col: (int)_col rowPercent: (int)_rowp colPercent: (int)_colp {
	GLWorld *gw = [[GLWorld alloc] init];
	AScreen *s = [AScreen alloc];
	s->name = name;
	s->world = gw;
	s->row = _row;
	s->col = _col;
	s->rowp = _rowp;
	s->colp = _colp;
	[worlds addObject: s];
	[self doLayout];
	//Create Sub Window
	s->window = [self makeGLWindow: s];
	return gw;
}

/** Internal function that calculated relative position of each window based on the requests made by each world for row and colum position
	lays out rows and then by column.  Called normaly during screen size changes and world set additions or removals
*/
-doLayout {
	int rowc,colc,row_place,col_place,row;
	float rptotal,cptotal;
	// calc num rows and cols, total up percentages
	NSEnumerator *list;
	AScreen *s;
	NSMutableArray *therow;
	
	rowc=0;
	colc=0;
	list = [worlds objectEnumerator];
	while ((s = [list nextObject])) {
		rowc = MAX(rowc,s->row);
		colc = MAX(colc,s->col);
	}
	//NSLog(@"RC %d %d",rowc,colc);
	
	rptotal=0.0;
	for (row=0;row<=rowc;row++) {
		//find max for row
		int rm=0;
		list = [worlds objectEnumerator];
		while ((s = [list nextObject])) {
			if (row == s->row)
				rm = MAX(rm,s->rowp);
		}
		rptotal += rm;
	}
	//NSLog(@"rptotal: %f",rptotal);
		
	//loop over rows
	row_place=0;
	for (row=0;row<=rowc;row++) {
		int rowmax=0;
		//calc max rowp for row  (probably a better way?) make col array on the way
		therow = [NSMutableArray arrayWithCapacity: colc];
		list = [worlds objectEnumerator];
		while ((s = [list nextObject])) {
			if (s->row == row) {
				rowmax = MAX(rowmax,s->rowp);
				[therow addObject: s];
			}
		}
		
		//calc real row height
		int rowh = (int)(height*rowmax/rptotal);
		
		//calc row widths total
		cptotal=0.0;
		list = [therow objectEnumerator];
		while ((s = [list nextObject])) {
			//printf("S<%@>: (%d,%d)\n",s->name,s->row,s->col);
			cptotal += s->colp;
		}
		//NSLog(@"cptotal: %f",cptotal);
		
		[therow sortUsingFunction: compareScreenColumns context: NULL];
		//calc actual sizes
		col_place = 0;
		list = [therow objectEnumerator];
		while ((s = [list nextObject])) {
			//NSLog(@"S<%@>: (%d,%d)",s->name,s->row,s->col);
			int colw =(int)(width*s->colp/cptotal);
			//setup actual place now
			s->x = col_place+1;
			s->y = row_place+1;
			s->w = colw-2;
			s->h = rowh-2;
			col_place += colw;
		}
		row_place += rowh;
	}
	return self;
}

/** dump out a list of the current screens being managed */
-dumpScreens {
	AScreen *s;
	NSEnumerator *list;
	
	list = [worlds objectEnumerator];
	while ((s = [list nextObject])) {
		NSLog(@"S<%@>: RC(%d,%d) - (%d,%d) -> (%d,%d) win:%d",s->name,s->row,s->col,s->x,s->y,s->x+s->w,s->y+s->h,s->window);
	}	
	return self;
}

-run {
	glutMainLoop();
	return self;
}

-(AScreen *)findWindow:(int)window {
	AScreen *s;
	NSEnumerator *list;
	list = [worlds objectEnumerator];
	while ((s = [list nextObject])) 
		if (s->window == window) 
			return s;
	//NSLog(@"Window not found");
	return nil;
}

double mysecond()
{
  struct timeval tp;
  struct timezone tzp;
  int i;

  i = gettimeofday(&tp,&tzp);
  return ( (double) tp.tv_sec + (double) tp.tv_usec * 1.e-6 );
}

-renderWindow:(int)window {
	double start,end;
	AScreen *s;
	if (( s=[self findWindow: window] )) {
		start = mysecond();
		[s->world glDraw];
		end = mysecond();		
		glutSwapBuffers();
		if (logDrawClocks)
			NSLog(@"Clocks fer Drawing %@: %3.6lf",s->name,end-start);
	}
	return self;
}

-setDelegate: (id)adelegate {
	[delegate autorelease];
    if(adelegate == nil)
        return self;
	delegate = [adelegate retain];
    NSLog(@"makeobjects....");
    [worlds makeObjectsPerformSelector: @selector(setDelegate:) withObject: delegate];
    NSLog(@"done");
	return self;
}

-(id)delegate {
	return delegate;
}

-keyPress: (unsigned char)key atX: (int)x andY: (int)y withWindow: (int)window {
	AScreen *s;
	BOOL handled=NO;	

	if (( s=[self findWindow: window] )) {
		if (delegate && [delegate respondsToSelector:@selector(keyPress:atX:andY:inGLWorld:)])
			handled = [delegate keyPress: key atX: x andY: y inGLWorld: s->world];
		glutPostRedisplay();	
	}
	return self;
}

-specialKeyPress: (int)key atX: (int)x andY: (int)y withWindow: (int)window {
	AScreen *s;
	BOOL handled=NO;	

	if (( s=[self findWindow: window] )) {
		if (delegate && [delegate respondsToSelector:@selector(specialKeyPress:atX:andY:inGLWorld:)])
			handled = [delegate specialKeyPress: key atX: x andY: y inGLWorld: s->world];
		glutPostRedisplay();	
	}
	return self;
}

-mouseButton: (int)button withState: (int)state atX: (int)x andY: (int)y withWindow: (int)window {
	AScreen *s;
	if (( s=[self findWindow: window] )) {
		//	NSLog(@"Delegate: %@ %d",delegate, [delegate respondsToSelector:@selector(mouseButton:withState:atX:andY:inGLWorld:)]);
		if (delegate && [delegate respondsToSelector:@selector(mouseButton:withState:atX:andY:inGLWorld:)])
			[delegate mouseButton: button withState: state atX: x andY: y inGLWorld:s->world];
	}
	glutPostRedisplay();
	return self;
}

-mouseActiveMoveAtX: (int)x andY: (int)y withWindow: (int)window {
	AScreen *s;
	if (( s=[self findWindow: window] )) {
		if (delegate && [delegate respondsToSelector:@selector(mouseActiveMoveAtX:andY:inGLWorld:)])
			[delegate mouseActiveMoveAtX: x andY: y inGLWorld:s->world];
	}
	glutPostRedisplay();
	return self;
}

-mousePassiveMoveAtX: (int)x andY: (int)y withWindow: (int)window {
	AScreen *s;

	if (( s=[self findWindow: window] )) {
		if (delegate && [delegate respondsToSelector:@selector(mousePassiveMoveAtX:andY:inGLWorld:)])
			[delegate mousePassiveMoveAtX: x andY: y inGLWorld:s->world];
	}
	glutPostRedisplay();
	return self;
}

/** 
	schedule a full re-draw of all windows as soon as possible on the graphics thread
*/
-causeFullRedraw:(NSNotification *)notification {
	redrawNeeded=YES;
	return self;
}

-checkState {
	if (redrawNeeded) {
		redrawNeeded=NO;
		[self postRedrawAll];
	}
	//[pool release];
	//pool = [[NSAutoreleasePool alloc] init];
	return self;
}

-postRedrawAll {
	AScreen *s;
	NSEnumerator *list;
	list = [worlds objectEnumerator];
	while (( s = [list nextObject] )) {
		glutSetWindow(s->window);
		glutPostRedisplay();
	}
	return self;
}

-toggleFullscreen {
	NSLog(@"toggleFullscreen: %d (%d,%d)",isFullscreen,oldWidth,oldHeight);
	
	glutSetWindow(mainwin);

	if (isFullscreen) {
		glutReshapeWindow(oldWidth,oldHeight);
	}
	else {
		oldWidth=width;
		oldHeight=height;
		glutFullScreen();
	}
	isFullscreen = ! isFullscreen;
	[self postRedrawAll];
	return self;
}

+(GLScreen *)getMaster {
	return _theMaster_;
	return self;
}

+setMaster: (GLScreen *)m {
	_theMaster_ = m;
	return self;
}

-resetPool {
	[pool release];
	pool = [[NSAutoreleasePool alloc] init];
	return self;
}
@end //GLScreen


