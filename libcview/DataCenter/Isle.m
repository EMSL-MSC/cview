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
    return self;
}
-(Node*)findNodeObjectByName:(NSString*) _name {
    if(self->rackArray == nil)
        return nil;
    NSEnumerator *enumerator = [self->rackArray getEnumerator];
    if(enumerator == nil)
        return nil;
    id element;
    Node *node;
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"ONE ITERATION OF THE ISLE LOOP**********");
        node = [element findNodeObjectByName: _name];
        if(node != nil)
            return node;
    }
    return nil; 
}
-startFading {
    if(self->rackArray == nil)
        return self;
    NSEnumerator *enumerator = [self->rackArray getEnumerator];
    if(enumerator == nil)
        return self;
    id element;
    while((element = [enumerator nextObject]) != nil)
        [element startFading];
    return self;
}
-draw {
    [super setupForDraw];
        [super draw];       // Draw bounding box around isle
        //glColor3f(1,1,1);
        [self->rackArray draw];
        //glColor3f(.1,.1,.3);
    [super cleanUpAfterDraw];
    return self;
}
-glPickDraw: (IdArray*)ids {
    if([ids isNumberInArray: [self myid]] == YES)
        // Found myid in the ids array, do furthing picking...
        [rackArray glPickDraw:ids];
    else
        //////////////////////////////////////////////////////////////////////
        // No, we are doing a pickdraw on just the **basic** isle itself   ///
        //   i.e. don't draw the name, don't draw the nodes, just the rack ///
        //////////////////////////////////////////////////////////////////////
        [super glPickDraw: ids];
    return self;
}
-(NSMutableArray*) getPickedObjects: (IdArray*)pickDrawIds hits: (IdArray*)glHits {
    if([pickDrawIds isNumberInArray: [self myid]] == NO)
        return nil;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject: self];  // Add this rack to the array
    [arr addObject: [rackArray getPickedObjects: pickDrawIds hits: glHits]];
    return arr;
}
-addRack: (Rack*) rack {
    self->rackArray = [self->rackArray addDrawablePickableObject: rack];
    return self;
}
-(NSEnumerator*) getEnumerator {
    NSEnumerator *enumerator = [self->rackArray getEnumerator];
    return enumerator;
}
/*
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
*/
@end
