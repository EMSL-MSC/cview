#import "Locatable.h"
#import <gl.h>
#import <glut.h>

@implementation Locatable
+(void)drawGLQuad: (Point) p1 andP2: (Point) p2
            andP3: (Point) p3 andP4: (Point) p4 {
    glBegin(GL_QUADS);
    glTexCoord2f(0.0,0.0);    glVertex3f(p1.x, p1.y, p1.z);
    glTexCoord2f(0.0,1.0);    glVertex3f(p2.x, p2.y, p2.z);
    glTexCoord2f(1.0,1.0);    glVertex3f(p3.x, p3.y, p3.z);
    glTexCoord2f(1.0,0.0);    glVertex3f(p4.x, p4.y, p4.z);
    glEnd();
}
-init {
    self->location = nil;
    self->name = nil;
    return self;
}
-setName: (NSString *) _name{
    self->name = _name;
    return self;
}
-(NSString*) getName{
    return self->name;
}
-setLocation: (Location*) _location {
    self->location = _location;
    return self;
}
-(Location*) getLocation; {
    return self->location;
}
-setWidth: (float) _width {
    self->width = _width;
    return self;
}
-(float) getWidth; {
    return self->width;
}
-setHeight: (float) _height {
    self->height = _height;
    return self;
}
-(float) getHeight; {
    return self->height;
}
-setDepth: (float) _depth {
    self->depth = _depth;
    return self;
}
-(float) getDepth; {
    return self->depth;
}

@end
