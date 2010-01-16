#import "Aisle.h"
#import <Foundation/Foundation.h>
#import <gl.h>
#import <glut.h>
#import <math.h>
#import "AisleOffsets.h"

@implementation Aisle
-init {
    [super init];
    self->racks = [[NSMutableArray alloc] init];
    return self;
}
-(Node*)findNodeObjectByName:(NSString*) _name {
    if(self->racks == nil)
        return nil;
    NSEnumerator *enumerator = [self->racks objectEnumerator];
    if(enumerator == nil)
        return nil;
    id element;
    Node *node;
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"ONE ITERATION OF THE AISLE LOOP**********");
        node = [element findNodeObjectByName: _name];
        if(node != nil)
            return node;
    }
    return nil; 
}
-startFading {
    if(self->racks == nil)
        return self;
    NSEnumerator *enumerator = [self->racks objectEnumerator];
    if(enumerator == nil)
        return self;
    id element;
    while((element = [enumerator nextObject]) != nil)
        [element startFading];
    return self;
}
-draw {
    [super setupForDraw];
        glColor3f(.1,.1,.3);
        //[super draw];       // Draw bounding box around isle
        //glColor3f(1,1,1);
        [self->racks makeObjectsPerformSelector:@selector(draw)]; // draw the nodes

    [super cleanUpAfterDraw];
    return self;
}
-glPickDraw {
    [super setupForDraw];
        [racks makeObjectsPerformSelector:@selector(glPickDraw)];
    [super cleanUpAfterDraw];
    return self;
}
-addRack: (Rack*) rack {
    if(self->racks != nil)
        [self->racks addObject: rack];
    return self;
}
-(NSEnumerator*) getEnumerator {
    NSEnumerator *enumerator = [self->racks objectEnumerator];
    return enumerator;
}
@end
