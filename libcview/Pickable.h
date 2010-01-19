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
@end
#endif
