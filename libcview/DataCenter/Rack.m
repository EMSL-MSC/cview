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
        glColor3f(1,1,1);
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
