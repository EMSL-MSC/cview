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
#import <sys/param.h>  //for max/min
#import <gl.h>
#import <glut.h>
#import <Foundation/Foundation.h>
#include <AntTweakBar.h>
#include "AntTweakBarManager.h"

#define MAX_STRING 255

static NSLock *ATB_lock;

@interface BarWrapper:NSObject {
	TwBar *barp;
}
+wrap:(TwBar *)bar;
-(TwBar *)bar;
@end
@implementation BarWrapper
+wrap:(TwBar *)bar {
	BarWrapper *bw = [[[BarWrapper alloc] init] autorelease];
	bw->barp = bar;
	return bw;
}
-(TwBar *)bar {
	return barp;
}
@end

@implementation AntTweakBarManager

+(void)initialize {
	ATB_lock=[NSLock new];
}
-init {
	[super init];
	if ([ATB_lock tryLock]) {
		bars = [[NSMutableSet setWithCapacity: 4] retain];
		TwInit(TW_OPENGL, NULL);
		TwWindowSize( glutGet(GLUT_WINDOW_WIDTH),glutGet(GLUT_WINDOW_HEIGHT));
		sizeChanged=NO;
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(setSizeChanged) name: @"GLScreenWindowSizeChanged" object: nil];
		TwGLUTModifiersFunc(glutGetModifiers);
		return self;
	}
	else
		return nil;
}

-initWithPList: (id)list {
	return nil; //Dont support loading from a plist..  This screws up locking for individual worlds..
}
 
-getPList {
	NSLog(@"getPList: %@",self);
	return nil;
/*
	return [NSDictionary dictionaryWithObjectsAndKeys: 
		[NSNumber numberWithBool: isVisible],@"isVisible",
		nil];
*/
}

-setSizeChanged {
	sizeChanged=YES;
	return self;
}

-(TwBar *)addBar: (NSString *)_name {
	TwBar *newBar = TwNewBar([_name UTF8String]);
	TwDefine([[NSString stringWithFormat:@"%@ iconpos=topleft alpha=192",_name] UTF8String]);
	[bars addObject: [BarWrapper wrap: newBar]];
	return newBar;
}

-removeBar: (TwBar *)bar {
	NSEnumerator *e;
	BarWrapper *bw;
	e = [bars objectEnumerator];
	while ((bw = [e nextObject])) {
		if ([bw bar] == bar) {
			TwDeleteBar([bw bar]);
			[bars removeObject: bw];
			break;
		}
	}
	return self;
}

-removeAllBars {
	NSEnumerator *e;
	BarWrapper *bw;
	e = [bars objectEnumerator];
	while ((bw = [e nextObject])) {
		TwDeleteBar([bw bar]);
	}
	[bars removeAllObjects];
	return self;
}

-glDraw {
	//NSLog(@"Tweaker Draw:%d",[bars count]);
	if (sizeChanged) {
		TwWindowSize( glutGet(GLUT_WINDOW_WIDTH),glutGet(GLUT_WINDOW_HEIGHT));
		sizeChanged = NO;
	}
	if ([bars count]>0)
		TwDraw();
	return self;
}

-(BOOL)keyPress: (unsigned char)key atX: (int)x andY: (int)y {
	if([bars count] && TwEventKeyboardGLUT(key, x, y) ) 
    	return YES;
	else
		return NO;
}

-(BOOL)specialKeyPress: (int)key atX: (int)x andY: (int)y {
	if ( [bars count] &&  TwEventSpecialGLUT(key, x, y) ) 
    	return YES;
	else
		return NO;
}

-(BOOL)mouseButton: (int)button withState: (int)state atX: (int)x andY: (int)y {
	if ( [bars count] && TwEventMouseButtonGLUT(button, state, x, y) ) {
    	return YES;
	}
	else {
    	return NO;
	}
}

-(BOOL)mouseActiveMoveAtX: (int)x andY: (int)y  {
	if ( [bars count] && TwEventMouseMotionGLUT(x, y) ) 
    	return YES;
	else
		return NO;
}

-(BOOL)mousePassiveMoveAtX: (int)x andY: (int)y  {
	if ( [bars count] && TwEventMouseMotionGLUT(x, y) ) 
    	return YES;
	else
		return NO;
}
- (id) retain{
	int i=4;
	i++;
	return [super retain];
};
-(void)dealloc {
	NSLog(@"%@ dealloc",[self class]);
	[self removeAllBars];
	TwTerminate();
	[bars autorelease];
	[ATB_lock unlock];
	[super dealloc];
	return;
}
@end
