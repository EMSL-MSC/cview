#import "IdArray.h"
#import <Foundation/NSValue.h>
#import <Foundation/NSEnumerator.h>

@implementation IdArray

-init {
    numbers = [[NSMutableArray alloc] init];
    return self;
}
-(int)count{
    return [numbers count];
}
-addInt:(int)number {
    [numbers addObject: [NSNumber numberWithInt: number]];
    return self; 
}
-insert:(int)number atIndex:(int)i {
    [numbers insertObject: [NSNumber numberWithInt: number] atIndex: i];
    return self;
}
-(int)index:(int)i {
    return [[numbers objectAtIndex: i] intValue];
}
-(BOOL)isNumberInArray:(int)number {
    if(numbers == nil)
        return NO;
    NSEnumerator *enumerator = [numbers objectEnumerator];
    if(enumerator == nil)
        return NO;
    id element;
    while((element = [enumerator nextObject]) != nil)
        if([element intValue] == number)
            return YES;
    return NO;
}
@end
