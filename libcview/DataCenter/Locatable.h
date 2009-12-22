#ifndef LOCATABLE_H
#define LOCATABLE_H
#import "Location.h"
/**
    @author Brock Erwin

  * interface Locatable
  * simple class that holds a Location object
  */
#import <Foundation/NSObject.h>
#import "Point.h"
@interface Locatable : NSObject {
    Location *location;
    NSString *name;
    float width;
    float height;
    float depth;
}
+(void)drawGLQuad: (Point) p1 andP2: (Point) p2
            andP3: (Point) p3 andP4: (Point) p4;
-setName: (NSString *) name;
-(NSString*) getName;
-setLocation: (Location*) location;
-(Location*) getLocation;
-setWidth: (float) _width;
-setHeight: (float) _height;
-setDepth: (float) _depth;
-(float)getWidth;
-(float)getHeight;
-(float)getDepth;
@end

#endif // LOCATABLE_H
