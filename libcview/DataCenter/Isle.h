#ifndef ISLE_H
#define ISLE_H
#import "Locatable.h"
#import "DrawableArray.h"
#import "Rack.h"
/**
    @author Brock Erwin
  * interface Isle
  * Is composed of an array of racks
  * 
  */

@interface Isle : Locatable <Drawable> {
    // Should hold an array of Rack objects
    DrawableArray *rackArray;
    int face;   // An angle, should be 0 or 180 degrees
}
// Draws every rack in the rackArray by sending draw messages to each rack
-draw;
// Adds a rack object to this isle object
-addRack: (Rack*) rack;
-(NSEnumerator*) getEnumerator;
-setface: (int) _face;
// Adds up all the rack widths that it contains
-(int)getWidth;
@end
#endif // ISLE_H
