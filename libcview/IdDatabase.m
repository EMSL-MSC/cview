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
+(NumberObject*) initWithNumber: (int) _number {
    return [[[[[NumberObject alloc] init] setNumber: _number] setObject: nil] autorelease];
}
@end

static NSMutableSet *database = nil;
static unsigned int number = 0;
@implementation IdDatabase
+initialize {
    if(database != nil)
        [database autorelease];
    database = [[NSMutableSet alloc] init];
    return self;
}
+(unsigned int)reserveUniqueId: (id) object {
    if(object == nil) {NSLog(@"<IdDatabase> tried to reserve a nil object!"); return -1;}
    [database addObject:
        [[[[NumberObject alloc] init] setObject: object] setNumber: number++]
            ];
    //NSLog(@"reserving a unique id, count: %d, object: %@", [database count], [object className]);
    return [database count]-1;
}
+(id) objectForId: (unsigned int) number {
    //NSLog(@"looking for unique id: %d", number);
    return [[database member: [NumberObject initWithNumber: number]] object];
}
+releaseUniqueId: (unsigned int)number {
    NumberObject *remove = [database member: [NumberObject initWithNumber: number]];
    [database removeObject: remove];
    [remove autorelease];
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
