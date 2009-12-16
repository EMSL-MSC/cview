#import "Location.h"

@implementation Location
-(int)getx {
    return x;
}
-(int)gety {
    return y;
}
-setx: (int)_x {
    self->x = _x;
    return self;
}
-sety: (int)_y {
    self->y = _y;
    return self;
}
@end

