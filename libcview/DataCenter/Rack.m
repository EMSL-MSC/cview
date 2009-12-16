#import "Rack.h"
#import "Point.h"
#import <gl.h>
#import <glut.h>
#include <stdio.h>
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
    self->nodes = [[DrawableArray alloc] init];
    return self;
}
-draw {
    // TODO: Add drawing algorithm from the rack itself (the container,
    //       not the nodes themself
    //printf("%s\n", [[self getName] UTF8String]);
    //NSLog(@"rack name: %@", [self getName]);
    int h = [self getHeight];
    int w = [self getWidth];
    int d = [self getDepth];
    struct Point p1,p2,p3,p4,p5,p6,p7,p8;
    p1.x = -0.5*w; p1.y = -0.5*h; p1.z = -0.5*d;
    p2.x = -0.5*w; p2.y = 0.5*h; p2.z = -0.5*d;
    p3.x = 0.5*w; p3.y = 0.5*h; p3.z = -0.5*d;
    p4.x = 0.5*w; p4.y = -0.5*h; p4.z = -0.5*d;
    // Back four points same as first four except for depth...
    p5.x = p1.x; p5.y = p1.y; p5.z = 0.5*d;
    p6.x = p2.x; p6.y = p2.y; p6.z = 0.5*d;
    p7.x = p3.x; p7.y = p3.y; p7.z = 0.5*d;
    p8.x = p4.x; p8.y = p4.y; p8.z = 0.5*d;
    glPushMatrix();
    glTranslatef(w*[[self getLocation] getx], 0, 0);
    glEnable(GL_TEXTURE_2D);
    //glDisable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texture);
    //NSLog(@"texture == %d", texture);
	//glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  GL_NEAREST);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_NEAREST);
    //glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    [Locatable drawGLQuad: p1 andP2: p2 andP3: p3 andP4: p4];  // Front
    //glDisable(GL_TEXTURE_2D);
    [Locatable drawGLQuad: p1 andP2: p5 andP3: p6 andP4: p2];  // Left side
    [Locatable drawGLQuad: p2 andP2: p6 andP3: p7 andP4: p3];  // Top side
    [Locatable drawGLQuad: p4 andP2: p3 andP3: p7 andP4: p8];  // Right side
    [Locatable drawGLQuad: p1 andP2: p4 andP3: p8 andP4: p5];  // Bottom side
    [Locatable drawGLQuad: p5 andP2: p8 andP3: p7 andP4: p6];  // Back side
    // Note::: Node locations are ***RELATIVE*** to the current rack location
    // that is why we don't call glPopMatrix() until after we've drawn the nodes!
    [self->nodes draw];
    glPopMatrix();  

    GLenum err = glGetError();
    if(err != GL_NO_ERROR) {
        NSLog(@"There was a glError, error number: %d", err);
        printf("error in hex: %x\n", err);
    }

    return self;
}
-addNode: (Node*) node {
    [self->nodes addDrawableObject: node];
    return self;
}
@end
