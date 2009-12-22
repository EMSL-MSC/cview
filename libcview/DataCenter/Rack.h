#ifndef RACK_H
#define RACK_H
#import "Locatable.h"
#import "Drawable.h"
#import "DrawableArray.h"
#import "Node.h"
#import "Point.h"
#import "../GLText.h"

/**
  * interface Rack
  * 
  */

@interface Rack : Locatable <Drawable> {
    DrawableArray *nodes;
@private
    BOOL vertsSetUp;
    BOOL wireframe;     // if yes draw the racks as wireframe
    //int vertCount;
    //Vertex* rackVerts;
    VertArray *rack;
    float r,g,b; // color stuff...
    GLText *gltName;
    int face; // degress in which the rack is facing
}
+(unsigned int) texture;
+setTexture:(unsigned int)_texture;
-initRackVerts;
-initWithName:(NSString*)_name;
-draw;
-addNode: (Node*) node;
-setFace: (int) _face;
@end

#endif // RACK_H
