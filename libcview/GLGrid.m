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
#import "DictionaryExtra.h"

/**
Data layout for reference:
@verbatim
(0,height)                                                            (width,height)
*=========================================================================*
|                                                                         |
|                                                                         |
|                                                                         |
|                                                                         |
*=========================================================================*
(0,0)                                                                 (width,0)
@endverbatim
*/


@implementation  GLGrid
-init {
	[super init];
	currentMax = 0.0;
	xTicks = 0;
	yTicks = 0;
	fontScale = 1.0;
	fontColorR = 1.0;
	fontColorG = 1.0;
	fontColorB = 1.0;
	xscale=1.0;
	yscale=1.0;
	zscale=1.0;
	dzmult=0.0;
	rmult=1.0;
	descText = [[GLText alloc] initWithString: @"Unset" andFont: @"LinLibertine_Re.ttf"];
	return self;
}

-initWithDataSet: (DataSet *)ds {
	[self init];
	[self setDataSet: ds];
	return self;
}

-setDataSet: (DataSet *)ds numRows: (int)num {
	float *d;
	int i,j;
		
	[ds retain];
	[dataSet autorelease];
	dataSet = ds;
	[dataRow autorelease];
	[colorRow autorelease];
	dataRow = [[NSMutableData alloc] initWithLength: num*3*[ds height]*sizeof(float)];
	colorRow = [[NSMutableData alloc] initWithLength: num*3*[ds height]*sizeof(float)];
	d = (float *)[dataRow mutableBytes];
	// setup drawable array... (0,unknown,rownum)
	for (i=0;i<[ds height];i++)
		for (j=0;j<num;j++)
			d[i*(3*num)+2+j*3]=i;
	
	[descText setString: [dataSet getDescription]]; //assume description will not change..

	return self;
}

-setDataSet: (DataSet *)ds {
	return [self setDataSet: ds numRows: 1];
}


-(DataSet *)getDataSet {
	return dataSet;
}

-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
	DataSet *ds;
	[super initWithPList: list];
	/// @todo error checking or exception handling.
	xTicks = [[list objectForKey: @"xTicks"] intValue];
	yTicks = [[list objectForKey: @"yTicks"] intValue];	
	fontScale = [[list objectForKey: @"fontScale" missing: @"1.0"] floatValue];
	fontColorR = [[list objectForKey: @"fontColorR" missing: @"1.0"] floatValue];
	fontColorG = [[list objectForKey: @"fontColorG" missing: @"1.0"] floatValue];
	fontColorB = [[list objectForKey: @"fontColorB" missing: @"1.0"] floatValue];
	xscale = [[list objectForKey: @"xscale" missing: @"1.0"] floatValue];
	yscale = [[list objectForKey: @"yscale" missing: @"1.0"] floatValue];
	zscale = [[list objectForKey: @"zscale" missing: @"1.0"] floatValue];


	Class c;
	c = NSClassFromString([list objectForKey: @"dataSetClass"]);
    NSLog(@"dataSetClass is: %@", c);
	if (c && [c conformsToProtocol: @protocol(PList)] && [c isSubclassOfClass: [DataSet class]]) {
		ds=[c alloc];
		[ds initWithPList: [list objectForKey: @"dataSet"]];
		[self setDataSet: ds];		
	}
	return self;
}
 
-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [super getPList]];
	[dict setObject: [NSNumber numberWithInt: xTicks] forKey: @"xTicks"];	
	[dict setObject: [NSNumber numberWithInt: yTicks] forKey: @"yTicks"];
	[dict setObject: [dataSet getPList] forKey: @"dataSet"];
	[dict setObject: [dataSet class] forKey: @"dataSetClass"];
	[dict setObject: [NSNumber numberWithFloat: fontScale] forKey: @"fontScale"];
	[dict setObject: [NSNumber numberWithFloat: fontColorR] forKey: @"fontColorR"];
	[dict setObject: [NSNumber numberWithFloat: fontColorG] forKey: @"fontColorG"];
	[dict setObject: [NSNumber numberWithFloat: fontColorB] forKey: @"fontColorB"];
	[dict setObject: [NSNumber numberWithFloat: xscale] forKey: @"xscale"];
	[dict setObject: [NSNumber numberWithFloat: yscale] forKey: @"yscale"];
	[dict setObject: [NSNumber numberWithFloat: zscale] forKey: @"zscale"];
	return dict;
}

