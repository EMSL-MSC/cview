#import "DrawableArray.h"
#import <Foundation/NSEnumerator.h>

@implementation DrawableArray
-init {
    [super init];
    drawableObjects = [[NSMutableArray alloc] init];
    return self;
}
-addDrawableObject: (id <Drawable>) drawableObject {
    // Add the passed rack to our rack_array
    //NSLog(@"Adding a drawable object!");
    [self->drawableObjects addObject: drawableObject];
    //NSLog(@"drawableObjecs count == %d", [drawableObjects count]);
    return self;
}
-draw {
    //NSLog(@"about to get an enumerator...");
    if(self->drawableObjects == nil)
        NSLog(@"[DrawableArray draw]: self->drawableObjects was nil!");
    NSEnumerator *enumerator = [self->drawableObjects objectEnumerator];
    if(enumerator == nil)
        NSLog(@"[DrawableArray draw]: enumerator was nil!");
    id element;
    //int x = 0;
    //NSLog(@"drawableObjecs count == %d", [drawableObjects count]);
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"x == %d", x++);
        [element draw];
    }
    //NSLog(@"After the draw loop!");
    return self;
}
-(NSEnumerator*)getEnumerator {
    if(self->drawableObjects == nil) {
        NSLog(@"getEnumerator: drawableObjects is nil!!!!!!!");
        return nil;
    }
    NSEnumerator *enumerator = [self->drawableObjects objectEnumerator];
    return enumerator;
}
-(int)count {
    return [drawableObjects count];
}
@end
