#ifndef IDENTIFIABLE_H
#define IDENTIFIABLE_H
#import <Foundation/NSObject.h>
@interface Identifiable : NSObject {
@private
    unsigned int myid;
}
/// generates a unique id with a call to IdDatabase
-init;
/**
    @returns a unique id used to identify this object
  */
-(unsigned int)myid;
/**
    Normally you should not call this.
    -init sets myid by calling [IdDatabase reserveUniqueId: self] which 
    guarantees that myid will be unique.  If you must call this,
    make sure you get an id from [IdDatabase reserveUniqueId: id]
    
    @param sets a new id number
  */
-setMyid:(unsigned int)_myid;
@end
#endif
