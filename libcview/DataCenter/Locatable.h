#ifndef LOCATABLE_H
#define LOCATABLE_H
#import "Vector.h"
/**
    @author Brock Erwin

  * interface Locatable
  * simple class that holds a Location object
  */
#import <Foundation/NSObject.h>
#import "Point.h"
#import "Identifiable.h"
#import "Drawable.h"
#import "Pickable.h"
@interface Locatable : Identifiable <Drawable, Pickable> {
    Vector *location;
    Vector *rotation;
    NSString *name;
    float width;
    float height;
    float depth;
    // Used if you want to draw a box at a given location and rotation with a given width, height, and depth
    // in this case call -draw; or you can call -glPickDraw to use that box for picking purposes
    NSData *boundingBox;
    NSData *wireframeBox;
}
+(void)drawGLQuad: (Point) p1 andP2: (Point) p2
            andP3: (Point) p3 andP4: (Point) p4;
-setName: (NSString *) name;
-(NSString*) name;
-setLocation: (Vector*) _location;
-(Vector*) location;
-setRotation: (Vector*) _rotation;
-(Vector*) rotation;
-setWidth: (float) _width;
-setHeight: (float) _height;
-setDepth: (float) _depth;
-(float)width;
-(float)height;
-(float)depth;
/**
    Draws a opengl box (6 sided) at given location, rotation, width, depth, height
  */
-drawBox;
-draw;
-drawWireframe;
/**
    Easy way to do rotations and translations if you inherit this class.
    Simply call: setLocation with your current location AND
                 setRotation with your appropriate rotation
        Then you can call setupForDraw and based on location and rotation
        it will make gl calls to translate and rotate the current matrix

    Make sure you call cleanUpAfterDraw once done drawing stuff
  */
-setupForDraw;
-cleanUpAfterDraw;
/**
    called when picking objects in the scene (does not render)
    @return An array of objects that were picked
 */
-glPickDraw;
@end

#endif // LOCATABLE_H
