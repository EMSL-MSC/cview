#import "Rack.h"
#import "Point.h"
#import <gl.h>
#import <glut.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#import <Foundation/Foundation.h>
#import "IsleOffsets.h"
void drawString3D(float x,float y,float z,void *font,NSString *string,float offset);
@implementation Rack
static unsigned int texture;
+(unsigned int)texture {
    return texture;
}
+setTexture:(unsigned int)_texture {
    texture = _texture;
    return self;
}
-init {
    [super init];
    r = (float)rand() / (float)RAND_MAX;
    g = 1.0-r;
    b = 0.0;
    self->wireframe = YES;
    self->gltName = nil;
    vertsSetUp = NO;
    self->nodes = [[DrawableArray alloc] init];
    return self;
}
-initWithName: (NSString*)_name {
    [self init];
    [self setName: _name];
    self->gltName = [[GLText alloc] initWithString: [self getName] andFont: @"LinLibertine_Re.ttf"];
    [self->gltName setScale: .4];
    [self->gltName setRotationOnX: 90 Y: 180 Z: 0];
    return self;
}
void setQuadArrayVertex(Vertex* v, Point p1, Point p2, Point p3, Point p4) {
    int i;
    Point *pX;
    for(i=0;i<4;++i) {
        if(i==0) {
            v[i].tu = 0.0f;
            v[i].tv = 0.0f;
            pX = &p1; 
        }else if(i==1) {
            v[i].tu = 0.0f;
            v[i].tv = 1.0f;
            pX = &p2;  
        }else if(i==2) {
            v[i].tu = 1.0f;
            v[i].tv = 1.0f;
            pX = &p3; 
        }else if(i==3) {
            v[i].tu = 1.0f;
            v[i].tv = 0.0f;
            pX = &p4;
        }
        v[i].x = pX->x;
        v[i].y = pX->y;
        v[i].z = pX->z;
    }
}
-initRackVerts {
    int w = [self getWidth];
    int h = [self getHeight];
    int d = [self getDepth];
    Point p1,p2,p3,p4,p5,p6,p7,p8;
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
    rack = malloc(sizeof(VertArray));
    self->rack->vertCount = 24;
    self->rack->verts = malloc(sizeof(Vertex)*self->rack->vertCount);  // Don't forget to free this...

    setQuadArrayVertex(&rack->verts[0],  p1, p2, p3, p4);  // Front
    setQuadArrayVertex(&rack->verts[4],  p1, p5, p6, p2);  // Left side
    setQuadArrayVertex(&rack->verts[8],  p2, p6, p7, p3);  // Top side
    setQuadArrayVertex(&rack->verts[12], p4, p3, p7, p8);  // Right side
    setQuadArrayVertex(&rack->verts[16], p1, p4, p8, p5);  // Bottom side
    setQuadArrayVertex(&rack->verts[20], p5, p8, p7, p6);  // Back side
    vertsSetUp = YES;
/*
    setQuadArrayVertex(&rack->verts[0],  p1, p5, p6, p2);  // Left side
    setQuadArrayVertex(&rack->verts[4],  p2, p6, p7, p3);  // Top side
    setQuadArrayVertex(&rack->verts[8], p4, p3, p7, p8);  // Right side
    setQuadArrayVertex(&rack->verts[12], p1, p4, p8, p5);  // Bottom side
    setQuadArrayVertex(&rack->verts[16], p5, p8, p7, p6);  // Back side
    vertsSetUp = YES;
    */

    return self;
}
-draw {
    if(!vertsSetUp)
        [self initRackVerts];

    glPushMatrix(); // Save matrix state
    // Draw this rack based on it's location within its isle
    glTranslatef([self getWidth]*[[self getLocation] getx], 0, 0);
    glEnable(GL_CULL_FACE);
    //glEnable(GL_TEXTURE_2D);
    glDisable(GL_TEXTURE_2D);
    //glColor3f(r,g,b);
    glColor3f(.1,.1,.3);
    glRotatef(self->face,0,1,0);
    // Draw the rack itself, consisting of 6 sides
    glInterleavedArrays(GL_T2F_V3F, 0, self->rack->verts);
    if(wireframe == YES)
        glDrawArrays(GL_LINES, 0, self->rack->vertCount);
    else
        glDrawArrays(GL_QUADS, 0, self->rack->vertCount);

    glColor3f(1,1,1);
    glPushMatrix();
    glTranslatef(0,[self getHeight]*-0.5+STANDARD_NODE_HEIGHT*-0.5,[self getDepth]*-0.5);
    if((int)[self getDepth] != (int)STANDARD_RACK_DEPTH)
        NSLog(@"Z = %f",[self getDepth]);
    [self->nodes draw];
    glPopMatrix();
    glTranslatef(11.2,.5001*STANDARD_RACK_HEIGHT,6);
    // Draw the rack name
    //drawString3D(0,[self getHeight],0,GLUT_BITMAP_HELVETICA_12,[self getName], 0);
    [gltName glDraw];
    glPopMatrix();  
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError, error number: %x", err);
    return self;
}
-addNode: (Node*) node {
    // Kinda cryptic line, don't you think?
    [node setLocation: [[[[Location alloc] init] setx: 0] sety: [self->nodes count]]];
    [self->nodes addDrawableObject: node];
    return self;
}
-setFace: (int) _face {
    self->face = _face;
    return self;
}
@end
