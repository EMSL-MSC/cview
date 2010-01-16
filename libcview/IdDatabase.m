#import "IdDatabase.h"
#import <Foundation/NSValue.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSEnumerator.h>
/** 
    Simple little class to allow us to store a number and an object together
  */
@interface NumberObject : NSObject {@private    unsigned int number;    id object;}
@end
@implementation NumberObject
-(NSUInteger)hash {return number;}
-(BOOL)isEqual: (id) anObject {return number == [anObject hash];}
-(unsigned int)number{return number;}
-(id)object{return object;}
-setNumber:(unsigned int)_number{number=_number;return self;}
-setObject:(id)_object{object=_object;return self;}
@end



static NSMutableSet *database = nil;
static NumberObject *tmpNumberObject = nil;
@implementation IdDatabase
+initIds {
    if(database != nil)
        [database autorelease];
    database = [[NSMutableSet alloc] init];
    return self;
}
+(unsigned int)reserveUniqueId: (id) object {
    if(object == nil) {NSLog(@"<IdDatabase> tried to reserve a nil object!"); return -1;}
    if(database == nil) database = [[NSMutableSet alloc] init];
    [database addObject:
        [[[[NumberObject alloc] init] setObject: object] setNumber: [database count]]
            ];
    //NSLog(@"reserving a unique id, count: %d, object: %@", [database count], [object className]);
    return [database count]-1;
}
+(id) objectForId: (unsigned int) number {
    //NSLog(@"looking for unique id: %d", number);
    if(database == nil) return nil;
    if(tmpNumberObject == nil) tmpNumberObject = [[NumberObject alloc] init];

    return [[database member: [tmpNumberObject setNumber: number]] object];
}
+releaseUniqueId: (unsigned int)number {
    if(database == nil) database = [[NSMutableSet alloc] init];
    if(tmpNumberObject == nil) tmpNumberObject = [[NumberObject alloc] init];
    NumberObject *remove = [database member: [tmpNumberObject setNumber: number]];
    unsigned int count = [database count];   // how many before we try to remove
    [database removeObject: remove];
    [remove autorelease];
    if([database count] < count) {
        // count went down, fill in the gap in numbers that we just made
        NumberObject *no = [database member: [tmpNumberObject setNumber: count-1]];
//        NSLog(@"filling in a gap: %@", [no object] );
//        NSLog(@"new number: %d", [no number] );
        [database removeObject: no];
        [no setNumber: number];
        [database addObject: no];
//        NSLog(@"new number: %d", [no number] );
//        NSLog(@"filling in a gap: %@", [no object] );
    }
//    NSLog(@"count before: %d after %d", count, [database count]);
    return self;
}
+print {
    NSEnumerator *enumerator = [[database allObjects] objectEnumerator];
    id element;
    while((element = [enumerator nextObject]) != nil) {
        NSLog(@"id: %d object: %@", [element number], [element object]);
    }
    return self;
}
+(unsigned int)count {
    if(database == nil)
        return 0;
    return [database count];
}
@end
