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
#include <math.h>
#import <Foundation/Foundation.h>
#import <gl.h>
#import <glut.h>
#import "cview.h"
#import "DataSet.h"
#import "DictionaryExtra.h"
#import "ValueStore.h"
#import "Defaults.h"

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
static NSArray *gridTypeStrings=nil;
static const char *gridTypeSelectors[] =	{
	"drawLines",
	"drawRibbons",
	"drawSurface",
	"drawPoints"
}
;
+(void)initialize {
	gridTypeStrings = [NSArray arrayWithObjects: @"Lines",@"Ribbons",@"Surface",@"Points",nil];
	return;
}
-init {
	[super init];
	// This lock protects the changing of the dataset.
	dataSetLock = [[NSRecursiveLock alloc] init];
	fontScale = 1.0;
	fontColorR = 1.0;
	fontColorG = 1.0;
	fontColorB = 1.0;
	xscale=1.0;
	yscale=1.0;
	zscale=1.0;
	dzmult=0.0;
	rmult=0.25;
	xTicks=[Defaults integerForKey:@"xTicks" Id:self];
	yTicks=[Defaults integerForKey:@"yTicks" Id:self];
	xTickDistance = [Defaults integerForKey: @"xTickDistance" Id: self];
	yTickDistance = [Defaults integerForKey: @"yTickDistance" Id: self];
	axisTicks=6;
	tickMax=1.0;
	currentTicks[0]=0.0;
	currentTicks[1]=1.0;
	numTicks=2;
	surfaceIndices=nil;
	gridType=G_LINES;
	descText = [[GLText alloc] initWithString: @"Unset" andFont: @"LinLibertine_Re.ttf"];
	return self;
}

-initWithDataSetKey: (NSString *)key andType: (GridTypesEnum)type{
  [self init];
  [self setGridType:type];
  [self setDataSet: [[ValueStore valueStore] getObject: key]];
  return self;
}

-initWithDataSetKey: (NSString *)key {
  [self init];
  [self setDataSet: [[ValueStore valueStore] getObject: key]];
  return self;
}

-initWithDataSet: (DataSet *)ds andType: (GridTypesEnum)type{
	[self init];
	[self setGridType:type];
	[self setDataSet: ds];
	return self;
}

-initWithDataSet: (DataSet *)ds {
	[self init];
	[self setDataSet: ds];
	return self;
}

-setDataSet: (DataSet *)ds {
	[dataSetLock lock];
	[ds retain];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DataSetResize" object: nil];
	[dataSet autorelease];
	dataSet = ds;
	NSLog(@"register notify for: %@ %@",self,dataSet);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveResizeNotification:) name:@"DataSetResize" object:dataSet];
	[self resetDrawingArrays];
	[dataSetLock unlock];

	return self;

}
-(void)receiveResizeNotification: (NSNotification *)notification {
	NSLog(@"GLGridResize notification: %@",notification);
	[self resetDrawingArrays];
}

-(void)resetDrawingArrays {
	float *d;
	int num=1;
	int i,j,w,h;
	int index=0;
	int numSurfaceVertices;
	GLuint *indices;

	[dataSetLock lock];
	[descText setString: [dataSet getDescription]];
	w=[dataSet width];
	h=[dataSet height];
	currentWidth = w;
	currentHeight = h;

	[dataRow autorelease];
	[colorRow autorelease];
	if (gridType == G_RIBBON)
		num++;
	dataRow = [[NSMutableData alloc] initWithLength: num*3*h*sizeof(float)];
	NSLog(@"reset %@ dataRow: %lu",dataSet,num*3*h*sizeof(float));
	colorRow = [[NSMutableData alloc] initWithLength: num*4*h*sizeof(float)];
	d = (float *)[dataRow mutableBytes];
	// setup drawable array... (0,unknown,rownum)
	for (i=0;i<h;i++)
		for (j=0;j<num;j++)
			d[i*(3*num)+2+j*3]=i;


	if (gridType == G_SURFACE) {
		numSurfaceVertices = ((w - 1) * 2) * h;

		surfaceIndices = [[NSMutableData alloc] initWithLength: numSurfaceVertices*sizeof(GLuint)];
		indices = (GLuint *)[surfaceIndices mutableBytes];
		for(i=0;i<w-1;i++)
			for(j=0;j<h;j++) {
				indices[index++] = i*h + j;
				indices[index++] = (i+1)*h + j;
			}
	}
	[dataSetLock unlock];

	return;
}

