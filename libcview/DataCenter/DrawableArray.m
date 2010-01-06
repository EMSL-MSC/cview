#import "DrawableArray.h"
#import <Foundation/NSEnumerator.h>

@implementation DrawableArray
-init {
    [super init];
    drawableObjects = [[NSMutableArray alloc] init];
    return self;
}
-addDrawablePickableObject: (id <Drawable, Pickable>) drawableObject {
    // Add the passed rack to our rack_array
    //NSLog(@"Adding a drawable object!");
    [self->drawableObjects addObject: drawableObject];
    //NSLog(@"drawableObjecs count == %d", [drawableObjects count]);
    return self;
}
-drawOne {
    //NSLog(@"about to get an enumerator...");
    if(self->drawableObjects == nil)
        NSLog(@"[DrawableArray draw]: self->drawableObjects was nil!");
    NSEnumerator *enumerator = [self->drawableObjects objectEnumerator];
    if(enumerator == nil)
        NSLog(@"[DrawableArray draw]: enumerator was nil!");
    id element;
    //int x = 0;
    //NSLog(@"drawableObjecs count == %d", [drawableObjects count]);
    element = [enumerator nextObject];
        //NSLog(@"x == %d", x++);
        [element draw];
    
    //NSLog(@"After the draw loop!");
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
-(NSMutableArray*)pickDrawX: (int)x andY: (int)y {
    if(self->drawableObjects == nil)
        NSLog(@"[DrawableArray draw]: self->drawableObjects was nil!");
    NSEnumerator *enumerator = [self->drawableObjects objectEnumerator];
    if(enumerator == nil)
        NSLog(@"[DrawableArray draw]: enumerator was nil!");
    id element;
    //int x = 0;
    //NSLog(@"drawableObjecs count == %d", [drawableObjects count]);
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSMutableArray *tmp;
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"x == %d", x++);
        if([element respondsToSelector: @selector(pickDrawX:andY:)] == YES) {
            tmp = [element pickDrawX: x andY: y];
            if(tmp != nil)
                [ret addObject: tmp];
        }
    }
    //NSLog(@"After the draw loop!");
    return ret;
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
