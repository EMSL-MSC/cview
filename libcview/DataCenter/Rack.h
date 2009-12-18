#ifndef RACK_H
#define RACK_H
#import "Locatable.h"
#import "Drawable.h"
#import "DrawableArray.h"
#import "Node.h"

/**
  * interface Rack
  * 
  */
@interface Rack : Locatable <Drawable> {
    DrawableArray *nodes;
@private
    BOOL vertsSetUp;
    int vertCount;
    Vertex* rackVerts;
}
+(unsigned int) texture;
+setTexture:(unsigned int)_texture;
-draw;
-addNode: (Node*) node;
@end

#endif // RACK_H
