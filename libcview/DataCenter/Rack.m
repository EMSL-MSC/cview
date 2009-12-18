#import "Rack.h"
#import "Point.h"
#import <gl.h>
#import <glut.h>
#include <stdio.h>
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
    vertsSetUp = FALSE;
    self->nodes = [[DrawableArray alloc] init];
    return self;
}
typedef struct
{
    float tu, tv;
    float x, y, z;
} Vertex;
void setQuadArrayVertex(Vertex* v, Point p1, Point p2, Point p3, Point p4) {
    int i;
    Point *pX;
    for(i=0,i<4;++i) {
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
void initRackVerts() {
    struct Point p1,p2,p3,p4,p5,p6,p7,p8;
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
    self->vertCount = 24;
    rackVerts = malloc(sizeof(Vertex)*24);  // Don't forget to free this...
    setQuadArrayVertex(&rackVerts[0],  p1, p2, p3, p4);  // Front
    setQuadArrayVertex(&rackVerts[4],  p1, p5, p6, p2);  // Left side
    setQuadArrayVertex(&rackVerts[8],  p2, p6, p7, p3);  // Top side
    setQuadArrayVertex(&rackVerts[12], p4, p3, p7, p8);  // Right side
    setQuadArrayVertex(&rackVerts[16], p1, p4, p8, p5);  // Bottom side
    setQuadArrayVertex(&rackVerts[20], p5, p8, p7, p6);  // Back side
}
-draw {
    //printf("%s\n", [[self getName] UTF8String]);
    //NSLog(@"rack name: %@", [self getName]);
    if(!vertsSetUp)
        initRackVerts();
    int h = [self getHeight];
    int w = [self getWidth];
    int d = [self getDepth];
    struct Point p1,p2,p3,p4,p5,p6,p7,p8;
    
    p1.x = -0.5*w; p1.y = -0.5*h; p1.z = -0.5*d;
    p2.x = -0.5*w; p2.y = 0.5*h; p2.z = -0.5*d;
    p3.x = 0.5*w; p3.y = 0.5*h; p3.z = -0.5*d;            v[i].tu = 0.0f;
            v[i].tv = 0.0f;
        else if(i==1) {

    p4.x = 0.5*w; p4.y = -0.5*h; p4.z = -0.5*d;
    // Back four points same as first four except for depth...
    p5.x = p1.x; p5.y = p1.y; p5.z = 0.5*d;
    p6.x = p2.x; p6.y = p2.y; p6.z = 0.5*d;
    p7.x = p3.x; p7.y = p3.y; p7.z = 0.5*d;
    p8.x = p4.x; p8.y = p4.y; p8.z = 0.5*d;
/*
    Vertex rackVertices[] =
    {
        { 0.0f,0.0f, p1.x,p1,p1 },
        { 1.0f,0.0f, p2.x,p2,p2 },
        { 1.0f,1.0f, p3.x,p3,p3 },
        { 0.0f,1.0f, p4.x,p4,p4 },
    };
*/
    // We are going to draw 4 quads, 4 verts per quad, 16 total verts
    

    glPushMatrix();
    glTranslatef(w*[[self getLocation] getx], 0, 0);
//    glEnable(GL_TEXTURE_2D);
    //glDisable(GL_TEXTURE_2D);
    //glBindTexture(GL_TEXTURE_2D, texture);
    //NSLog(@"texture == %d", texture);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_NEAREST);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glEnable(GL_CULL_FACE);
    glEnable(GL_TEXTURE_2D);
    glColor3f(1.0,1.0,1.0);
    [Locatable drawGLQuad: p1 andP2: p2 andP3: p3 andP4: p4];  // Front
    glDisable(GL_TEXTURE_2D);
    glColor3f(1,1,1);
    [Locatable drawGLQuad: p1 andP2: p5 andP3: p6 andP4: p2];  // Left side
    glColor3f(1,0,0);
    [Locatable drawGLQuad: p2 andP2: p6 andP3: p7 andP4: p3];  // Top side
    glColor3f(1,1,1);
    [Locatable drawGLQuad: p4 andP2: p3 andP3: p7 andP4: p8];  // Right side
    glColor3f(0,0,1.0);
    [Locatable drawGLQuad: p1 andP2: p4 andP3: p8 andP4: p5];  // Bottom side
    glColor3f(0,0,1);
    [Locatable drawGLQuad: p5 andP2: p8 andP3: p7 andP4: p6];  // Back side
    // Note::: Node locations are ***RELATIVE*** to the current rack location
    // that is why we don't call glPopMatrix() until after we've drawn the nodes!
    glColor3f(1,1,1);
    drawString3D(0,h,0,GLUT_BITMAP_HELVETICA_12,@"Rack #", 0);
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
