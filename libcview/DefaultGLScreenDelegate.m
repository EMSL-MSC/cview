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
#include <glut.h>
#import "DefaultGLScreenDelegate.h"
#import "debug.h"

@implementation DefaultGLScreenDelegate 
-initWithScreen: (GLScreen *)screen {
	myScreen = screen; //dont retain... we should be retained by the screen, and we dont want a recursive retainingnesses
	tweaker=nil;
	tweakoverlays = [[NSMutableSet setWithCapacity: 4] retain];
//	[self toggleTweakersVisibility];
	return self;
}

-(void)dealloc {
	[super dealloc];
	return;
}
-screenHasStarted {
	return self;	
}
-(void)setTweakableValues: (NSObject *) val forKey: (NSString *) key {
#if HAVE_ANTTWEAKBAR
	NSEnumerator *e = [tweakoverlays objectEnumerator];
	AntTweakBarOverlay *o;
	while((o = [e nextObject]) != nil) {
		[o setValues: val forKey: key];
	}
#endif
}

-(void)toggleTweakersVisibility {
#if HAVE_ANTTWEAKBAR
	NSLog(@"tweaker:%@",tweaker);
	if (tweaker==nil) {
		[self setupTweakers];
	}
	//could add a toggle visible to DrawableObject...
	else if ([tweaker visible]) {
		[tweaker hide];
	}
	else {
		[tweaker show];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName: @"DataSetUpdate" object: self];
#endif
}

-(BOOL)keyPress: (unsigned char)key atX: (int)x andY: (int)y inGLWorld: (GLWorld *)world; {
	BOOL handled = YES;

	if ( ! (tweaker && [tweaker visible] && [tweaker keyPress: key atX: x andY: y])) {
		switch (key) {
			case 'w':
			case 'W':
				[[world eye] strafeVertical: -1];
				break;
			case 's':
			case 'S':
				[[world eye] strafeVertical: 1];
				break;
			case 'a':
			case 'A':
				[[world eye] strafeHorizontal: -1];
				break;
			case 'd':
			case 'D':
				[[world eye] strafeHorizontal: 1];
				break;
			case 'p':
				NSLog(@"%@",[[world eye] debug]);
				break;
			case 'z': 
				[world dumpImage: @"cview" withBaseDir: @"." dailySubDirs: NO];
				break;
			case 't':
				[self toggleTweakersVisibility];
				break;
			case 'c':
				NSLog(@"Retain Count: %lu %lu",[tweaker retainCount],[tweakoverlays retainCount]);
				break;
			case 'q':
				DUMPALLOCLIST(NO);
				exit(0);
				break;
			case 'f':
				[myScreen toggleFullscreen];
				break;
			case 'h':
				[myScreen moveWorld: world Row: 0 Col: -1];
				break;
			case 'j':
				[myScreen moveWorld: world Row: 1 Col: 0];
				break;
			case 'k':
				[myScreen moveWorld: world Row: -1 Col: 0];
				break;
			case 'l':
				[myScreen moveWorld: world Row: 0 Col: 1];
				break;
			case 'H':
				[myScreen resizeWorld: world Width: -2 Height:  0];
				break;
			case 'J':
				[myScreen resizeWorld: world Width:  0 Height:  2];
				break;
			case 'K':
				[myScreen resizeWorld: world Width:  0 Height: -2];
				break;
			case 'L':
				[myScreen resizeWorld: world Width:  2 Height:  0];
				break;
			default:
				[[NSNotificationCenter defaultCenter] postNotificationName: @"keyPress" object: self userInfo:
					[NSDictionary dictionaryWithObject: [NSNumber numberWithUnsignedChar: key] forKey: @"key"]
				];
				handled=NO;
				break;
		}
	}
	
	return handled;
}

-(BOOL)specialKeyPress: (int)key atX: (int)x andY: (int)y inGLWorld: (GLWorld *)world {
	BOOL handled = YES;

	if ( ! (tweaker && [tweaker visible] && [tweaker specialKeyPress: key atX: x andY: y])) {
		switch (key) {
			case GLUT_KEY_RIGHT:
				[[world eye] hrotate: 1];
				break;
			case GLUT_KEY_LEFT:
				[[world eye] hrotate: -1];
				break;
			case GLUT_KEY_UP:
				[[world eye] moveDistance: 1];
				break;
			case GLUT_KEY_DOWN:
				[[world eye] moveDistance: -1];
				break;
			case GLUT_KEY_PAGE_UP:
				[[world eye] vrotate: 1];
				break;
			case GLUT_KEY_PAGE_DOWN:
				[[world eye] vrotate: -1];
				break;
			default:
				handled=NO;
				[[NSNotificationCenter defaultCenter] postNotificationName: @"keyPress" object: self userInfo:
					[NSDictionary dictionaryWithObject: [NSNumber numberWithInt: key] forKey: @"specialKey"]
				];
				break;
		}	
	}
	
	return handled;
}

