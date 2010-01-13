#ifndef IDDATABASE_H
#define IDDATABASE_H
#import <Foundation/NSArray.h>
/**
    The IdDatabase is used to keep track of ids being assigned to object
    for picking purposes when glRenderMode(GL_SELECT) is called
    It implements the singleton design pattern
  */
@interface IdDatabase : NSObject {
@private
#define ID_COUNT 50000
    NSMutableArray *ids;
}
+(IdDatabase*)instance;
/// resets the whole database with new ids
-initIds;
/**
    @returns a unique id to be used in conjunction with glPushName(*theid*)
             is -1 if there are no unique ids left
 */
-(int)reserveUniqueId;
/// this probably won't get used, instead just call initIds to reset the whole thing
-releaseUniqueId: (int)number ;
-(id)retain ;
-(void)release ;
-(id)autorelease ;

@end
#endif
