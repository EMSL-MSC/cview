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
    if(self->drawableObjects == nil) {
        NSLog(@"[DrawableArray draw]: self->drawableObjects was nil!");
        return self;
    }
    NSEnumerator *enumerator = [self->drawableObjects objectEnumerator];
    if(enumerator == nil) {
        NSLog(@"[DrawableArray draw]: enumerator was nil!");
        return self;
    }
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
-glPickDraw:(IdArray*) ids {
    if(self->drawableObjects == nil)
        return self;
    NSEnumerator *enumerator = [self->drawableObjects objectEnumerator];
    if(enumerator == nil)
        return self;
    id element;
    while((element = [enumerator nextObject]) != nil) {
        if([element respondsToSelector: @selector(glPickDraw:)] == YES)
            [element glPickDraw:ids];
    }
    return self;
}
-(NSMutableArray*) getPickedObjects: (IdArray*)pickDrawIds hits: (IdArray*)glHits {
    if(self->drawableObjects == nil)
        return nil;
    NSEnumerator *enumerator = [self->drawableObjects objectEnumerator];
    if(enumerator == nil)
        return nil;
    id element;
    NSMutableArray *mashedTogether = nil;
    NSMutableArray *tmp;
    while((element = [enumerator nextObject]) != nil) {
        if([element respondsToSelector: @selector(getPickedObjects:pickDrawIds:)] == YES) {
            tmp = [element getPickedObjects: pickDrawIds hits: glHits];
            if(tmp != nil) {
                if(mashedTogether == nil)
                    mashedTogether = [[NSMutableArray alloc] init];
                [mashedTogether addObject: tmp];
            }
        }
    }
    return mashedTogether;
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
