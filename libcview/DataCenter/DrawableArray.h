#ifndef DRAWABLEARRAY_H
#define DRAWABLEARRAY_H
/**
    @author Brock Erwin

  * interface DrawableArray
  * Holds an array of drawable objects
  * Sending a draw message to this object will send draw messages
  * to every drawable object in its array
  */
#import <Foundation/Foundation.h>
#import "Drawable.h"
#import "Pickable.h"
@interface DrawableArray : NSObject <Drawable, Pickable> {
    NSMutableArray *drawableObjects;
}
-addDrawablePickableObject: (id <Drawable, Pickable>) drawableObject;
-draw;
/// called when picking objects in the scene (does not render)
-(NSMutableArray*)pickDrawX: (int)x andY: (int)y;
/// TODO: should remove this selector - just for testing purposes...
-drawOne;
/// Returns an enumerator for the drawable objects array it holds
-(NSEnumerator*)getEnumerator;
-(int)count;
@end

#endif
