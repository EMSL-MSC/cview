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
#import <gl.h>
#import <glut.h>
#import "GLTooltip.h"
#import <FTGL/ftgl.h>
#import "DictionaryExtra.h"
#import "GLText.h"
//Implemented in utils.m
//void drawString3D(float x,float y,float z,void *font,NSString *string,float offset);
static FTGLfont *theFont=NULL;
static GLText* glText=nil;
NSFileHandle *find_resource(NSString *filename);
NSString *find_resource_path(NSString *filename);
@implementation  GLTooltip
-init {
    [super init];
	self->title = [@"GLTooltip" retain]; // should i retain this?
	self->text = [@"Hello World!\nHow are you today?" retain]; //ditto
	self->title_halign = 0;
	self->x = 100;
	self->y = 0.5;
	self->width = 50;
	self->height = 100;
	self->borderred = 233.0/255.0;
	self->bordergreen = 149.0/255.0;
	self->borderblue = 25.0/255.0;
	self->red = 120.0/255.0;
	self->green = 162.0/255.0;
	self->blue = 46.0/255.0;

    return self;
}
-(void)dealloc {
	NSLog(@"%@ dealloc",[self class]);
	[title autorelease];
	[text autorelease];
	ftglDestroyFont(theFont);
	[super dealloc];
	return;
}
-(NSArray *)attributeKeys {
	//isVisible comes from the DrawableObject
	return [NSArray arrayWithObjects: @"isVisible",
									@"width",
									@"height",
									@"title_height",
									@"title_halign",
									@"max_text_height",
									@"red",
									@"green",
									@"blue",
									nil];
}
-(NSDictionary *)tweaksettings {
	return [NSDictionary dictionaryWithObjectsAndKeys:
		@"min=0 max=1",@"isVisible",
		@"step=1 min=1 max=500",@"width",
		@"step=1 min=1 max=500",@"height",
		@"step=1 min=1 max=500",@"title_height",
		@"help='Title Horizontal Alignment' min=-1 max=1 step=1",@"title_halign",
		@"help='Maximum text size' min=8 max=20 step=1",@"max_text_height",
		@"min=0.0 max=1.0 step=0.001",@"red",
		@"min=0.0 max=1.0 step=0.001",@"green",
		@"min=0.0 max=1.0 step=0.001",@"blue",
		nil];
}
-description {
	return @"Tooltip";
}
-(float)x {return self->x;}
-setX:(float)_x {self->x = _x; return self;}
-(float)y {return self->y;}
-setY:(float)_y {self->y = _y; return self;}
-(NSString*)text {return text;}
-setText:(NSString*)_text {
	[self->text autorelease];
	[_text retain];
	self->text = _text;
	return self;
}
-(NSString*)title {return self->title;}
-setTitle:(NSString*)_title {
	[self->title autorelease];
	[_title retain];
	self->title = _title;
	return self;
}


/*
-(int)title_halign {return self->title_halign;}
-setTitle_halign:(int)_title_halign {self->title_halign = _title_halign; return self;}
*/
-(float)width {return self->width;}
-setWidth:(float)_width {self->width = _width; return self;}
-(int)height {return self->height;}
-setHeight:(int)_height {self->height = _height; return self;}

