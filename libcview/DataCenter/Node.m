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

#import "Node.h"
#import <Foundation/NSString.h>
#import <gl.h>
#import <glut.h>
//#import "AisleOffsets.h"
#import "../../libcview-data/WebDataSet.h"
@implementation Node
//static VertArray *nodeArray;
static WebDataSet *dataSet;
static GLText *gltName;
static ColorMap *colorMap;
static double currentMax = 0.0;

+(void)setWebDataSet:(WebDataSet*)_dataSet {
    dataSet = [_dataSet retain];
}
+setGLTName:(GLText*) _gltName {
    gltName = _gltName;
    return self;
}
-cleanUp {
    // maybe add stuff here later

    [self autorelease];
    return self;
}
-init {
    [super init];
    self->drawname = YES;
    self->fading = NO;
    self->unfading = NO;
    self->selected = NO;
    self->fadetime = 2.5;    // in seconds
    self->fadestart = 0;
    self->fadeval = 1;  // default to full opacity
    return self;
 }
-initWithName:(NSString*)_name {
    [self init];
    [self setName: _name];
    return self;
}
-(void)dealloc {
    if(dataSet != nil)
        [dataSet release];
    return [super dealloc];
}
-startFading {
    fading = YES;
    unfading = NO;
    return self;
}
-startUnFading {
    //NSLog(@"called UNFADING, node: %@", [self getName]);
    unfading = YES;
    fading = NO;
    return self;
}
-(float)getData: (NSString*)nodeName {
    // First find the nodename in the xticks array
    //DataSet *ds = [myDCG getDataSet];
    float *row = [dataSet dataRowByString: [nodeName uppercaseString]];
    if(row != NULL) {
        //NSLog(@"row[0] = %f", row[0]);
        return row[0];
    }else {
        //NSLog(@"[Node getData] called [dataSet dataRowByString] and got a zero pointer!");
        return -1;
    }
}
-draw {
//    NSLog(@"node=%@ width=%f height=%f depth=%f",[self name],[self width],[self height],[self depth]);
    double thetime = [[NSDate date] timeIntervalSince1970]; // get current time in seconds
    if(fading == YES || unfading == YES) { // check to see if we should fade/unfade
        double scale = 0.0; // must be between 0 and 1, inclusive
        if(wasfading == NO) {
            fadestart = thetime;    //we just started fading
            wasfading = YES;
            if( (fading == YES && fadeval == scale) ||
                (unfading == YES && fadeval == 1.0) )
                thetime = fadetime + fadestart + 1.0; // push it over the top
        }
        if(thetime - fadestart > fadetime) {    // time to stop fading
            if(fading == YES)
                fadeval = scale;
            else if(unfading == YES)
                fadeval = 1.0;
            fading = NO;
            unfading = NO;
            wasfading = NO;
            //NSLog(@"ENDED FADING!!!!");
        }else{  // we're still fading
            fadeval = (1/fadetime)*(thetime-fadestart); // calculate the fade
            if(fading == YES) 
                fadeval = 1-fadeval;    // fading out, not in
            fadeval = scale+(1-scale)*fadeval;
        }
        glutPostRedisplay();    // Tell glut to draw again - we're still fading
    }
    if(selected == YES || fadeval != 0) {  // only draw this node if we're not completely faded out or selected
        [super setupForDraw];
            [self setTemperature: [self getData: [self name]]];
            if(self->temperature != -1)
                self->temperature /=  100.0;
            glEnable(GL_BLEND);
            float max = [dataSet getScaledMax];
            if (currentMax != max) {
//                NSLog(@"New Max: %.2f %.2f",max,currentMax);
                currentMax = max;
                [colorMap autorelease];
                colorMap = [ColorMap mapWithMax: currentMax];
                [colorMap retain];
            }
            if(selected == YES)
                glColor4f(.1,.1,.1,1);
            else if(temperature == -1) { // No valid data found from the dataSet    
                glColor4f(1,1,1,fadeval);// color the node white
        //        NSLog(@"bad data from %@", [self name]);
            }else
                glColor4f([colorMap r: temperature],[colorMap g: temperature], [colorMap b: temperature], fadeval);
            [super drawBox];    // draw a box around the node

            if(drawname == YES) {
                if(gltName == nil) {
                    gltName = [[GLText alloc] initWithString: [self name] andFont: @"LinLibertine_Re.ttf"];
                    [gltName setColorRed: 0 Green: 0 Blue: 0];
                }
                [gltName setString: [[self name] lowercaseString]];
                if([gltName width] != 0 && [gltName height] != 0) { // test for divide by zero
                    // Here we want to scale the font such that it fits inside the area on the front of the node
                    float heightRatio = [self height] / [gltName height];
                    float widthRatio = [self width] / [gltName width];
                    float scale = heightRatio < widthRatio ? .9*heightRatio : .9*widthRatio;
                    if(isodd == YES)  // every other node, change name locations (left or right aligned)
                        glTranslatef(.48*[self width],.5*[self height],-.51*[self depth]);
                    else
                        glTranslatef(-.48*[self width]+scale*[gltName width],.5*[self height],-.51*[self depth]);
                    glScalef(scale,-scale,scale);
                    glRotatef(180,0,0,1);
                    glRotatef(180,1,0,0);
                    [gltName glDraw];   // Draw the node name
                }
            }
        [super cleanUpAfterDraw];
    }
    return self;
}
-glPickDraw {
    [super setupForDraw];
        [super glPickDraw];
    [super cleanUpAfterDraw];
    return self;
}
-setTemperature: (float) _temperature {
    self->temperature = _temperature;
    return self;
}
-(float)getTemperature {
    return self->temperature;
}
-setIsodd: (BOOL)_isodd {
    isodd = _isodd;
    return self;
}
-setSelected:(BOOL)_selected {
    self->selected = _selected; 
//    NSLog(@"selection is %d", _selected);
    glutPostRedisplay();
    return self;
}
@end
