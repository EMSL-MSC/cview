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
#import <gl.h>
#import <glut.h>
#import <Foundation/Foundation.h>
#import "DataCenterCViewScreenDelegate.h"
#import "WebDataSet.h"
#import "GLWorld.h"
#import "GLGrid.h"
#import "Scene.h"
#import "GLDataCenter.h"
#import "IdDatabase.h"
/**
    Overrides the super implementation of keyPress in order to check
    for our own special key-presses.  After we've checked, we can pass
    this message to the super class and let it handle the key press however
    it wants.

    Right now, the only thing that this class overrides is the '7' key press.
 */
@implementation DataCenterCViewScreenDelegate 
-init {
	self->tip = nil;
	self->time = nil;
	self->hovering = NO;
	self->sel = nil;
	self->sleeperCount = 0;
	//self->sleeperLock = [NSLock newLockAt: self];
	self->sleeperLock = [[NSLock alloc] init];
    lastSelection = nil;
    leftClicked = NO;
    passiveMove = NO;
    return self;
}
-initWithScreen: (GLScreen *)screen {
	[super initWithScreen: screen];
	[self init];
	return self;
}
-(BOOL)keyPress: (unsigned char)key atX: (int)x andY: (int)y inGLWorld: (GLWorld *)world {
    BOOL handled = YES;
    NSArray *objects;
    NSEnumerator *enumerator;
    switch (key) {
        case '7':
            objects = [[world scene] getAllObjects];
            if(objects == nil) {
                NSLog(@"objects was nil!!!");
                break;
            }
            enumerator = [objects objectEnumerator];
            if(enumerator == nil) {
                NSLog(@"enumerator was nil!!!");
                break;
            }
            // loop through scene objects while looking for a datacenter
            id element;
            while((element = [enumerator nextObject]) != nil) {
                if([element isKindOfClass: [GLDataCenter class]]) {
                    [(GLDataCenter*)element seeNextJobId];  // yes, send it our message
                }
            }
            break;
        default:
            handled=NO;
            break;
    }
    if(!handled)    // call the super since we didn't handle it, let the super do that
        return [super keyPress: key atX: x andY: y inGLWorld: world];
    return handled;
}
-(BOOL)mousePassiveMoveAtX: (int)x andY: (int)y inGLWorld: (GLWorld *)world {
    [[[world setHoverX: x] setHoverY: y] setDoPickDraw: YES];
    passiveMove = YES;
    leftClicked = NO;
//    return NO;  // return value doesn't matter right now! ask evan about this
    return [super mousePassiveMoveAtX: x andY: y inGLWorld: world];
}
-(BOOL)mouseButton: (int)button withState: (int)state atX: (int)x andY: (int)y inGLWorld: (GLWorld *)world {
    if (state == GLUT_DOWN) {
        switch (button) {
            case GLUT_LEFT_BUTTON:
                {
                    // set the world to do a pickdraw next time around the merry-go-round.
                    [[[world setHoverX: x] setHoverY: y] setDoPickDraw: YES];
                    passiveMove = NO;
                    leftClicked = YES;
                    break;
                }
                break;
            case GLUT_MIDDLE_BUTTON:
                break;
            case GLUT_RIGHT_BUTTON:
                break;
            case 3: // WHEEL_UP
                break;
            case 4: // WHEEL_DOWN
                break;
            default:
                break;
        }
    }
    else {
       // mouse released in this block
    }
    return [super mouseButton: button withState: state atX: x andY: y inGLWorld: world];
}
-selectNode: (Node*) n {
    if(lastSelection != nil)
        [lastSelection setSelected: NO];
    if(n != nil)
        [n setSelected: YES];
    lastSelection = n;
    return self;
}
-printNode: (Node*)n withId: (float) _id {
    NSLog(@"Node: name: %@ jobid: %f", [n getName], _id);
    return self;
}
-(void)sleepAndUpdate:(id) sleeptime {
//	NSLog(@"sleeping....");
	[self->sleeperLock lock];
	++sleeperCount;
	[self->sleeperLock unlock];
	[NSThread sleepForTimeInterval: [sleeptime floatValue]];
	[self->sleeperLock lock];
//	NSLog(@"woken up! sleeperCount = %d",sleeperCount);
	// Posting a "DataSetUpdate" causes a full redraw to occur (we didn't actually update the dataset, but
	// the desired effect will occur)
	if(sleeperCount == 1 && self->sel != nil) {
		[[NSNotificationCenter defaultCenter] postNotificationName: @"DataSetUpdate" object: self];
		[self->tip show];
	}
	--sleeperCount;
	[self->sleeperLock unlock];
}
-processHits: (GLint) hitCount buffer: (GLuint*) selectBuf andSize: (GLint) buffSize inWorld: (GLWorld*) world {
    //////////////////////////////////////////////////
    /// process the hits/////
    // m is a maximum value, starting at the max hex value we can get
    unsigned int i, m = 0xffffffff;
    unsigned int theId = 0;
    GLuint names, *ptr, *rowptr;
    ptr = (GLuint*)selectBuf;

/* temporary code */ /*
    NSEnumerator *enume = [[[world scene] getAllObjects] objectEnumerator];
    GLDataCenter *gcdT = nil;
    id elemen;
	// loop through the scene objects and find the DataCenter
	while((elemen = [enume nextObject]) != nil) {
		if([elemen isKindOfClass: [GLDataCenter class]]) {
			gcdT = elemen;
			break;
		}
	}*/
/* end temporary code */

    for(i=0;i<hitCount;++i) {
        names = *ptr;   // the number of names in current 'cell'
        rowptr = ptr;   // points to the current 'cell' or row
        ptr += 3;       // skip past 3 elements in this row (names, closest distance, furthest distance)
        ptr += names;   // skip past the number of names there are in this row
        if(rowptr[1] < m)   // look for a new minimum
        {   
            m = rowptr[1];
            theId = rowptr[3];  // get the id because it's closest to the camera
        }   
    }
    id thing = [IdDatabase objectForId: theId];
    Node *n;
	// Found 
    if(thing != nil && [thing isKindOfClass: [Node class]]) {
		self->tip = [world tooltip];
        n = thing;
		if(self->tip != nil) {
			if(self->sel != n) {
				// Set up the tooltip for viewing
				[tip setTitle: [n getName]];
				float jobId = 0;
				float *row = [[[n datacenter] jobIds] dataRowByString: [[n getName] uppercaseString]];
				if(row != NULL)
					jobId = row[0];
				[tip setText: [NSString stringWithFormat: @"JobId: %.0f\nAmbient Temp: %.0f%@C\nFront Panel Temp: ", jobId, [NSString stringWithCString: "\313\232"], [n getTemperature]]];
				int x = [world hoverX];
				int y = [world hoverY];
				if(x > glutGet(GLUT_WINDOW_WIDTH) / 2)
					x -= .5*[self->tip width];
				else
					x += .5*[self->tip width];
				if(y > glutGet(GLUT_WINDOW_HEIGHT) / 2)
					y -= .5*[self->tip height] + 80;
				else
					y += .5*[self->tip height] + 80;
				[[tip setX: x] setY: y];
			}
			// Schedule the tip for later viewing
			[NSThread detachNewThreadSelector: @selector(sleepAndUpdate:) toTarget: self withObject: [NSNumber numberWithFloat: .7]];
			self->sel = n;
		}
    } else { // not hovering over anything, no node is selected
		[self selectNode: nil];
		self->sel = nil;
		[tip hide];
        return self;
	}
    ///////////////////////////////////////////////////////////////////
    //////   Now we parsed the data and found out what node is selected,
    //////// next decide what to do with that node
    if(leftClicked == YES) {
        leftClicked = NO;
        GLDataCenter *gcd = nil;
        NSArray *arr = [[world scene] getAllObjects];
        NSEnumerator *enumerator = [arr objectEnumerator];
        id element;
        // loop through the scene objects and find the DataCenter
        while((element = [enumerator nextObject]) != nil) {
            if([element isKindOfClass: [GLDataCenter class]]) {
                gcd = element;
                break;
            }
        }
        if(gcd == nil)
            return self;

        // fade all the other nodes not having a like jobid
        if(n != nil) {
            float jobid = [gcd getJobIdFromNode: n];
            [self printNode: n withId: jobid];

            if(jobid != 0) 
                [gcd fadeEverythingExceptJobID: jobid];
        }
    }else if(passiveMove == YES){
        passiveMove = NO;
        [self selectNode: n];
    }
    return self;
}
@end
