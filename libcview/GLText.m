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
#include <gl.h>
#include <glut.h>
#import "cview.h"
#import "DictionaryExtra.h"

	
@implementation GLText
static NSMutableDictionary *fontCache=nil;
+(void)initialize {
	fontCache = [[NSMutableDictionary dictionaryWithCapacity: 5] retain];
	return;
}
- initWithString: (NSString *)str andFont: (NSString *)font {
	int i;
	[super init];
	NSString *tmpFont = find_resource_path(font);
	[self setFont: tmpFont];
	string = [str retain];
	for (i=0;i<3;i++) {
		color[i]=1.0;
		scale[i]=1.0;
		rotates[i]=0.0;
	}
	return self;
}

-(void)dealloc {
	NSLog(@"%@ dealloc",[self class]);
	[string autorelease];
	ftglDestroyFont(theFont);
	[fontResource autorelease];
	[super dealloc];
	return;
}

-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
	[super initWithPList: list];
	///@todo use a resource
	NSString *font_res = [list objectForKey: @"fontfile" missing: @"LinLibertine_Re.ttf"];

	NSString *s = [list objectForKey: @"string" missing: @"FIXME"];
	[self initWithString: s andFont: font_res];

	#define GD(x,k,m) x=[[list objectForKey: k missing: m] floatValue]
	GD(color[0],@"colorR",@"1.0");
	GD(color[1],@"colorG",@"1.0");
	GD(color[2],@"colorB",@"1.0");
	GD(scale[0],@"scaleX",@"1.0");
	GD(scale[1],@"scaleY",@"1.0");
	GD(scale[2],@"scaleZ",@"1.0");
	GD(rotates[0],@"rotX",@"0.0");
	GD(rotates[1],@"rotY",@"0.0");
	GD(rotates[2],@"rotZ",@"0.0");
	#undef GD

	return self;
}
 
-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [super getPList]];
	[dict setObject: fontResource forKey: @"fontfile"];
	[dict setObject: string forKey: @"string"];

	#define SD(x,k) [dict setObject: [NSNumber numberWithFloat: x] forKey: k];
	SD(color[0],@"colorR");
	SD(color[1],@"colorG");
	SD(color[2],@"colorB");
	SD(scale[0],@"scaleX");
	SD(scale[1],@"scaleY");
	SD(scale[2],@"scaleZ");
	SD(rotates[0],@"rotX");
	SD(rotates[1],@"rotY");
	SD(rotates[2],@"rotZ");
	#undef SD

	return dict;
}

-(NSArray *)attributeKeys {
	//isVisible comes from the DrawableObject
	return [NSArray arrayWithObjects: @"isVisible",
									@"colorRed",@"colorGreen",@"colorBlue",
									//@"scaleX",@"scaleY",@"scaleZ",
									//@"rotX",@"rotY",@"rotZ",
									nil];
}

-(NSDictionary *)tweaksettings {
	return [NSDictionary dictionaryWithObjectsAndKeys:
		@"min=0.1 step=0.05",@"scaleX",
		@"min=0.1 step=0.05",@"scaleY",
		@"min=0.1 step=0.05",@"scaleZ",
		@"min=0 max=1",@"isVisible",
		@"min=0.0 step=0.01 max=1.0",@"colorRed",
		@"min=0.0 step=0.01 max=1.0",@"colorGreen",
		@"min=0.0 step=0.01 max=1.0",@"colorBlue",	
		@"min=-3.14159 max=3.14159 step=0.01745 precision=5",@"rotX",
		@"min=-3.14159 max=3.14159 step=0.01745 precision=5",@"rotY",
		@"min=-3.14159 max=3.14159 step=0.01745 precision=5",@"rotZ",
		nil];
}

