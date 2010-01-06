#ifndef RACK_H
#define RACK_H
#import "Locatable.h"
#import "Drawable.h"
#import "Pickable.h"
#import "DrawableArray.h"
#import "Node.h"
#import "Point.h"
#import "../GLText.h"

/**
  * interface Rack
  * 
  */

@interface Rack : Locatable <Drawable, Pickable> {
    DrawableArray *nodes;
@private
    BOOL wireframe;     // if yes draw the racks as wireframe
    BOOL drawname;
    //int vertCount;
    //Vertex* rackVerts;
    float r,g,b; // color stuff...
    int face; // degress in which the rack is facing
    VertArray *rackArray;
}
//+(void) setRackArray: (VertArray*) _rackArray;
+(unsigned int) texture;
+setTexture:(unsigned int)_texture;
+setGLTName:(GLText*) _gltName; // kind of 3d text we'll use to draw the rack name
-initWithName:(NSString*)_name;
-draw;
/// called when picking objects in the scene (does not render)
-(NSMutableArray*)pickDrawX: (int)x andY: (int)y;
-addNode: (Node*) node;
-setFace: (int) _face;  // angle in degrees in which the rack is facing
-startFading; // makes this rack start fading (being transparent) over a period of time
@end

#endif // RACK_H
