#ifndef LOCATION_H
#define LOCATION_H
#import <Foundation/NSObject.h>
/**
    @author Brock Erwin
  * class Location
  * simple class to hold an (x,y) vector
  * representing a location on the data-center floor
  * 
  */

@interface Location : NSObject {
    int x,y;
}
-(int)getx;
-(int)gety;
-setx:(int)x;
-sety:(int)x;

@end

#endif // LOCATION_H
