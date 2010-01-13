#import "IdDatabase.h"
#import <Foundation/NSValue.h>

static IdDatabase *instance = nil;
@implementation IdDatabase
+(IdDatabase*)instance
{
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[IdDatabase alloc] init];
            [instance initIds];
        }
    }
    return instance;
}
-initIds {
    if(ids != nil)
        [ids autorelease];
    ids = [NSMutableArray arrayWithCapacity: ID_COUNT];
    int i;
    for(i=0;i<ID_COUNT;++i)
        [ids addObject: [NSNumber numberWithInt: i]];
    return self;
}
/// return -1 if there are no unique ids left
-(int)reserveUniqueId {
    if([ids count] > 0) {
        id obj = [ids objectAtIndex: 0];
        int num = [obj intValue];
        [ids removeObjectAtIndex: 0];
        return num;
    }else
        return -1;
}
-releaseUniqueId: (int)number {
    int i;
    for(i=0;i<[ids count];++i)
        if([[ids objectAtIndex: i] intValue] == number) 
            return self;
    [ids addObject: [NSNumber numberWithInt: number]];
    return self;
}
-(id)retain {
    return self;
}
-(void)release {
    //do nothing
}
-(id)autorelease {
    return self;
}

@end
