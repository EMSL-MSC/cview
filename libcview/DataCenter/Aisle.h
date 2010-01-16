#ifndef AISLE_H
#define AISLE_H
#import "Locatable.h"
#import "Rack.h"
/**
    @author Brock Erwin
  * interface Aisle
  * Is composed of an array of racks
  * 
  */

@interface Aisle : Locatable <Drawable, Pickable> {
    // Should hold an array of Rack objects
    NSMutableArray *racks;
}
// Draws every rack in the rackArray by sending draw messages to each rack
-draw;
/// called when picking objects in the scene (does not render)
-glPickDraw;
// Adds a rack object to this aisle object
-addRack: (Rack*) rack;
-(NSEnumerator*) getEnumerator;
// Adds up all the rack widths that it contains
//-(int)getWidth;
-startFading;// tell the whole aisle to fade (become transparent) over time
/// Returns a pointer to a node object whose name matches the passed string
-(Node*)findNodeObjectByName:(NSString*) _name;
@end
#endif // AISLE_H
