#import "AisleOffsets.h"
#import <Foundation/Foundation.h>
@implementation AisleOffsets
// Created this little function using the data center map....
// I establised a baseline, and then counted how many tiles each
// aisle was away from the baseline.  Pretty simple, only problem is
// that it's hardcoded in here.....(maybe we don't care)
+(float)getAisleOffset: (int) aisle {
    if(aisle < 0) {
        NSLog(@"Someone passed a negetive aisle number!!! VERY BAD.");
        return 0;
    }else if(aisle == 1) {
        return 2.5;
    }else if(aisle == 2) {
        return -0.2;
    }else if(aisle == 3) {
        return 1;
    }else if(aisle == 4) {
        return 0;
    }else if(aisle == 5) {
        return 1;
    }else if(aisle == 6) {
        return 3.8;
    }else if(aisle <= 13) {
        return 11;
    }else if(aisle <= 16) {
        return 10;
    }else{
        NSLog(@"Someone passed an aisle greater than 16!!! Uh-oh.");
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
