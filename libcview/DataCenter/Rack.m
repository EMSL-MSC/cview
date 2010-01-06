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
-init {
    [super init];
    r = (float)rand() / (float)RAND_MAX;
    g = 1.0-r;
    b = 0.0;
    self->wireframe = YES;
    self->drawname = YES;
    self->rackArray = NULL;
    //self->gltName = nil;
    self->nodes = [[DrawableArray alloc] init];
    return self;
}
-(Node*)findNodeObjectByName:(NSString*) _name {
    //NSLog(@"name we're tyring to find is: %@", _name);
    if(self->nodes == nil)
        return nil;
    NSEnumerator *enumerator = [self->nodes getEnumerator];
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
            //[element poopy];
            return element;
        }
    }
 //   NSLog(@"returning nil");

            //[element poopy];
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
    NSEnumerator *enumerator = [self->nodes getEnumerator];
    if(enumerator == nil)
        NSLog(@"[DrawableArray draw]: enumerator was nil!");
    id element;
    while((element = [enumerator nextObject]) != nil) {
        [element startFading];
    }
    return self;
}
extern VertArray* createBox(float w, float h, float d);
-draw {
    if(rackArray == NULL) 
        rackArray = createBox([self getWidth],[self getHeight],[self getDepth]);

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
    [self->nodes draw]; // Draw the nodes
    glPopMatrix();
    if(drawname == YES) {   // Draw the rack name
        if(gltName == nil) {
            gltName = [[GLText alloc] initWithString: [self getName] andFont: @"LinLibertine_Re.ttf"];
            [gltName setScale: .4];
            [gltName setRotationOnX: 90 Y: 180 Z: 0];
        }
        [gltName setString: [self getName]];
        glTranslatef(11.2,.5001*STANDARD_RACK_HEIGHT,6);
        [gltName glDraw];
    }
    glPopMatrix();  
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError, error number: %x", err);
    return self;
}
-(NSMutableArray*)pickDrawX: (int)x andY: (int)y {
    NSMutableArray *ret;
    //TODO: initial picking

    if(YES)  // do the further picking 
        ret = [nodes pickDrawX: x andY: y];
    return ret;
}
-addNode: (Node*) node {
    int y = [self->nodes count];
    if(y > 9)
        ++y;    // Account for the standard gap in most every rack
    [node setLocation: [[[[Location alloc] init] setx: 0] sety: y]];
    [self->nodes addDrawablePickableObject: node];
    return self;
}
-setFace: (int) _face {
    self->face = _face;
    return self;
}
@end
