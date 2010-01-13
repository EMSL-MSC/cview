#ifndef IDARRAY_H
#define IDARRAY_H
#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
/**
    Used for holding an array of numbers
 */
@interface IdArray : NSObject {
    NSMutableArray *numbers;
}
-init;
-(int)count;
-addInt:(int)number;
-(int)index:(int)index;
/**
    @returns true if the passed number is in the array
 */
-(BOOL)isNumberInArray:(int)number;
@end
#endif
