#ifndef PICKABLE_H
#define PICKABLE_H
#import <Foundation/NSArray.h>
#import "IdArray.h"
/**
    protocol Drawable
    The sole purpose of this protocol is to make sure
    all inherited objects have a pickDrawX:andY: selector defined
  */
@protocol Pickable
/// call the pickdraw selector only on passed ids
/**
    @author Brock Erwin
    @returns self;
 */
-glPickDraw;
/**
    @author Brock Erwin
    @returns objects that correspond to a particular unique id.
    @param pickDrawIds are the ids which which we originally caled glPickDraw with
           this is used so we don't compare hits with objects we didn't even test
    @param glHits contain the unique ids that got hit and were returned from glRenderMode()
 */
//-(NSMutableArray*) getPickedObjects: (IdArray*)pickDrawIds hits: (IdArray*)glHits;
@end
#endif
