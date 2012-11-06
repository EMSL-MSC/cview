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
/** 
This class implements the gl drawing code to show a graph of lines above a lower base plane, with X and Y labels, with a z-axix tower showing the height of the data.  The data is provided by a DataSet class.  The coloring of the lines is provided by a self-created ColorMap class.

The class can display 4 types of Grid: Lines, Surfaces, Ribbons and Points.
@author Evan Felix <evan.felix@pnl.gov>, (C) 2008
@ingroup cview3d
*/
#import <Foundation/Foundation.h>
#import "DataSet.h"
#import "ColorMap.h"
#import "DrawableObject.h"
#import "GLText.h"
#define MAX_TICKS 10

typedef enum { B_SQUARE=0,B_COUNT } BarTypesEnum;
#define B_SQUARE_STRING @"0"

@interface GLBar: DrawableObject {
	DataSet *dataSet;
	ColorMap *colorMap;
	int axisTicks;
	double currentTicks[MAX_TICKS];
	int numTicks;
	int tickMax;
	double currentMax;
	GLText *descText;
	float fontScale;
	float fontColorR;
	float fontColorG;
	float fontColorB;
	float highlightColorR;	
	float highlightColorG;	
	float highlightColorB;
	float xscale,yscale,zscale;
	float dzmult,rmult;
	BarTypesEnum barType;
	NSRecursiveLock *dataSetLock;
	float baseWidth,baseLength;
	float barWidth,barLength;
	int gridw,gridl;
	NSMutableArray *barText;
	BOOL usersetwidth;
}
-init;
/** Create GLBar with a dataset, using the default Square Drawing method*/ 
-initWithDataSet: (DataSet *)ds;
/** Create GLBar with a dataset, using the given Drawing method*/ 
-initWithDataSet: (DataSet *)ds andType: (BarTypesEnum)type;
/** change the dataSet displayed */
-setDataSet: (DataSet *)ds;
/** get the current dataset */
-(DataSet *)getDataSet;
-(float)getWidth;
-setWidth: (float)w;
-glDraw;
/** draw the overall grid description text */
-drawTitles;
/** draw the z axis tower with appropriate ticks */
-drawAxis;
/** draw the lower plane, with x and y axis ticks */
-drawPlane;
/** set the scaling of the descriptive text */
-setFontScale:(float)scale;
-(float)fontScale;
/**Set the current type of grid to display*/
-(void)setBarType:(BarTypesEnum)code;
/**Returns the current Type of Grid being Displayed*/
-(BarTypesEnum)getBarType;
/** draw the data bars*/
-drawSquares;
@end
