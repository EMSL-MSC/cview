/*

This file is port of the CVIEW graphics system, which is goverened by the following License

Copyright © 2008,2009, Battelle Memorial Institute
All rights reserved.

1.	Battelle Memorial Institute (hereinafter Battelle) hereby grants permission
	to any person or entity lawfully obtaining a copy of this software and
	associated documentation files (hereinafter “the Software”) to redistribute
	and use the Software in source and binary forms, with or without
	modification.  Such person or entity may use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and may permit
	others to do so, subject to the following conditions:

	•	Redistributions of source code must retain the above copyright
		notice, this list of conditions and the following disclaimers. 
	•	Redistributions in binary form must reproduce the above copyright
		notice, this list of conditions and the following disclaimer in the
		documentation and/or other materials provided with the distribution.
	•	Other than as used herein, neither the name Battelle Memorial
		Institute or Battelle may be used in any form whatsoever without the
		express written consent of Battelle.  
	•	Redistributions of the software in any form, and publications based
		on work performed using the software should include the following
		citation as a reference:

			(A portion of) The research was performed using EMSL, a
			national scientific user facility sponsored by the
			Department of Energy's Office of Biological and
			Environmental Research and located at Pacific Northwest
			National Laboratory.

2.	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE OR CONTRIBUTORS BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
	THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

3.	The Software was produced by Battelle under Contract No. DE-AC05-76RL01830
	with the Department of Energy.  The U.S. Government is granted for itself
	and others acting on its behalf a nonexclusive, paid-up, irrevocable
	worldwide license in this data to reproduce, prepare derivative works,
	distribute copies to the public, perform publicly and display publicly, and
	to permit others to do so.  The specific term of the license can be
	identified by inquiry made to Battelle or DOE.  Neither the United States
	nor the United States Department of Energy, nor any of their employees,
	makes any warranty, express or implied, or assumes any legal liability or
	responsibility for the accuracy, completeness or usefulness of any data,
	apparatus, product or process disclosed, or represents that its use would
	not infringe privately owned rights.  

*/
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