-(DataSet *)getDataSet {
	return dataSet;
}

-initWithPList: (id)list {
	id o;
	NSLog(@"initWithPList: %@",[self class]);
	DataSet *ds;
	NSString *key;
	[super initWithPList: list];
	/// @todo error checking or exception handling.
	xTicks = [Defaults integerForKey: @"xTicks" Id: self Override: list];
	yTicks = [Defaults integerForKey: @"yTicks" Id: self Override:list];
	fontScale = [Defaults floatForKey: @"fontScale" Id: self Override: list];
	fontColorR = [Defaults floatForKey: @"fontColorR" Id: self Override: list];
	fontColorG = [Defaults floatForKey: @"fontColorG" Id: self Override: list];
	fontColorB = [Defaults floatForKey: @"fontColorB" Id: self Override: list];
	xscale = [Defaults floatForKey: @"xscale" Id: self Override: list];
	yscale = [Defaults floatForKey: @"yscale" Id: self Override: list];
	zscale = [Defaults floatForKey: @"zscale" Id: self Override: list];
	gridType = [Defaults integerForKey: @"gridType" Id: self Override:list];
		
	o = [list objectForKey: @"gradient" missing: nil];
	if (o!=nil)
		ggr = [[GimpGradient alloc] initWithPList: o];

	key = [list objectForKey: @"valueStoreDataSetKey"];
	if (key) {
		//New Method using DataStore
		ds=[[ValueStore valueStore] getObject: key];
		NSLog(@"DataSet from ValueStore: %@",ds);
		[self setDataSet: ds];
	}
	else {
		//Deprecated Method.. with upgrade code
		Class c;
		c = NSClassFromString([list objectForKey: @"dataSetClass"]);
		NSLog(@"dataSetClass is: %@ == %@", [c className],[list objectForKey: @"dataSetClass"]);
		if (c && [c conformsToProtocol: @protocol(PList)] && [c isSubclassOfClass: [DataSet class]]) {
			ds=[[c alloc] initWithPList: [list objectForKey: @"dataSet"]];

			if ([(NSString *)[list objectForKey: @"dataSetClass"] compare: @"ValueStoreDataSet"]==NSOrderedSame) {
				key = [[list objectForKey: @"dataSet"] objectForKey:@"key"];
				[ds autorelease];
				ds = [[ValueStore valueStore] getObject:key];
			}
			else {
				//Add it to the value store
				key = [NSString stringWithFormat:@"AutoName-%p",ds];
				[[ValueStore valueStore] setKey: key withObject: ds];
			}
			[self setDataSet: ds];
		}
	}
	return self;
}


-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [super getPList]];
	PLIST_SET_IF_NOT_DEFAULT_INT(dict, xTicks);
	PLIST_SET_IF_NOT_DEFAULT_INT(dict, yTicks);
	PLIST_SET_IF_NOT_DEFAULT_FLT(dict, fontScale);
	PLIST_SET_IF_NOT_DEFAULT_FLT(dict, fontColorR);
	PLIST_SET_IF_NOT_DEFAULT_FLT(dict, fontColorG);
	PLIST_SET_IF_NOT_DEFAULT_FLT(dict, fontColorB);
	PLIST_SET_IF_NOT_DEFAULT_FLT(dict, xscale);
	PLIST_SET_IF_NOT_DEFAULT_FLT(dict, yscale);
	PLIST_SET_IF_NOT_DEFAULT_FLT(dict, zscale);
	PLIST_SET_IF_NOT_DEFAULT_INT(dict, gridType);

	[dict setObject: [[ValueStore valueStore] getKeyForObject:dataSet] forKey: @"valueStoreDataSetKey"];

	if (ggr != nil)
		[dict setObject: [ggr getPList] forKey: @"gradient"];
	return dict;
}

-(NSArray *)attributeKeys {
	//isVisible comes from the DrawableObject
	return [NSArray arrayWithObjects: @"isVisible",@"xTicks",@"yTicks",@"fontScale",@"xscale",@"yscale",@"zscale",
									@"dzmult",@"rmult",@"fontColorR",@"fontColorG",@"fontColorB",@"gridType",@"dataSet",@"axisTicks",nil];
}

