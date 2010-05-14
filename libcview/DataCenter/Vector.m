#import "Vector.h"

@implementation Vector
-initWithZeroes {
    x = 0; y = 0; z = 0;
    return self;
}
-init {
    [super init];
    [self initWithZeroes];
    return self;
}
-(float)x {
    return x;
}
-(float)y {
    return y;
}
-(float)z {
    return z;
}
-setx: (float)_x {
    self->x = _x;
    return self;
}
-sety: (float)_y {
    self->y = _y;
    return self;
}
-setz: (float)_z {
    self->z = _z;
    return self;
}
@end

