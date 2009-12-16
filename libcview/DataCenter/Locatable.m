#import "Locatable.h"
#import <gl.h>
#import <glut.h>

@implementation Locatable
+(void)drawGLQuad: (struct Point) p1 andP2: (struct Point) p2
      andP3: (struct Point) p3 andP4: (struct Point) p4 {
    glBegin(GL_QUADS);
    glColor3f(1,0,0);
    glTexCoord2f(0.0,0.0);
    glVertex3f(p1.x, p1.y, p1.z);
    glColor3f(0,1,0);
    glTexCoord2f(0.0,1.0);
    glVertex3f(p2.x, p2.y, p2.z);
    glColor3f(0,0,1);
    glTexCoord2f(1.0,1.0);
    glVertex3f(p3.x, p3.y, p3.z);
    glColor3f(.5,.5,.2);
    glTexCoord2f(1.0,0.0);
    glVertex3f(p4.x, p4.y, p4.z);
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
-setWidth: (int) _width {
    self->width = _width;
    return self;
}
-(int) getWidth; {
    return self->width;
}
-setHeight: (int) _height {
    self->height = _height;
    return self;
}
-(int) getHeight; {
    return self->height;
}
-setDepth: (int) _depth {
    self->depth = _depth;
    return self;
}
-(int) getDepth; {
    return self->depth;
}

@end
