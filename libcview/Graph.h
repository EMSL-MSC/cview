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
#import <Foundation/Foundation.h>
/** A simple graph implementation consiting of a set of Vertices and Edges.
    Each vertex or edge can be associated with a used data object, that will be 
    can be returned during edge traversal.
	@author Evan Felix
	@ingroup cview3d
*/

@interface Graph: NSObject {
	NSMutableDictionary *verts;
	NSMutableSet *edges;
};
-(id) init;
/** Add a vertex to the graph with a NSNull data member*/
-(void) addVertex: (NSString *)name;
/** Add a vertex to the graph with a data parameter, if data is nil, an NSNull object will be put in the data storage area */
-(void) addVertex: (NSString *)name withInfo: (id)data;
/** remove vertex from set if possible.
a vertex cannot be removed while edges exist that refer to it.
Returns TRUE if the vertex was sucessfully removed.*/
-(BOOL) removeVertex: (NSString *)name;
/** return an unordered enumerater for each vertex*/
-(NSEnumerator *)vertexEnumerator;
/** Add an edge. Both Vertices should already exist in the graph
Returns True if successfully added.
the data is associated with the edge,
*/
-(BOOL) addEdge: (NSString *)end1 and: (NSString *)end2 withInfo: (id) data;
/** add an edge with a null data member*/
-(BOOL) addEdge: (NSString *)end1 and: (NSString *)end2;
/** Retrieve User data for a given vertex */
-(id) vertexData: (NSString *)vertex;
/** Remove an edge given the two end points */
-(BOOL) removeEdge: (NSString *)end1 and: (NSString *)end2;
/** Return an enumerator for each edge.  Each object is an Array with (vertex,vertex,data) in it */
-(NSEnumerator *)edgeEnumerator;
/** Dump the graph using NSLog*/
-(void) dumpToLog;
@end

