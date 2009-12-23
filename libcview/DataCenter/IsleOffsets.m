#import "IsleOffsets.h"
#import <Foundation/Foundation.h>
void initQuad(Vertex* v, Point p1, Point p2, Point p3, Point p4) {
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
// Will malloc and initialize an array of verteces needed
// to draw a BOX in openGL...this will be very handy! (width, height, depth)
VertArray* createBox(float w, float h, float d) {
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
    VertArray *va = malloc(sizeof(VertArray));
    va->vertCount = 24;
    va->verts = malloc(sizeof(Vertex)*va->vertCount);  // Don't forget to free this...
    initQuad(&va->verts[0],  p1, p2, p3, p4);  // Front
    initQuad(&va->verts[4],  p1, p5, p6, p2);  // Left side
    initQuad(&va->verts[8],  p2, p6, p7, p3);  // Top side
    initQuad(&va->verts[12], p4, p3, p7, p8);  // Right side
    initQuad(&va->verts[16], p1, p4, p8, p5);  // Bottom side
    initQuad(&va->verts[20], p5, p8, p7, p6);  // Back side
    return va;
}
@implementation IsleOffsets
// Created this little function using the data center map....
// I establised a baseline, and then counted how many tiles each
// isle was away from the baseline.  Pretty simple, only problem is
// that it's hardcoded in here.....(maybe we don't care)
+(float)getIsleOffset: (int) isle {
    if(isle < 0) {
        NSLog(@"Someone passed a negetive isle number!!! VERY BAD.");
        return 0;
    }else if(isle == 1) {
        return 2.5;
    }else if(isle == 2) {
        return -0.2;
    }else if(isle == 3) {
        return 1;
    }else if(isle == 4) {
        return 0;
    }else if(isle == 5) {
        return 1;
    }else if(isle == 6) {
        return 3.8;
    }else if(isle <= 13) {
        return 11;
    }else if(isle <= 16) {
        return 10;
    }else{
        NSLog(@"Someone passed an isle greater than 16!!! Uh-oh.");
        return 0;
    }
}
+(VertArray*)getDataCenterFloorPart2 {
    /*  Everything is based off of the origin... 
        Keep in mind this vert array will be draw with GL_POLYGONS.
        */
    VertArray *va = malloc(sizeof(VertArray));
    if(va == NULL) {
        NSLog(@"Could not malloc some stuff!  AHHHHH!");
        return NULL;
    }
    va->vertCount = 5;
    va->verts = malloc(sizeof(Vertex)*va->vertCount);  // Don't forget to free this...
    if(va->verts == NULL) {
        NSLog(@"Could not malloc some stuff!  AHHHHH!");
        return NULL;
    }
    va->verts[0].x =-26.55; va->verts[0].z =  70.45; 
    va->verts[1].x =-26.55; va->verts[1].z =  81.05; 
    va->verts[2].x =-6.5;   va->verts[2].z =  81.05; 
    va->verts[3].x  =-6.5;  va->verts[3].z =  62.2; 
    va->verts[4].x  =-9;    va->verts[4].z =  60; 

    // For now, initialize these to zero.  we'll change this later...
    int i;
    for(i=0;i < va->vertCount; ++i) {
        va->verts[i].tu = 0.0;
        va->verts[i].tv = 0.0;
        // each unit is in 1 tile units...1 tile's width = 1 rack width, 
        // make the conversion
        va->verts[i].x *= STANDARD_RACK_WIDTH;
        va->verts[i].y = -0.5*STANDARD_RACK_HEIGHT;
        va->verts[i].z *= STANDARD_RACK_WIDTH;
    }
    return va;
}
+(VertArray*)getDataCenterFloorPart1 {
    /*  Everything is based off of the origin... 
        Keep in mind this vert array will be draw with GL_POLYGONS.
        */
    VertArray *va = malloc(sizeof(VertArray));
    if(va == NULL) {
        NSLog(@"Could not malloc some stuff!  AHHHHH!");
        return NULL;
    }
    va->vertCount = 13;
    va->verts = malloc(sizeof(Vertex)*va->vertCount);  // Don't forget to free this...
    if(va->verts == NULL) {
        NSLog(@"Could not malloc some stuff!  AHHHHH!");
        return NULL;
    }

    //va->verts[0].x =-27.55; va->verts[0].z = -5.5; 
    va->verts[0].x =-27.55; va->verts[0].z =  0.8; 
    va->verts[1].x =-27.55; va->verts[1].z =  70.45; 
    va->verts[2].x =-26.55;  va->verts[2].z =  70.45; 
    va->verts[3].x  =-9;     va->verts[3].z =  60; 
    va->verts[4].x  =-9;     va->verts[4].z =  51.5; 
    va->verts[5].x  =-6.5;   va->verts[5].z =  49.2;
    va->verts[6].x  =-6.5;   va->verts[6].z =  36.5; 
    va->verts[7].x  = 5.5;   va->verts[7].z =  36.5; 
    va->verts[8].x  = 5.5;   va->verts[8].z =  33.1; 
    va->verts[9].x  = 7.5;   va->verts[9].z =  33.1; 
    va->verts[10].x  = 7.5;   va->verts[10].z =  0.8; 
    va->verts[11].x  = 2.1;   va->verts[11].z =  0.8; 
    //va->verts[12].x = 2.1;   va->verts[12].z = -5.5; 
    va->verts[12].x = 2.1;   va->verts[12].z =  0.8; 
    // For now, initialize these to zero.  we'll change this later...
    int i;
    for(i=0;i < va->vertCount; ++i) {
        va->verts[i].tu = 0.0;
        va->verts[i].tv = 0.0;
        // each unit is in 1 tile units...1 tile's width = 1 rack width, 
        // make the conversion
        va->verts[i].x *= STANDARD_RACK_WIDTH;
        va->verts[i].y = -0.5*STANDARD_RACK_HEIGHT;
        va->verts[i].z *= STANDARD_RACK_WIDTH;
    }
    return va;
}
+(VertArray*)getDataCenterFloorPart3 {
    /*  Everything is based off of the origin... 
        Keep in mind this vert array will be draw with GL_POLYGONS.
        */
    VertArray *va = malloc(sizeof(VertArray));
    if(va == NULL) {
        NSLog(@"Could not malloc some stuff!  AHHHHH!");
        return NULL;
    }
    va->vertCount = 4;
    va->verts = malloc(sizeof(Vertex)*va->vertCount);  // Don't forget to free this...
    if(va->verts == NULL) {
        NSLog(@"Could not malloc some stuff!  AHHHHH!");
        return NULL;
    }
    va->verts[0].x = 2.1;    va->verts[0].z =    0.8; 
    va->verts[1].x = 2.1;    va->verts[1].z =   -5.5; 
    va->verts[2].x = -27.55;   va->verts[2].z = -5.5; 
    va->verts[3].x = -27.55;   va->verts[3].z =  0.8; 
    // For now, initialize these to zero.  we'll change this later...
    int i;
    for(i=0;i < va->vertCount; ++i) {
        va->verts[i].tu = 0.0;
        va->verts[i].tv = 0.0;
        // each unit is in 1 tile units...1 tile's width = 1 rack width, 
        // make the conversion
        va->verts[i].x *= STANDARD_RACK_WIDTH;
        va->verts[i].y = -0.5*STANDARD_RACK_HEIGHT;
        va->verts[i].z *= STANDARD_RACK_WIDTH;
    }
    return va;
}
@end