-(NSArray *)attributeKeys {
	//isVisible comes from the DrawableObject
	return [NSArray arrayWithObjects: @"isVisible",@"xTicks",@"yTicks",@"fontScale",@"xscale",@"yscale",@"zscale",@"dataSet",@"dzmult",@"rmult",@"fontColorR",@"fontColorG",@"fontColorB",@"dataSet",nil];
}

-(NSDictionary *)tweaksettings {
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[NSString stringWithFormat: @"help='Tick separation in the X direction' min=1 max=%d step=1 precision=0",[dataSet width]],@"xTicks",
		[NSString stringWithFormat: @"help='Tick separation in the Y direction' min=1 max=%d step=1 precision=0",[dataSet height]],@"yTicks",
		@"min=0.1 step=0.05",@"xscale",
		@"min=0.1 step=0.05",@"yscale",
		@"min=0.1 step=0.05",@"zscale",
		@"help='scaling of the descriptive font tile' min=0.1 max=4.0 precision=1 step=0.1",@"fontScale",
		@"min=0 max=1",@"isVisible",
		@"step=0.1",@"dxmult",
		@"step=0.1",@"rmult",
		@"min=0.0 step=0.01 max=1.0",@"fontColorR",
		@"min=0.0 step=0.01 max=1.0",@"fontColorG",
		@"min=0.0 step=0.01 max=1.0",@"fontColorB",
		nil];
}

-(void)dealloc {
	NSLog(@"GLGrid dealloc");
	[colorMap autorelease];
	[dataRow autorelease];
	[colorRow autorelease];
	[dataSet autorelease];
	return [super dealloc];
}

-glDraw {
	float max = [dataSet getScaledMax];
	
	if (currentMax != max) {
		NSLog(@"New Max: %.2f %.2f",max,currentMax);
		currentMax = max;
		[colorMap autorelease];
		colorMap = [ColorMap mapWithMax: currentMax];
		[colorMap retain];
	}

	glScalef(1.0,1.0,1.0); 
	
	[self drawPlane];
	[self drawData];
	[self drawAxis];
	[self drawTitles];
	
	return self;
}

-drawTitles {
	glPushMatrix();
	glScalef(1.0,1.0,zscale); 
	glTranslatef(0.0,0,[dataSet height]+15+15*fontScale);
	glRotatef(90,1.0,0.0,0.0);
	
	glScalef(fontScale,fontScale,fontScale/zscale);

	[descText setColorRed: fontColorR Green: fontColorG Blue: fontColorB];
	[descText glDraw];

	glPopMatrix();
	return self;
}

-drawAxis {
	int i;
	float bsize=0.25/xscale;
	float x,y;

	x=[dataSet width];
	y=0.0;

	glPushMatrix();
	glScalef(xscale,yscale,zscale); 	

	glBegin(GL_LINES);
	for (i=1;i<currentMax+1;i++) {
		[colorMap glMap: i];
		//glColor3f(1.0,1.0,1.0);
		glVertex3f(x,i-1.0,y);
		glVertex3f(x,i,y);
	}
	glEnd();
	
	glColor3f(fontColorR,fontColorG,fontColorB);
	glBegin(GL_QUADS);
	for (i=0;i<currentMax+1;i+=(int)MAX(4,currentMax/5)) {
		glVertex3f(x-bsize,i,y-bsize);
		glVertex3f(x-bsize,i,y+bsize);
		glVertex3f(x+bsize,i,y+bsize);
		glVertex3f(x+bsize,i,y-bsize);
	}
	glEnd();

	for (i=0;i<currentMax+1;i+=(int)MAX(4,currentMax/5))
		drawString3D(x+4.0/xscale,i,y,GLUT_BITMAP_HELVETICA_12,[dataSet getLabel: i],1.0);

	glPopMatrix();
	return self;
}

