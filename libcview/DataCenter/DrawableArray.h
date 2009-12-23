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
@interface DrawableArray : NSObject <Drawable> {
    NSMutableArray *drawableObjects;
}
-addDrawableObject: (id <Drawable>) drawableObject;
-draw;
-drawOne;
-(NSEnumerator*)getEnumerator;
-(int)count;
@end

#endif
