#import "IsleOffsets.h"
#import <Foundation/Foundation.h>
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
+(VertArray*)getDataCenterFloor {
    /*  Everything is based off of the origin... 
        Keep in mind this vert array will be draw with GL_POLYGONS.
        */
    VertArray *va = malloc(sizeof(VertArray));
    if(va == NULL) {
        NSLog(@"Could not malloc some stuff!  AHHHHH!");
        return NULL;
    }
    va->vertCount = 16;
    va->verts = malloc(sizeof(Vertex)*va->vertCount);  // Don't forget to free this...
    if(va->verts == NULL) {
        NSLog(@"Could not malloc some stuff!  AHHHHH!");
        return NULL;
    }

    va->verts[0].x  = 2.1;   va->verts[0].z =  0.8; 
    va->verts[1].x  = 7.5;   va->verts[1].z =  0.8; 
    va->verts[2].x  = 7.5;   va->verts[2].z =  33.1; 
    va->verts[3].x  = 5.5;   va->verts[3].z =  33.1; 
    va->verts[4].x  = 5.5;   va->verts[4].z =  36.5; 
    va->verts[5].x  =-6.5;   va->verts[5].z =  36.5; 
    va->verts[6].x  =-6.5;   va->verts[6].z =  49.2;
    va->verts[7].x  =-9;     va->verts[7].z =  51.5; 
    va->verts[8].x  =-9;     va->verts[8].z =  60; 
    va->verts[9].x  =-6.5;   va->verts[9].z =  62.2; 
    va->verts[10].x =-6.5;   va->verts[10].z =  81.05; 
    va->verts[11].x =-26.55; va->verts[11].z =  81.05; 
    va->verts[12].x =-26.55; va->verts[12].z =  70.45; 
    va->verts[13].x =-27.55; va->verts[13].z =  70.45; 
    va->verts[14].x =-27.55; va->verts[14].z = -5.5; 
    va->verts[15].x = 2.1;   va->verts[15].z = -5.5; 

    // For now, initialize these to zero.  we'll change this later...
    int i;
    for(i=0;i < va->vertCount; ++i) {
        va->verts[i].tu = 100.0;
        va->verts[i].tv = 100.0;
        // each unit is in 1 tile units...1 tile's width = 1 rack width, 
        // make the conversion
        va->verts[i].x *= STANDARD_RACK_WIDTH;
        va->verts[i].y = -2*STANDARD_RACK_HEIGHT;
        va->verts[i].z *= STANDARD_RACK_WIDTH;
    }
    // oops, drew them counter-clockwise accidentally, reverse it

    float x,y,z;
    for(i=0;i < va->vertCount/2; ++i) {
        x=va->verts[i].x; y=va->verts[i].y; z=va->verts[i].z;
        
        va->verts[i].x = va->verts[va->vertCount-i-1].x;
        va->verts[i].y = va->verts[va->vertCount-i-1].y;
        va->verts[i].z = va->verts[va->vertCount-i-1].z;
        va->verts[va->vertCount-i-1].x = x;
        va->verts[va->vertCount-i-1].y = y;
        va->verts[va->vertCount-i-1].z = z;
/*
        if(va->verts[i].x == 0 ||
            va->verts[i].y == 0 ||
            va->verts[i].z == 0) {
            printf("x is: %f, y is: %f, z is: %f i is: %d", va->verts[i].x, va->verts[i].y, va->verts[i].z, i);
            printf("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHH NON BAD BAD BOY!\n");
        }
*/
    }

    return va;
}
@end