-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
	[super initWithPList: list];
	/// @todo error checking or exception handling.
    //self->gendersFilePath = [[list objectForKey: @"gendersFilePath" missing: @"data/genders"] retain];
    self->width = [[list objectForKey: @"width" missing: [NSNumber numberWithInt: self->width]] intValue];
	self->height = [[list objectForKey: @"height" missing: [NSNumber numberWithInt: self->height]] intValue];
    self->title_halign = [[list objectForKey: @"title_halign" missing: [NSNumber numberWithInt: self->title_halign]] intValue];
    self->max_text_height = [[list objectForKey: @"max_text_height" missing: [NSNumber numberWithInt: self->max_text_height]] intValue];
    self->red = [[list objectForKey: @"red" missing: [NSNumber numberWithFloat: self->red]] floatValue];
    self->green = [[list objectForKey: @"green" missing: [NSNumber numberWithFloat: self->green]] floatValue];
    self->blue = [[list objectForKey: @"blue" missing: [NSNumber numberWithFloat: self->blue]] floatValue];
    self->borderred = [[list objectForKey: @"borderred" missing: [NSNumber numberWithFloat: self->borderred]] floatValue];
    self->bordergreen = [[list objectForKey: @"bordergreen" missing: [NSNumber numberWithFloat: self->bordergreen]] floatValue];
    self->borderblue = [[list objectForKey: @"borderblue" missing: [NSNumber numberWithFloat: self->borderblue]] floatValue];
    self->fontred = [[list objectForKey: @"fontred" missing: [NSNumber numberWithFloat: self->fontred]] floatValue];
    self->fontgreen = [[list objectForKey: @"fontgreen" missing: [NSNumber numberWithFloat: self->fontgreen]] floatValue];
    self->fontblue = [[list objectForKey: @"fontblue" missing: [NSNumber numberWithFloat: self->fontblue]] floatValue];

        //NSLog(@"gendersFilePath = %@", self->gendersFilePath);
    return self;
}
-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [super getPList]];
	[dict setObject: [NSNumber numberWithInt: self->width] forKey: @"width"];
	[dict setObject: [NSNumber numberWithInt: self->height] forKey: @"height"];
	[dict setObject: [NSNumber numberWithInt: self->title_halign] forKey: @"title_halign"];
	[dict setObject: [NSNumber numberWithInt: self->title_halign] forKey: @"max_text_height"];
	[dict setObject: [NSNumber numberWithFloat: self->red] forKey: @"red"];
	[dict setObject: [NSNumber numberWithFloat: self->green] forKey: @"green"];
	[dict setObject: [NSNumber numberWithFloat: self->blue] forKey: @"blue"];
	[dict setObject: [NSNumber numberWithFloat: self->borderred] forKey: @"borderred"];
	[dict setObject: [NSNumber numberWithFloat: self->bordergreen] forKey: @"bordergreen"];
	[dict setObject: [NSNumber numberWithFloat: self->borderblue] forKey: @"borderblue"];
	[dict setObject: [NSNumber numberWithFloat: self->fontred] forKey: @"fontred"];
	[dict setObject: [NSNumber numberWithFloat: self->fontgreen] forKey: @"fontgreen"];
	[dict setObject: [NSNumber numberWithFloat: self->fontblue] forKey: @"fontblue"];
	return dict;
}

-glDraw {
	//NSLog(@"drawing the tooltip!");
	glTranslatef(self->x,self->y,0);
//	glScalef(100,100,100);
	float bordersize = 10.0;
	// Draw the boarder
	glBegin(GL_POLYGON);
		glColor3f(borderred,bordergreen,borderblue);
		glVertex2f(-.5*self->width-bordersize,-.5*self->height-bordersize);
		glVertex2f(-.5*self->width-bordersize, .5*self->height+bordersize);
		glVertex2f( .5*self->width+bordersize, .5*self->height+bordersize);
		glVertex2f( .5*self->width+bordersize,-.5*self->height-bordersize);
	glEnd();
	// Draw the background
	glBegin(GL_POLYGON);
		glColor3f(red,green,blue);
		glVertex2f(-.5*self->width,-.5*self->height);
		glVertex2f(-.5*self->width, .5*self->height);
		glVertex2f( .5*self->width, .5*self->height);
		glVertex2f( .5*self->width,-.5*self->height);
	glEnd();
	glColor3f(1,1,1);

	if(glText == nil) {
		glText = [[GLText alloc] initWithString: @"" andFont: @"LinLibertine_Re.ttf"];
		[glText setColorRed: self->fontred Green: self->fontgreen Blue: self->fontblue];
	}

	float max_height_scale;
	/*	First, scale (if necessary) and draw the title of the tooltip:
	 *  The scaling is necessary so that the text fits inside of the tooltip window
	 */
	[glText setString: title];
	if([glText width] != 0 && [glText height] != 0) {	// prevent against divide by zero
		max_height_scale = self->max_text_height / [glText height];
		// Check to see if we can use the max_text_height for the size of the title
		if(max_height_scale * [glText width] > self->width) {
			// No, that would cause the font to draw over the end of the window
			max_height_scale = self->width / [glText width];
		}
			//heightRatio = self->height / [glText height];
		//float scale = heightRatio < widthRatio ? .9*heightRatio : .9*widthRatio;
		//float scale = widthRatio;
		glTranslatef(-0.5*self->width,-0.5*self->height,0.0);
		glScalef(max_height_scale,max_height_scale,max_height_scale);
		[glText glDraw];
	}

	/* Now we draw the body of the tooltip, taking special care of newline characters */

	if(self->text != nil) {
		float bounds[6];
		// Start drawing  the text at the upper left part of the box
		glTranslatef(-.5*self->width,-.5*self->height,0);
		//glScalef(10,10,10);
		ftglGetFontBBox(theFont,[text UTF8String],[text length],bounds);
		//printf("bounds[4] = %f\n", bounds[4]);
		glTranslatef(0,bounds[4],0);
//		drawString3D(0,0,0,GLUT_BITMAP_HELVETICA_12,self->text,1.0);

		if (theFont==NULL) {
			theFont = ftglCreateBitmapFont([find_resource_path(@"LinLibertine_Re.ttf") UTF8String]);
			ftglSetFontFaceSize(theFont,14,72);
			ftglSetFontCharMap(theFont,ft_encoding_unicode);
		}
		ftglRenderFont(theFont,[text UTF8String], FTGL_RENDER_ALL);
	}

    return self;
}

@end
