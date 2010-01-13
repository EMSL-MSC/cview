#ifndef LOCATION_H
#define LOCATION_H
#import <Foundation/NSObject.h>
/**
    @author Brock Erwin
  * class Vector
  * simple class to hold an (x,y,z) vector
  * 
  */

@interface Vector : NSObject {
    float x,y,z;
}
-(float)x;
-(float)y;
-(float)z;
-setx:(float)_x;
-sety:(float)_x;
-setz:(float)_z;
-initWithZeroes;
@end

#endif // LOCATION_H
