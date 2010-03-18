#ifndef RACK_H
#define RACK_H
#import <Foundation/NSString.h>
#import "Locatable.h"
#import "Drawable.h"
#import "Pickable.h"
#import "Node.h"
#import "Point.h"
#import "../GLText.h"

/**
    interface Rack
    @author Brock Erwin

  */

@interface Rack : Locatable <Drawable, Pickable> {
    NSMutableArray *nodes;
@private
    NSString *color;
    BOOL wireframe;     // if yes draw the racks as wireframe
    BOOL drawname;
    float r,g,b; // color stuff...
}
//+(void) setRackArray: (VertArray*) _rackArray;
+(unsigned int) texture;
+setTexture:(unsigned int)_texture;
+setGLTName:(GLText*) _gltName; // kind of 3d text we'll use to draw the rack name
-initWithName:(NSString*)_name;
-draw;
/// called when picking objects in the scene (does not render)
-glPickDraw;
-addNode: (Node*) node;
-(int)nodeCount;
-startFading; // makes this rack start fading (being transparent) over a period of time
-(NSString*)color;
-setColor:(NSString*)_color;
-cleanUp;
@end

#endif // RACK_H