-drawPlane {
	float dropit=-1.5;
	int i;

	glColor3f(0.5,0.0,0.0);
	
	glPolygonOffset(dzmult,rmult);
	glPushMatrix();
	glScalef(xscale,yscale,zscale);
	glBegin(GL_QUADS);

	//glNormal3f(0.0, -1.0, 0.0);
	glVertex3f(0, dropit, 0 );
	glVertex3f(0, dropit, [dataSet height] );
	glVertex3f([dataSet width], dropit, [dataSet height] );
	glVertex3f([dataSet width], dropit, 0 );
	
	glEnd();

	glColor3f(fontColorR,fontColorG,fontColorB);
	if (yTicks) {
		int p = [dataSet width];
		glBegin(GL_LINES);
		for (i = 0;i < [dataSet height];i += yTicks) {
			glVertex3f(p,0.0,i);
			glVertex3f(p+2.0/xscale,0,i);
		}
		glEnd();
		for (i = 0;i < [dataSet height];i += yTicks) {
			NSString *str = [dataSet rowTick: i];
			drawString3D(p+2.5/xscale,0,i,GLUT_BITMAP_HELVETICA_12,str,0);
		}
	}
	if (xTicks) {
		int p = [dataSet height];
		glBegin(GL_LINES);
		for (i = 0;i < [dataSet width]; i += xTicks) {
			glVertex3f(i,dropit,p);
			glVertex3f(i,dropit,p+2.0/zscale);
		}
		glEnd();
		for (i = 0;i < [dataSet width]; i += xTicks) {
			NSString *str = [dataSet columnTick: i];
			drawString3D(i,dropit,p+12/zscale,GLUT_BITMAP_HELVETICA_12,str,0);
		}
	}
	glPopMatrix();
	return self;
}

-drawData {
	int i,j;
	float *dl;
	float *verts;
	int prevPoint=0;
	float prevValue;
	int countPoints;
	verts = [dataRow mutableBytes];

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glPushMatrix();	
	glScalef(xscale,yscale,zscale);

	glVertexPointer(3, GL_FLOAT, 0, verts);
	glColorPointer(3, GL_FLOAT, 0, [colorRow mutableBytes]);

	for (i=0;i<[dataSet width];i++) {
		dl=[dataSet dataRow: i];

		/// @todo is there a gooder way to draw all the lines?
		verts[2] = 0;
		verts[1] = prevValue = dl[0];
		verts[0] = (float)i;
		countPoints = 1;
		prevPoint=0;
		for (j=1;j<[dataSet height];j++) {
			if(prevValue != dl[j]) {
				if(j-1 != prevPoint) {
					verts[countPoints*3+2] = (float)j-1;
					verts[countPoints*3+1] = prevValue;
					verts[countPoints*3+0] = (float)i;
					countPoints++;
				}
				verts[countPoints*3+2] = (float)j;
				verts[countPoints*3+1] = dl[j];
				verts[countPoints*3+0] = (float)i;
				countPoints++;
				prevValue = dl[j];
				prevPoint = j;
			}
		}	
		if(j-1 != prevPoint) {
			verts[countPoints*3+2] = (float)j-1;
			verts[countPoints*3+1] = dl[j-1];
			verts[countPoints*3+0] = (float)i;
			countPoints++;
		}

		[colorMap doMapWithPoints: verts thatHasLength: countPoints toColors: [colorRow mutableBytes]];
		
		glDrawArrays(GL_LINE_STRIP,0,countPoints);
	}

	glPopMatrix();
	return self;
}

-setXTicks: (int) delta {
	xTicks = delta;
	return self;
}
-setYTicks: (int) delta {
	yTicks = delta;
	return self;
}
-(int)xTicks {
	return xTicks;
}
-(int)yTicks {
	return yTicks;
}
-setFontScale:(float)scale {
	fontScale=scale;
	return self;
}
-(float)fontScale {
	return fontScale;
}

-description {
	return [[self class] description];
}

-(NSString*)getName {
	NSString *retval = [super getName];
	if(!name)
		retval = [dataSet description];
	return retval;
}

@end
