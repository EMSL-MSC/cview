#import "Identifiable.h"
#import "IdDatabase.h"
#import <Foundation/Foundation.h>
@implementation Identifiable
-init {
    [super init];
    //NSLog(@"identifiable init");
    self->myid = [IdDatabase reserveUniqueId: self];
    return self;
}
-(unsigned int)myid {
    return self->myid;
}
-setMyid:(unsigned int)_myid {
    self->myid = _myid;
    return self;
}
@end
