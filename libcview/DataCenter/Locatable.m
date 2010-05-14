#import "Locatable.h"
#import <gl.h>
#import <glut.h>
#import <Foundation/Foundation.h>

#import "Node.h"
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
    [super init];
    self->location = [[Vector alloc] initWithZeroes];
    self->rotation = [[Vector alloc] initWithZeroes];
    self->name = nil;
    width = 0;
    height = 0;
    depth = 0;
    boundingBox = NULL;
    wireframeBox = NULL;
    return self;
}
-setName: (NSString *) _name{
    self->name = _name;
    return self;
}
-(NSString*) name{
    return self->name;
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
void initQuad(Vertex* v, Point *p1, Point *p2, Point *p3, Point *p4) {
    int i;
    Point *pX;
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
void initLine(Vertex* v, Point* p1, Point* p2) {
    v[0].x = p1->x;
    v[0].y = p1->y;
    v[0].z = p1->z;
    v[1].x = p2->x;
    v[1].y = p2->y;
    v[1].z = p2->z;
}
NSData* createWireframeBox(float w, float h, float d) {
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
-draw {
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