-(NSDictionary *)tweaksettings {
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[NSString stringWithFormat: @"help='Tick separation in the X direction' min=0 max=%d step=1 precision=0",[dataSet width]],@"xTicks",
		[NSString stringWithFormat: @"help='Tick separation in the Y direction' min=0 max=%d step=1 precision=0",[dataSet height]],@"yTicks",
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
		@"min=0 max=3",@"gridType",
		[NSString stringWithFormat: @"min=2 max=%d",MAX_TICKS],@"axisTicks",
		nil];
}

-(void)dealloc {
	NSLog(@"GLGrid dealloc");
	[dataSetLock lock];
	[colorMap autorelease];
	[dataRow autorelease];
	[colorRow autorelease];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[dataSet autorelease];
	[dataSetLock autorelease];
	[ggr autorelease];
	return [super dealloc];
}

/* This should be called with the dataSet Locked */
-resetColorMap {
	[colorMap autorelease];
	if (ggr == nil)
		colorMap = [ColorMap mapWithMax: tickMax];
	else
		colorMap = [ColorMap mapWithGradient: ggr andMax: tickMax];
	[colorMap retain];
	return self;
}

-glDraw {
	[dataSet lock];
	unsigned long max = round([dataSet getMax]);
	max = max<5?5:max;	

	if (currentMax != max || currentMax==0) {
		NSLog(@"New Max: %lu %lu",max,currentMax);
		currentMax = max;
		numTicks = niceticks(0,currentMax,currentTicks,axisTicks);
		tickMax = round(currentTicks[numTicks-1]);
		
		[self resetColorMap];
	}
	
	glScalef(1.0,1.0,1.0);

	[dataSetLock lock];
	if (currentHeight != [dataSet height] || currentWidth != [dataSet width]) {
		NSLog(@"WARNING: Size mismatch since last time - This should not happen if DataSet Notifications are working on resizes. Attempting to handle cleanly.");
		[self resetDrawingArrays];
	}
	[self drawPlane];
	[self performSelector: sel_registerName(gridTypeSelectors[gridType]) ];
	[self drawAxis];
	[self drawTitles];
	[dataSetLock unlock];
	[dataSet unlock];
	return self;
}

-drawTitles {
	glPushMatrix();
	glScalef(1.0,1.0,zscale);
	glTranslatef(0.0,0,[dataSet height]+xTickDistance+15+15*fontScale);
	glRotatef(90,1.0,0.0,0.0);

	glScalef(fontScale,fontScale,fontScale/zscale);

	[descText setColorRed: fontColorR Green: fontColorG Blue: fontColorB];
	[descText glDraw];

	glPopMatrix();
	return self;
}

-drawAxis {
	int i;
	float bsize=0.5/xscale;
	float j,step,x,y;

	x=[dataSet width];
	y=0.0;

	glPushMatrix();
	glScalef(xscale,yscale*100.0/tickMax,zscale);

	glBegin(GL_LINES);
	step=currentMax/100.0;
	for (j=step;j<=tickMax;j+=step) {
		[colorMap glMap: j];
		//glColor3f(1.0,1.0,1.0);
		glVertex3f(x,j-step,y);
		glVertex3f(x,j,y);
	}
	glEnd();

	glColor3f(fontColorR,fontColorG,fontColorB);
	glBegin(GL_QUADS);
	for (i=0;i<numTicks;i++) {
		glVertex3f(x-bsize,currentTicks[i],y-bsize);
		glVertex3f(x-bsize,currentTicks[i],y+bsize);
		glVertex3f(x+bsize,currentTicks[i],y+bsize);
		glVertex3f(x+bsize,currentTicks[i],y-bsize);
	}
	glEnd();

	glColor3f(fontColorR,fontColorG,fontColorB);
	for (i=0;i<numTicks;i++) 
		drawString3D(x+4.0/xscale,currentTicks[i],y,GLUT_BITMAP_HELVETICA_12,[dataSet getLabel: currentTicks[i]],0.0);

	glPopMatrix();
	return self;
}

