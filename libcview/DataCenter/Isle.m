#import "Isle.h"
#import <Foundation/Foundation.h>
#import <gl.h>
#import <glut.h>
#import <math.h>
#import "IsleOffsets.h"

@implementation Isle
-init {
    [super init];
    self->rackArray = [[DrawableArray alloc] init];
    self->face = 0;
    return self;
}
-setface: (int) _face {
    self->face = _face;
    return self;
}
-(int)getFace {
    return face;
}
-draw {
    //Location *l = [self getLocation];
    //int x = [l getx];
    //int y = [l gety];
    int scale = 3.5*TILE_WIDTH; // Spacing between isles
    float thenum = 0;
    //if(self->face == 0)
        thenum = -[self getWidth]+STANDARD_RACK_WIDTH;
    thenum -= STANDARD_RACK_WIDTH*[IsleOffsets getIsleOffset: [[self getLocation] getx]];
    int additionalstuff = 0;
    if([[self getLocation] getx] > 6)
        additionalstuff = 20*TILE_WIDTH;
    glPushMatrix();
    // Move this isle one way or the other depending on which way it's facing...
    glTranslatef(thenum,0,scale*([[self getLocation] getx]-1)+0.5*STANDARD_RACK_DEPTH
                    +additionalstuff);
    
    [self->rackArray draw];
    glPopMatrix();
    return self;
}
-addRack: (Rack*) rack {
    self->rackArray = [self->rackArray addDrawableObject: rack];
    return self;
}
-(NSEnumerator*) getEnumerator {
    NSEnumerator *enumerator = [self->rackArray getEnumerator];
    return enumerator;
}
-(int)getWidth {
    NSEnumerator *enumerator = [self->rackArray getEnumerator];
    if(enumerator == nil)
        NSLog(@"[Isle getWidth]: enumerator was nil!");
    id element;
    int _width = 0;
    while((element = [enumerator nextObject]) != nil)
        _width += [element getWidth];
    return _width;
}
@end