//use the movement speeds for keys for now ... ???
-(BOOL)mouseButton: (int)button withState: (int)state atX: (int)x andY: (int)y inGLWorld: (GLWorld *)world {
	if ( ! (tweaker && [tweaker visible] && [tweaker mouseButton: button withState: state atX: x andY: y])) {
		if (state == GLUT_DOWN) {
			mouseX = x;
			mouseY = y;
			switch (button) {
				case GLUT_LEFT_BUTTON:
					mouseSlide=YES;
					break;
				case GLUT_MIDDLE_BUTTON:
					mouseZoom=YES;
					break;
				case GLUT_RIGHT_BUTTON:
					mouseRotate=YES;
					break;
				case 3: // WHEEL_UP
					[[world eye] moveDistance: 1];
					break;
				case 4: // WHEEL_DOWN
					[[world eye] moveDistance: -1];
					break;
				default:
					break;
			}
		}
		else {
			mouseX=0;
			mouseY=0;
			mouseSlide=NO;
			mouseRotate=NO;
			mouseZoom=NO;
		}
	}
	return YES;
}

-(BOOL)mouseActiveMoveAtX: (int)x andY: (int)y inGLWorld: (GLWorld *)world; {
	int xd,yd;
	if ( ! (tweaker && [tweaker visible] && [tweaker mouseActiveMoveAtX: x andY: y])) {
		xd = mouseX-x;
		yd = mouseY-y;
		if (mouseSlide) {
			[[world eye] strafeVertical: yd/3.0];
			[[world eye] strafeHorizontal: xd/3.0];
		}
		if (mouseZoom) {
			[[world eye] moveDistance: yd/3.0];
		}
		if (mouseRotate) {
			[[world eye] hrotate: xd/3.0];
			[[world eye] vrotate: -yd/3.0];
		}
		mouseX = x;
		mouseY = y;
	}
	return YES;
}

-(BOOL)mousePassiveMoveAtX: (int)x andY: (int)y inGLWorld: (GLWorld *)world {
	if ( ! (tweaker && [tweaker visible] && [tweaker mousePassiveMoveAtX: x andY: y])) 
		return NO;
	else
		return YES;
}

#if HAVE_ANTTWEAKBAR
-setupTweakers {
	GLWorld *w;
	Scene *s;
	tweaker = [[AntTweakBarManager alloc] init];
	
	if (tweaker) {
		NSArray *worlds = [myScreen getWorlds];
		NSEnumerator *list;
		list = [worlds objectEnumerator];
		while ((w = [list nextObject])) {
			TwSetCurrentWindow([w context]);
			
			NSLog(@"add tweak: %@ %d",w,[w context]);
			AntTweakBarOverlay *tweakoverlay = [[AntTweakBarOverlay alloc] initWithName: @"GLWorld" andManager: tweaker];
			TwDefine("GLWorld iconified=true label='World Config'");
			[tweakoverlay setTree: w];
			[tweakoverlays addObject: tweakoverlay];

			NSLog(@"add vstweak");
			ValueStoreTweakBar *vstweak = [[ValueStoreTweakBar alloc] initWithManager: tweaker];
      [tweakoverlays addObject:vstweak];

			// find the overlay and add ourselves..
		
			s = [w overlay];
			if (!s) {
				//NSLog(@"Creating Scene For Overlay");
				s=[[Scene alloc] init];
				[w setOverlay: s];
			}
			[s addObject: tweaker atX: 0.0 Y:0.0 Z:0.0];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName: @"DataSetUpdate" object: self];
	}
	
	return self;
}

-cleanTweakers {
	[tweaker hide];
	[[NSNotificationCenter defaultCenter] postNotificationName: @"DataSetUpdate" object: self];
	return self;
}
#endif
-processHits: (GLint) hitCount buffer: (GLuint*) selectBuf andSize: (GLint) buffSize inWorld: (GLWorld*) world {
    return self;    // do nothing by default
}
@end
