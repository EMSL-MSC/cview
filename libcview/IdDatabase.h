#ifndef IDDATABASE_H
#define IDDATABASE_H
#import <Foundation/NSArray.h>
/**
    The IdDatabase is used to keep track of ids being assigned to object
    for picking purposes when glRenderMode(GL_SELECT) is called
    It implements the singleton design pattern
  */
@interface IdDatabase : NSObject
/// resets the whole database - erases old ids
+initIds;
/**
    @returns a unique id to be used in conjunction with glPushName(*theid*)
    @param the object that should be associated with the id
 */
+(unsigned int)reserveUniqueId: (id) object;
/**
    @returns the object that is associated with the unique id that is passed
             is nil if no object with that number is found
    @param   the unique identification number
  */
+(id) objectForId: (unsigned int) number; 
/// this probably won't get used, instead just call initIds to reset the whole thing
+releaseUniqueId: (unsigned int)number ;
+(unsigned int)count;
@end
#endif
