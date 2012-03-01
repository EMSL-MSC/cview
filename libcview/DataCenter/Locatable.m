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
#import "Locatable.h"
#import <gl.h>
#import <glut.h>
#import <Foundation/Foundation.h>

#import "Node.h"
@implementation Locatable
+(void)drawGLQuad: (_PointStruct) p1 andP2: (_PointStruct) p2
            andP3: (_PointStruct) p3 andP4: (_PointStruct) p4 {
    glBegin(GL_QUADS);
    glTexCoord2f(0.0,0.0);    glVertex3f(p1.x, p1.y, p1.z);
    glTexCoord2f(0.0,1.0);    glVertex3f(p2.x, p2.y, p2.z);
    glTexCoord2f(1.0,1.0);    glVertex3f(p3.x, p3.y, p3.z);
    glTexCoord2f(1.0,0.0);    glVertex3f(p4.x, p4.y, p4.z);
    glEnd();
}
-init {
    [super init];
    self->location = [[Vector alloc] initWithZeroes];
    self->rotation = [[Vector alloc] initWithZeroes];
    width = 0;
    height = 0;
    depth = 0;
    boundingBox = NULL;
    wireframeBox = NULL;
    return self;
}
-setLocation: (Vector*) _location {
    self->location = _location;
    return self;
}
-(Vector*) rotation; {
    return self->rotation;
}
-setRotation: (Vector*) _rotation {
    self->rotation = _rotation;
    return self;
}
-(Vector*) location; {
    return self->location;
}
-setWidth: (float) _width {
    self->width = _width;
    return self;
}
-(float) width; {
    return self->width;
}
-setHeight: (float) _height {
    self->height = _height;
    return self;
}
-(float) height; {
    return self->height;
}
-setDepth: (float) _depth {
    self->depth = _depth;
    return self;
}
-(float) depth; {
    return self->depth;
}
void initQuad(Vertex* v, _PointStruct *p1, _PointStruct *p2, _PointStruct *p3, _PointStruct *p4) {
    int i;
    _PointStruct *pX;
    for(i=0;i<4;++i) {
        if(i==0) {
            v[i].tu = 0.0f;
            v[i].tv = 0.0f;
            pX = p1; 
        }else if(i==1) {
            v[i].tu = 0.0f;
            v[i].tv = 1.0f;
            pX = p2;  
        }else if(i==2) {
            v[i].tu = 1.0f;
            v[i].tv = 1.0f;
            pX = p3; 
        }else if(i==3) {
            v[i].tu = 1.0f;
            v[i].tv = 0.0f;
            pX = p4;
        }
        v[i].x = pX->x;
        v[i].y = pX->y;
        v[i].z = pX->z;
    }
}
void initLine(Vertex* v, _PointStruct* p1, _PointStruct* p2) {
    v[0].x = p1->x;
    v[0].y = p1->y;
    v[0].z = p1->z;
    v[1].x = p2->x;
    v[1].y = p2->y;
    v[1].z = p2->z;
}
NSData* createWireframeBox(float w, float h, float d) {
    _PointStruct p1,p2,p3,p4,p5,p6,p7,p8;
    p1.x = -0.5*w; p1.y = -0.5*h; p1.z = -0.5*d;
    p2.x = -0.5*w; p2.y =  0.5*h; p2.z = -0.5*d;
    p3.x =  0.5*w; p3.y =  0.5*h; p3.z = -0.5*d;
    p4.x =  0.5*w; p4.y = -0.5*h; p4.z = -0.5*d;
    // Back four points same as first four except for depth...
    p5.x = p1.x; p5.y = p1.y; p5.z = 0.5*d;
    p6.x = p2.x; p6.y = p2.y; p6.z = 0.5*d;
    p7.x = p3.x; p7.y = p3.y; p7.z = 0.5*d;
    p8.x = p4.x; p8.y = p4.y; p8.z = 0.5*d;
    // 6 quads, 4 verts per quad, 24 verts total
    Vertex verts[24];
    
    initLine(&verts[0], &p1, &p2);
    initLine(&verts[2], &p2, &p3);
    initLine(&verts[4], &p3, &p4);
    initLine(&verts[6], &p4, &p1);
    initLine(&verts[8], &p5, &p6);
    initLine(&verts[10], &p6, &p7);
    initLine(&verts[12], &p7, &p8);
    initLine(&verts[14], &p8, &p5);
    initLine(&verts[16], &p1, &p5);
    initLine(&verts[18], &p2, &p6);
    initLine(&verts[20], &p3, &p7);
    initLine(&verts[22], &p4, &p8);
    // this method has "create" in the name, so we need to retain this object (it's the receiver's job to release it)
    return [[NSData dataWithBytes: verts length: sizeof(Vertex)*24] retain];
}
// Will create and initialize an array of verteces needed
// to draw a BOX in openGL...this will be very handy! (width, height, depth)
NSData* createBox(float w, float h, float d) {
    _PointStruct p1,p2,p3,p4,p5,p6,p7,p8;
    p1.x = -0.5*w; p1.y = -0.5*h; p1.z = -0.5*d;
    p2.x = -0.5*w; p2.y =  0.5*h; p2.z = -0.5*d;
    p3.x =  0.5*w; p3.y =  0.5*h; p3.z = -0.5*d;
    p4.x =  0.5*w; p4.y = -0.5*h; p4.z = -0.5*d;
    // Back four points same as first four except for depth...
    p5.x = p1.x; p5.y = p1.y; p5.z = 0.5*d;
    p6.x = p2.x; p6.y = p2.y; p6.z = 0.5*d;
    p7.x = p3.x; p7.y = p3.y; p7.z = 0.5*d;
    p8.x = p4.x; p8.y = p4.y; p8.z = 0.5*d;
    // 6 quads, 4 verts per quad, 24 verts total
    Vertex verts[24];
    initQuad(&verts[0],  &p1, &p2, &p3, &p4);  // Front
    initQuad(&verts[4],  &p1, &p5, &p6, &p2);  // Left side
    initQuad(&verts[8],  &p2, &p6, &p7, &p3);  // Top side
    initQuad(&verts[12], &p4, &p3, &p7, &p8);  // Right side
    initQuad(&verts[16], &p1, &p4, &p8, &p5);  // Bottom side
    initQuad(&verts[20], &p5, &p8, &p7, &p6);  // Back side
    return [[NSData dataWithBytes: verts length: sizeof(Vertex)*24] retain];
}
-setupForDraw {
    glPushMatrix(); // Save matrix state
    // Do translations and rotations
    glTranslatef([location x], [location y], [location z]);
    glRotatef([rotation x],1,0,0);
    glRotatef([rotation y],0,1,0);
    glRotatef([rotation z],0,0,1);
    return self;
}
-cleanUpAfterDraw {
    glPopMatrix();
    return self;
}
-drawBox {
    if(boundingBox == NULL) 
        boundingBox = createBox([self width],[self height],[self depth]);
    //NSLog(@"box: width: %f height: %f depth: %f", width, height, depth);
   // NSLog(@"box: loc: x: %f y: %f z: %f", [location x], [location y], [location z]);
    //NSLog(@"box: loc: x: %f", [location x]);
//glColor3f(.1,.1,.3);

    glInterleavedArrays(GL_T2F_V3F, 0, [boundingBox bytes]);
    glDrawArrays(GL_QUADS, 0, [boundingBox length] / sizeof(Vertex));
    return self;
}
-glDraw {
    [self drawBox];
    return self;
}
-drawWireframe {
    if(wireframeBox == NULL) 
        wireframeBox = createWireframeBox([self width],[self height],[self depth]);
    // TODO: change this to draw the wireframe correctly
    glInterleavedArrays(GL_T2F_V3F, 0, [wireframeBox bytes]);
    glDrawArrays(GL_LINES, 0, [wireframeBox length] / sizeof(Vertex));
    return self;
}
-glPickDraw {
    if(![self isKindOfClass:[Node class]])
        NSLog(@"found a class: %@", self);
    glPushName([super myid]);    // push my id onto the gl stack
    {
        [self drawBox];
    }
    glPopName();
    return self;
}
@end
