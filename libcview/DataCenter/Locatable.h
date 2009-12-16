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
    int width;
    int height;
    int depth;
}
+(void)drawGLQuad: (struct Point) p1 andP2: (struct Point) p2
      andP3: (struct Point) p3 andP4: (struct Point) p4;
-setName: (NSString *) name;
-(NSString*) getName;
-setLocation: (Location*) location;
-(Location*) getLocation;
-setWidth: (int) _width;
-setHeight: (int) _height;
-setDepth: (int) _depth;
-(int)getWidth;
-(int)getHeight;
-(int)getDepth;
@end

#endif // LOCATABLE_H
