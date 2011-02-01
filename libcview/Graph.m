/*

This file is part of the CVIEW graphics system, which is goverened by the following License

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
#include "Graph.h"
@implementation Graph
-(id) init {
	[super init];
	verts = [[NSMutableDictionary dictionaryWithCapacity:32] retain];
	edges = [[NSMutableDictionary dictionaryWithCapacity:32] retain];
	return self;
}

-(void)dealloc {
	NSLog(@"%@ dealloc",[self class]);
	[verts autorelease];
	[edges autorelease];
	[super dealloc];
	return;
}

-(void) addVertex: (NSString *)name {
	[self addVertex: name withInfo: [NSNull null]];
	return;
}

-(void) addVertex: (NSString *)name withInfo: (id)data {
	if (data == nil)
		data = [NSNull null];
	[verts setValue:data forKey: name];
	return;	
}

-(BOOL) removeVertex: (NSString *)name {
	NSArray *edge;
	NSEnumerator *list;
	//Verify no edges have this vertex
	list = [self edgeEnumerator];
	while ( (edge = [list nextObject]) ) {
		if ([edge containsObject: name])
			return NO;
	}
	[verts removeObjectForKey: name];
	return YES;
}

-(NSEnumerator *)vertexEnumerator {
	return [[verts allKeys] objectEnumerator];
}

-(BOOL) addEdge: (NSString *)end1 and: (NSString *)end2 {
	return [self addEdge: end1 and: end2 withInfo: [NSNull null]];
}

-(BOOL) addEdge: (NSString *)end1 and: (NSString *)end2 withInfo: (id) data {
	NSArray *key;
	if (data == nil)
		data = [NSNull null];
	//Verify edges are valid.
	if ([verts objectForKey: end1] != nil && [verts objectForKey: end2] != nil) {
		key = [NSArray arrayWithObjects: end1,end2,nil];
		[edges setObject: data forKey: key];
		return YES;
	}
	else
		return NO;
}

-(BOOL) removeEdge: (NSString *)end1 and: (NSString *)end2 {
	NSArray *a = [NSArray arrayWithObjects: end1,end2,nil];
	[edges removeObjectForKey: a];
	return YES;
}

-(id) edgeData: (NSArray *)arr {
	return [edges objectForKey: arr];
}

-(id) edgeData: (NSString *)end1 and: (NSString *)end2 {
	return [self edgeData:[NSArray arrayWithObjects: end1,end2,nil]];
}

-(NSEnumerator *)edgeEnumerator {
	return [[edges allKeys] objectEnumerator];
}

-(id) vertexData: (NSString *)vertex {
	return [verts objectForKey:vertex];
}

//This should maybe actually dump to a file we could feed to graphviz or something...
-(void) dumpToLog {
	id o;
	NSEnumerator *list;
	//vertices
	list = [self vertexEnumerator];
	while ( (o = [list nextObject]) ) {
		NSLog(@"%@ => %@",o,[verts objectForKey:o]);
	}
	//Edges
	list = [self edgeEnumerator];
	while ( (o = [list nextObject]) ) {
		NSLog(@"Edge: %@,%@ => %@",[o objectAtIndex:0],[o objectAtIndex:1],[edges objectForKey: o]);
	}
	return;	
}
@end