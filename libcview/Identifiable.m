#import "Identifiable.h"
#import "IdDatabase.h"
@implementation Identifiable
-init {
    [super init];
    [self genUniqueId];
    return self;
}
/*
-setMyid: (int) _myid:
    [[IdDatabase releaseUniqueId: myid];
    myid = _myid;
    return self;
}*/
-(int)myid {
    return myid;
}
-genUniqueId {
    [[IdDatabase instance] releaseUniqueId: myid];   // first release the old one  
    // get a unique id from the IdDatabase
    myid = [[IdDatabase instance] reserveUniqueId];
    return self;
}
@end
