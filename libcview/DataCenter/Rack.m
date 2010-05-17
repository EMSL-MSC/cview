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
#import "Rack.h"
#import "Point.h"
#import <gl.h>
#import <glut.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#import <Foundation/Foundation.h>
// #import "AisleOffsets.h"
void drawString3D(float x,float y,float z,void *font,NSString *string,float offset);
@implementation Rack
static unsigned int texture;
static GLText *gltName;

+setGLTName:(GLText*) _gltName {
    gltName = _gltName;
    return self;
}
+(unsigned int)texture {
    return texture;
}
+setTexture:(unsigned int)_texture {
    texture = _texture;
    return self;
}
-cleanUp{
    NSEnumerator *enumerator = [nodes objectEnumerator];
    if(enumerator != nil) {
        id element;
        while((element = [enumerator nextObject]) != nil)
            [element cleanUp];
    }
    [self autorelease];
    return self;
}
-(NSString*)color {
    return color;
}
-setColor:(NSString*)_color {
    self->color = _color;
    return self;
}
-init {
    [super init];
    r = (float)rand() / (float)RAND_MAX;
    g = 1.0-r;
    b = 0.0;
    self->wireframe = YES;
    self->drawname = YES;
    //self->gltName = nil;
    self->nodes = [[NSMutableArray alloc] init];
    return self;
}
-(Node*)findNodeObjectByName:(NSString*) _name {
    //NSLog(@"name we're tyring to find is: %@", _name);
    if(self->nodes == nil)
        return nil;
    NSEnumerator *enumerator = [self->nodes objectEnumerator];
    if(enumerator == nil)
        return nil;
    id element;
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"got here!");
  //      NSLog(@"node name: %@", [element getName]);
        if([element getName] != nil &&
           [[element getName] caseInsensitiveCompare: _name] == NSOrderedSame) {
     //       NSLog(@"found it!!!");
            //NSLog(@"node name: %@", [element getName]);
            return element;
        }
    }
 //   NSLog(@"returning nil");
    return nil;
}
-initWithName: (NSString*)_name {
    [self init];
    [self setName: _name];
        return self;
}
-startFading {
    if(self->nodes == nil)
        return self;
    [self->nodes makeObjectsPerformSelector: @selector(startFading)];
    return self;
}
-draw {
//    NSLog(@"rack=%@ width=%f height=%f depth=%f",[self name],[self width],[self height],[self depth]);
    [super setupForDraw];
        //[super draw]; // Draw bounding box around rack
        glColor3f(.184,.431,.502);
        [super drawWireframe]; // Draw wireframe around the rack
        [self->nodes makeObjectsPerformSelector:@selector(draw)]; // draw the nodes
//        [[[nodes objectEnumerator] nextObject] draw];

        if(drawname == YES) {   // Draw the rack name
            if(gltName == nil) {
                gltName = [[GLText alloc] initWithString: [self name] andFont: @"LinLibertine_Re.ttf"];
      //          [gltName setRotationOnX: 90 Y: 180 Z: 0];
            }
            [gltName setString: [self name]];
            // Scale the font so that it fits within the rack width
            float heightRatio = [self height] / [gltName height];
            float widthRatio = [self width] / [gltName width];
            [gltName setScale: heightRatio < widthRatio ? .8 * heightRatio: .8 * widthRatio];

            glTranslatef(11.2,.5001*[self height],.75*[self depth]);
            glRotatef(-90,1,0,0);
            glRotatef(180,0,1,0);
            [gltName glDraw];
        }
    [super cleanUpAfterDraw]; 
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError, error number: %x", err);
    return self;
}
-glPickDraw {
    [super setupForDraw];
        [nodes makeObjectsPerformSelector:@selector(glPickDraw)];
    [super cleanUpAfterDraw];
    return self;
}
-addNode: (Node*) node {
    [self->nodes addObject: node];
    return self;
}
-(int)nodeCount {
    return [nodes count];
}
@end
