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
    NSEnumerator *enumerator = [self->nodes getEnumerator];
    if(enumerator == nil)
        NSLog(@"[DrawableArray draw]: enumerator was nil!");
    id element;
    while((element = [enumerator nextObject]) != nil) {
        [element startFading];
    }
    return self;
}
-draw {
    [super setupForDraw];
        //[super draw]; // Draw bounding box around rack
        glColor3f(1,1,1);
        [super drawWireframe]; // Draw wireframe around the rack
        [self->nodes draw]; // Draw the nodes

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
    [super cleanUpAfterDraw]; 
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError, error number: %x", err);
    return self;
}
-glPickDraw: (IdArray*)ids {
    if([ids isNumberInArray: [self myid]] == YES)
        // Found myid in the ids array, do furthing picking...
        [nodes glPickDraw:ids];
    else
        [super glPickDraw:ids];
    return self;
}
-(NSMutableArray*) getPickedObjects: (IdArray*)pickDrawIds hits: (IdArray*)glHits {
    if([pickDrawIds isNumberInArray: [self myid]] == NO)
        return nil;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject: self];  // Add this rack to the array
    [arr addObject: [nodes getPickedObjects: pickDrawIds hits: glHits]];
    return arr;
}
-addNode: (Node*) node {
    [self->nodes addDrawablePickableObject: node];
    return self;
}
-(int)nodeCount {
    return [nodes count];
}
@end
