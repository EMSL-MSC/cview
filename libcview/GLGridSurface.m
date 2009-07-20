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
#import <gl.h>
#import <glut.h>
#import "cview.h"
#import "DataSet.h"

@implementation  GLGridSurface
-setDataSet: (DataSet *)ds {
	int i,j;
	int index=0;
	int numSurfaceVertices;
	GLuint *indices;

	numSurfaceVertices = (([ds width] - 1) * 2) * [ds height];

	surfaceIndices = [[NSMutableData alloc] initWithLength: numSurfaceVertices*sizeof(GLuint)];
	indices = (GLuint *)[surfaceIndices mutableBytes];
	for(i=0;i<[ds width]-1;i++)
		for(j=0;j<[ds height];j++) {
			indices[index++] = i*[ds height] + j;
			indices[index++] = (i+1)*[ds height] + j;
		}

	return [super setDataSet:ds];
}


-(void)dealloc {
	NSLog(@"GLGridSurface dealloc");
	[surfaceIndices autorelease];
	return [super dealloc];
}

-drawData {
	int i,j;
	int dataIndex=0;
	int vertIndex=0;
	unsigned int stripLength = [surfaceIndices length]/sizeof(GLuint)/([dataSet width]-1);
	NSMutableData *vertsObj = [[NSMutableData alloc] initWithLength: (3*[dataSet height] * [dataSet width])*sizeof(float)];
	float *verts = (float *)[vertsObj mutableBytes];
	NSMutableData *colorObj = [[NSMutableData alloc] initWithLength: (3 * [dataSet height] * [dataSet width]) * sizeof(float)];
	float *color = (float *)[colorObj mutableBytes];
	float *data = [dataSet data];

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glPushMatrix();	
	glScalef(xscale,yscale,zscale);

	[colorMap doMapWithData: data thatHasLength: [dataSet height] * [dataSet width] toColors: color];
	for(i=0;i<[dataSet width];i++) {
		for(j=0;j<[dataSet height];j++) {
			verts[vertIndex++] = (float)i;
			verts[vertIndex++] = data[dataIndex++];
			verts[vertIndex++] = (float)j;
		}
	}
	glVertexPointer(3, GL_FLOAT, 0, verts);
	glColorPointer(3, GL_FLOAT, 0, color);
	
	for(i=0; i < ([dataSet width]-1); i++) {
		glDrawElements(GL_TRIANGLE_STRIP, stripLength, GL_UNSIGNED_INT, [surfaceIndices mutableBytes] + (i * stripLength) * sizeof(int));
	}

	glPopMatrix();
	[vertsObj autorelease];
	[colorObj autorelease];
	return self;
}
@end
