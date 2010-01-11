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

@interface Isle : Locatable <Drawable, Pickable> {
    // Should hold an array of Rack objects
    DrawableArray *rackArray;
}
// Draws every rack in the rackArray by sending draw messages to each rack
-draw;
/// called when picking objects in the scene (does not render)
-glPickDraw: (IdArray*)ids;
-(NSMutableArray*) getPickedObjects: (IdArray*)pickDrawIds hits: (IdArray*)glHits;
// Adds a rack object to this isle object
-addRack: (Rack*) rack;
-(NSEnumerator*) getEnumerator;
// Adds up all the rack widths that it contains
//-(int)getWidth;
-startFading;// tell the whole isle to fade (become transparent) over time
/// Returns a pointer to a node object whose name matches the passed string
-(Node*)findNodeObjectByName:(NSString*) _name;
@end
#endif // ISLE_H
