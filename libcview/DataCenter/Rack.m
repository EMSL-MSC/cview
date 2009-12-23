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
static VertArray *rackArray;

+(void) setRackArray: (VertArray*) _rackArray {
    rackArray = _rackArray;
}
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
    self->drawname = YES;
    self->gltName = nil;
    vertsSetUp = NO;
    self->nodes = [[DrawableArray alloc] init];
    return self;
}
-initWithName: (NSString*)_name {
    [self init];
    [self setName: _name];
        return self;
}
extern VertArray* createBox(float w, float h, float d);
-draw {
    if(rackArray == NULL) {
        rackArray = createBox([self getWidth],[self getHeight],[self getDepth]);
        //vertsSetUp = YES;
    }
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
    glInterleavedArrays(GL_T2F_V3F, 0, rackArray->verts);
    if(wireframe == YES)
        glDrawArrays(GL_LINES, 0, rackArray->vertCount);
    else
        glDrawArrays(GL_QUADS, 0, rackArray->vertCount);

    glColor3f(1,1,1);
    glPushMatrix();
    glTranslatef(0,[self getHeight]*-0.5+STANDARD_NODE_HEIGHT*-0.5,0);//[self getDepth]*-0.5);
    if((int)[self getDepth] != (int)STANDARD_RACK_DEPTH)
        NSLog(@"Z = %f",[self getDepth]);
    [self->nodes draw];
    glPopMatrix();
    // Draw the rack name
    //drawString3D(0,[self getHeight],0,GLUT_BITMAP_HELVETICA_12,[self getName], 0);
    if(drawname == YES) {
        glTranslatef(11.2,.5001*STANDARD_RACK_HEIGHT,6);
        if(self->gltName == nil) {
            self->gltName = [[GLText alloc] initWithString: [self getName] andFont: @"LinLibertine_Re.ttf"];
            [self->gltName setScale: .4];
            [self->gltName setRotationOnX: 90 Y: 180 Z: 0];
        }
        [gltName glDraw];
    }
    glPopMatrix();  
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError, error number: %x", err);
    return self;
}
-addNode: (Node*) node {
    int y = [self->nodes count];
    if(y > 9)
        ++y;    // Account for the standard gap in most every rack
    [node setLocation: [[[[Location alloc] init] setx: 0] sety: y]];
    [self->nodes addDrawableObject: node];
    return self;
}
-setFace: (int) _face {
    self->face = _face;
    return self;
}
@end
