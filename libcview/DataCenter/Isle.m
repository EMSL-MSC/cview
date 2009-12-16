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
#define PI 3.1415
#define standardrackwidth 
-draw {
    Location *l = [self getLocation];
    int x = [l getx];
    int y = [l gety];
    int scale = 100;
    float thenum = 0;// = cos((self->face/180)*PI)*rowscale*[self getWidth];
    if(self->face == 0)
        thenum = -[self getWidth]+STANDARD_RACK_WIDTH;
    thenum -= STANDARD_RACK_WIDTH*[IsleOffsets getIsleOffset: [[self getLocation] getx]];

    glPushMatrix();
    //NSLog(@"self->face == %d", self->face);
    // Move this isle one way or the other depending on which way it's facing...
    glTranslatef(thenum,0,scale*[[self getLocation] getx]);
    //NSLog(@"rackArray count == %f",thenum);
    //NSLog(@"rackArray count == %f", cos((double)PI));
    //NSLog(@"rackArray count == %d", self->face);
    glRotatef(self->face,0,1,0);
    //NSLog(@"y = %d", [[self getLocation] getx]);
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