-drawPlane {
	float dropit=-1.5;
	int i,w,h;
	w=[dataSet width];
	h=[dataSet height];

	glColor3f(0.5,0.0,0.0);

	glPolygonOffset(dzmult,rmult);
	glPushMatrix();
	glScalef(xscale,yscale,zscale);
	glBegin(GL_QUADS);

	//glNormal3f(0.0, -1.0, 0.0);
	glVertex3f(0, dropit, 0 );
	glVertex3f(0, dropit, h );
	glVertex3f(w, dropit, h );
	glVertex3f(w, dropit, 0 );

	glEnd();

	glColor3f(fontColorR,fontColorG,fontColorB);
	if (yTicks) {
		int p = w;
		glBegin(GL_LINES);
		for (i = 0;i < h;i += yTicks) {
			glVertex3f(p,0.0,i);
			glVertex3f(p+2.0/xscale,0,i);
		}
		glEnd();
		for (i = 0;i < h;i += yTicks) {
			NSString *str = [dataSet rowTick: i];
			drawString3D(p+yTickDistance+2.5/xscale,0,i,GLUT_BITMAP_HELVETICA_12,str,0);
		}
	}
	if (xTicks) {
		int p = h;
		glBegin(GL_LINES);
		for (i = 0;i < w; i += xTicks) {
			glVertex3f(i,dropit,p);
			glVertex3f(i,dropit,p+2.0/zscale);
		}
		glEnd();
		for (i = 0;i < w; i += xTicks) {
			NSString *str = [dataSet columnTick: i];
			drawString3D(i,dropit,p+xTickDistance+12/zscale,GLUT_BITMAP_HELVETICA_12,str,0);
		}
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


-(void)setGridType:(GridTypesEnum)code {
	if (code < G_COUNT)
		gridType = code;
	/**@todo actualy switch drawing*/
	[self resetDrawingArrays];
}

-(GridTypesEnum)getGridType {
	return gridType;
}


-setGradient: (GimpGradient *)gradient {
	[gradient retain];
	[ggr autorelease];
	ggr = gradient;
	//dont change while it may be in use.
	[dataSet lock];
	[self resetColorMap];
	[dataSet unlock];
	return self;
}

-getGradient {
	return ggr;
}

-drawLines {
	int i,j;
	int w,h;
	float *dl;
	float *verts;
	int prevPoint=0;
	float prevValue;
	int countPoints;
	verts = [dataRow mutableBytes];

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glPushMatrix();
	glScalef(xscale,yscale*100.0/tickMax,zscale);

	glVertexPointer(3, GL_FLOAT, 0, verts);
	glColorPointer(4, GL_FLOAT, 0, [colorRow mutableBytes]);

	w=[dataSet width];
	h=[dataSet height];

	for (i=0;i<w;i++) {
		dl=[dataSet dataRow: i];

		/// @todo is there a gooder way to draw all the lines?
		verts[2] = 0;
		verts[1] = prevValue = MAX(0,dl[0]);
		verts[0] = (float)i;
		countPoints = 1;
		prevPoint=0;
		for (j=1;j<h;j++) { 
			if(prevValue != dl[j]) {
				if(j-1 != prevPoint) {
					verts[countPoints*3+2] = (float)j-1;
					verts[countPoints*3+1] = prevValue;
					verts[countPoints*3+0] = (float)i;
					countPoints++;
				}
				verts[countPoints*3+2] = (float)j;
				verts[countPoints*3+1] = MAX(0,dl[j]);
				verts[countPoints*3+0] = (float)i;
				countPoints++;
				prevValue = dl[j];
				prevPoint = j;
			}
		}
		if(j-1 != prevPoint) {
			verts[countPoints*3+2] = (float)j-1;
			verts[countPoints*3+1] = MAX(0,dl[j-1]);
			verts[countPoints*3+0] = (float)i;
			countPoints++;
		}
		
		[colorMap doMapWithPoints: verts thatHasLength: countPoints toColors: [colorRow mutableBytes]];

		glDrawArrays(GL_LINE_STRIP,0,countPoints);
	}

	glPopMatrix();
	return self;
}

-(void)regenerateIndicies {
		return;
}

-drawSurface {
	int i,j,w,h;
	int dataIndex=0;
	int vertIndex=0;
	w=[dataSet width];
	h=[dataSet height];

	unsigned int stripLength = [surfaceIndices length]/sizeof(GLuint)/(w-1);
	NSMutableData *vertsObj = [[NSMutableData alloc] initWithLength: (3*h * w)*sizeof(float)];
	float *verts = (float *)[vertsObj mutableBytes];
	NSMutableData *colorObj = [[NSMutableData alloc] initWithLength: (4 * h * w) * sizeof(float)];
	float *color = (float *)[colorObj mutableBytes];
	float *data = [dataSet data];

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glPushMatrix();
	glScalef(xscale,yscale*100.0/tickMax,zscale);

	[colorMap doMapWithData: data thatHasLength: h * w toColors: color];
	for(i=0;i<w;i++) {
		for(j=0;j<h;j++) {
			verts[vertIndex++] = (float)i;
			verts[vertIndex++] = data[dataIndex++];
			verts[vertIndex++] = (float)j;
		}
	}
	glVertexPointer(3, GL_FLOAT, 0, verts);
	glColorPointer(4, GL_FLOAT, 0, color);

	for(i=0; i < (w-1); i++) {
		glDrawElements(GL_TRIANGLE_STRIP, stripLength, GL_UNSIGNED_INT, [surfaceIndices mutableBytes] + (i * stripLength) * sizeof(int));
	}

	glPopMatrix();
	[vertsObj autorelease];
	[colorObj autorelease];
	return self;
}

-drawPoints {
	int i,j,w,h;
	float *dl;
	float *verts;
	verts = [dataRow mutableBytes];
	w=[dataSet width];
	h=[dataSet height];

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glPushMatrix();
	glScalef(xscale,yscale*100.0/tickMax,zscale);

	glVertexPointer(3, GL_FLOAT, 0, verts);
	glColorPointer(4, GL_FLOAT, 0, [colorRow mutableBytes]);

	//Bigger points up close stuff
	glPointSize(150);
#if HAVE_OPENGL_1_4
	float glparm[3];

	glparm[0]=0;
	glPointParameterfv(GL_POINT_SIZE_MIN,glparm);
	glparm[0]=20.0;
	glPointParameterfv(GL_POINT_SIZE_MAX,glparm);
	glparm[0]=0.0;
	glparm[1]=-0.01;
	glparm[2]=0.025;
	glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION, glparm);
#endif
	//end bigger stuff..

	for (i=0;i<w;i++) {
		dl=[dataSet dataRow: i];


		[colorMap doMapWithData: dl thatHasLength: h toColors: [colorRow mutableBytes]];
		//is there a gooder way? FIXME
		for (j=0;j<h;j++) {
			verts[j*3+1] = dl[j];
			verts[j*3+0] = (float)i;
		}
		glDrawArrays(GL_POINTS,0,h);
	}

	glPopMatrix();
	return self;
}

-drawRibbons {
	int i,j,w,h;
	float *dl,*newdl;
	float *verts;
	w=[dataSet width];
	h=[dataSet height];

	NSMutableData *temp = [[NSMutableData alloc] initWithLength: h*2*sizeof(float)];
	verts = [dataRow mutableBytes];


	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glPushMatrix();
	glScalef(xscale,yscale*100.0/tickMax,zscale);

	glVertexPointer(3, GL_FLOAT, 0, verts);
	glColorPointer(4, GL_FLOAT, 0, [colorRow mutableBytes]);
	glColor3f(1.0,1.0,0.0);

	for (i=0;i<w;i++) {
		dl=[dataSet dataRow: i];
		newdl = (float *)[temp mutableBytes];

		for (j=0;j<[dataSet height];j++) {
			newdl[j*2+0]=dl[j];
			newdl[j*2+1]=dl[j];
		}

		[colorMap doMapWithData: newdl
			thatHasLength: h*2
			toColors: [colorRow mutableBytes]];
		//is there a gooder way? FIXME
		for (j=0;j<h;j++) {
			verts[j*6+1] = dl[j];
			verts[j*6+0] = (float)i;
			verts[j*6+4] = dl[j];
			verts[j*6+3] = (float)i+1.0;
		}
		glDrawArrays(GL_QUAD_STRIP,0,h*2);
	}

	glPopMatrix();
	[temp autorelease];
	return self;
}
@end
