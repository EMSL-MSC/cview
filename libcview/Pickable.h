#ifndef PICKABLE_H
#define PICKABLE_H
/**
    protocol Drawable
    The sole purpose of this protocol is to make sure all inherited objects have a glPickDraw selector defined
  */
@protocol Pickable
/**
    @author Brock Erwin
    @returns self;
 */
-glPickDraw;
@end
#endif
