#ifndef IDENTIFIABLE_H
#define IDENTIFIABLE_H
#import <Foundation/NSObject.h>
@interface Identifiable : NSObject {
    int myid;
}
-init;
-(int)myid;
//-setMyid: (int) _myid:
/// generates a unique id using the IdDatabase class
-genUniqueId;
@end
#endif
