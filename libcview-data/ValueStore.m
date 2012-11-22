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

#import <Foundation/Foundation.h>
#import "ValueStore.h"
#import "ListComp.h"

@implementation ValueStore 
static ValueStore *singletonValueStore;
+(void)initialize {
	if ([ValueStore class] == self) {
		singletonValueStore = [[self alloc] init];
	}
}
+valueStore {
	return singletonValueStore;
}

-(id)init {
	[super init];
	values=[[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	return self;
}

-(void)dealloc {
	[values autorelease];
	[super dealloc];
}

-getPList {
	//return an array of triples sutable for loading with loadValueArray: call
	NSArray *keys = [values allKeys];
	NSMutableArray *res = [NSMutableArray arrayWithCapacity: [keys count]];
	NSString *key;
	NSEnumerator *e;
	e = [keys objectEnumerator];
	while ((key = [e nextObject])) {
		id o = [values objectForKey: key];
		NSArray *a = [NSArray arrayWithObjects: key,[o className],[o getPList],nil];
		[res addObject: a];
	}
	NSLog(@"resultantarray: %@",res);
	return res;
}

-initWithPList: (id)list {
	//Dont actually implement, it might be good to force this to use the singleton, but do we wipe then?...
	NSLog(@"initWithPList called in singleton class");
	return nil;
};

-loadKeyValueArray: (NSArray*)array {
	NSEnumerator *e;
	NSArray *a;
	NSLog(@"loadValueArray %@",array);
	e = [array objectEnumerator];
	while ((a = [e nextObject])) {
		NSLog(@"loading %@",a);
		if ([a count]==3)
			[self loadKey: [a objectAtIndex:0] withClass: [a objectAtIndex:1] andData: [a objectAtIndex:2]];
	}
	return self;
}

-loadKey: (NSString *)key withClass: (NSString *)clsName andData: (id)pListData {
	Class c;
	c = NSClassFromString(clsName);
	NSLog(@"Load Class From %@ with %@",c,pListData);
	if (c && [c conformsToProtocol: @protocol(PList)]) {
		id o = [c alloc];
		o = [o initWithPList: pListData];
		[self setKey: key withObject: o];
		[o autorelease];
	}
	return self;
}
-(void)setKey: (NSString *)key withObject: (id)value{
	NSLog(@"setValue: %@ for Key: %@",value,key);
	[values setValue: value forKey: key];
	return; 
}
-getObject: (NSString *)key {
	return [values objectForKey: key];
}
-getKeyForObject: (id)object {
	NSArray *arr;
	arr = [values allKeysForObject: object];
	if ([arr count]>1)
		NSLog(@"WARNING: multiple keys for same object:%@ %@",object,arr);
	if ([arr count]>=1)
		return [arr objectAtIndex:0];
	else 
		return nil;
}
-(NSUInteger)count {
	return [values count];
}
@end