- setColorRed: (float)r Green: (float)g Blue: (float)b {
	color[0]=r;
	color[1]=g;
	color[2]=b;
	return self;
}
- setColorRed: (float)r {
	color[0]=r;
	return self;
}
- (float)getColorRed { 
	return color[0]; 
}
- setColorGreen: (float)g {
	color[1]=g;
	return self;
}
- (float)getColorGreen {
	return color[1];
}
- setColorBlue: (float)b {
	color[2]=b;
	return self;
}
- (float)getColorBlue {
	return color[2];
}

- setScale: (float)s {
	int i;
	for (i=0;i<3;i++)
		scale[i]=s;
	return self;
}
- setScaleX: (float)x Y: (float)y Z: (float)z {
	scale[0]=x;
	scale[1]=y;
	scale[2]=z;
	return self;
}
- setRotationOnX: (float)x Y: (float)y Z: (float)z {
	rotates[0]=x;
	rotates[1]=y;
	rotates[2]=z;
	return self;
}
- setFont: (NSString *)font_res {
	id fontPointer;
	[font_res retain];
	[fontResource autorelease];
	fontResource=font_res;

	NSString * key = [NSString stringWithFormat: @"%s-%d",font_res,glutGetWindow()];

	fontPointer = [fontCache valueForKey: key];
	if (fontPointer == nil) {
		theFont = ftglCreateExtrudeFont([fontResource UTF8String]);
		if (!theFont)
			NSLog(@"Error Loading Font:%@",fontResource);
		ftglSetFontFaceSize(theFont,36,72);
		ftglSetFontCharMap(theFont,ft_encoding_unicode);
		fontPointer = [NSNumber numberWithLong: (long)theFont];
		[fontCache setObject: fontPointer forKey: key];
	}
	else {
		theFont = (FTGLfont *)[fontPointer longValue];
	}	
	return self;
}
- glDraw {
///@todo store the bounding box infos
	float bounds[6];
    if(string == nil) {
        NSLog(@"in GLText::glDraw() string is nill! cannot draw this....");
        return self;
    }
    if(theFont == NULL) {
        NSLog(@"in GLText::glDraw() theFont is nill! please initialize before attempting to draw....");
        return self;
    }
	ftglGetFontBBox(theFont,[string UTF8String],[string length],bounds);
	glPushMatrix();

	if (rotates[0]==0.0 && rotates[1]==0.0 && rotates[2]==0.0)
		glTranslatef(0,bounds[4],0);
	glScalef(scale[0],-scale[1],scale[2]);	
	glRotatef(rotates[0],1.0,0.0,0.0);
	glRotatef(rotates[1],0.0,1.0,0.0);
	glRotatef(rotates[2],0.0,0.0,1.0);
	glColor3fv(color);
	
	ftglRenderFont(theFont,[string UTF8String], FTGL_RENDER_ALL);

	glPopMatrix();
	return self;
}

-(NSString *)getString {
	return string;
}

-setString: (NSString*)s {
	[s retain];
	[string autorelease];
	string = s;
	return self;
}

-(float)width {
///@todo store the bounding box infos
	float bounds[6];
	if (string == nil)
		return 1;
	ftglGetFontBBox(theFont,[string UTF8String],[string length],bounds);
	//This really should deal with any rotations that may have happened
	//TODO: what about dealing with the scale??????????
	return abs(bounds[3]-bounds[0]);
}

-(float)height {
///@todo store the bounding box infos
	float bounds[6];
	if (string == nil)
		return 1;
	ftglGetFontBBox(theFont,[string UTF8String],[string length],bounds);
	//This really should deal with any rotations that may have happened
	return abs(bounds[4]-bounds[1]);
}
- bestFitForWidth: (float)w andHeight: (float)h {
    // Scale the font so that it fits within width and height passed
    float s_h = [self height];
    float s_w = [self width];
    if(s_h == 0 || s_w == 0)
        return self;
    float heightRatio = h / s_h;
    float widthRatio = w / s_w;
    [self setScale: heightRatio < widthRatio ? .8 * heightRatio: .8 * widthRatio];
    return self;
}
@end
