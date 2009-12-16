#import "Node.h"
#import <Foundation/NSString.h>
@implementation Node
-init {
    [super init];
    return self;
 }
-draw {
    //printf("%s\n", [[self getName] UTF8String]);
    return self;
}
-setTemperature: (int) _temperature {
    self->temperature = _temperature;
    return self;
}
-(int)getTemperature {
    return self->temperature;
}
@end
