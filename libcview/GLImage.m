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
#include <gl.h>
#include <glut.h>
#include "Wand.h"
#import "PList.h"
#import "cview.h"
#import "DictionaryExtra.h"


@implementation GLImage
-initWithFilename: (NSString *)file {
	MagickBooleanType status;
	[super init];
	filename = [find_resource_path(file) retain];

	MagickWand *wand = NewMagickWand();
	PixelWand *pw = NewPixelWand();

	PixelSetColor(pw,"none");
	status = MagickSetBackgroundColor(wand,pw);

	///@todo optionaly pull from a resource instead of the full filename
	status = MagickReadImage (wand, [filename UTF8String]);
	if ( status == MagickFalse )
	{
		NSLog(@"Error reading image: %@",filename);
		image = nil;
	}
	else {
		tw = MagickGetImageWidth( wand );
		th = MagickGetImageHeight( wand );
		w=tw;
		h=th;

		image = [[NSMutableData dataWithCapacity: tw*th*4] retain]; //FIXME only deal with RGBA images
	
		MagickExportImagePixels(wand, 0,0, tw, th, "RGBA", CharPixel, [image mutableBytes]);
	}

	bound = NO;	
	wand = DestroyMagickWand(wand);
	return self;
}

-(void)dealloc {
	NSLog(@"%@ dealloc",[self class]);
	[filename autorelease];
	[image autorelease];
	[super dealloc];
	return;
}

-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
	[super initWithPList: list];
	[self initWithFilename: [list objectForKey: @"filename" missing: @"thefileisnotehere"]];
	[self setWidth: [[list objectForKey: @"w" missing: @"64"] intValue]];
	[self setHeight: [[list objectForKey: @"h" missing: @"64"] intValue]];
	[self setVflip: [[list objectForKey: @"vflip" missing: @"0"] intValue]];
	[self setHflip: [[list objectForKey: @"hflip" missing: @"0"] intValue]];
	return self;
}
 
-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [super getPList]];
	[dict setObject: filename forKey: @"filename"];
	[dict setObject: [NSNumber numberWithInt: w] forKey: @"w"];
	[dict setObject: [NSNumber numberWithInt: h] forKey: @"h"];
	[dict setObject: [NSNumber numberWithInt: vflip] forKey: @"vflip"];
	[dict setObject: [NSNumber numberWithInt: hflip] forKey: @"hflip"];

	return dict;
}

-(NSArray *)attributeKeys {
	return [NSArray arrayWithObjects: @"width",@"height",@"hflip",@"vflip",nil];
}

-setWidth: (int) width {
	w=width;
	return self;
}
-setHeight: (int) height {
	h=height;
	return self;
}
-(int)width {
	return w;
}
-(int)height {
	return h;
}

-setVflip: (BOOL)flip {
	vflip = flip;
	return self;
}

-setHflip: (BOOL)flip {
	hflip = flip;
	return self;
}

-(BOOL)Vflip {
	return vflip;
}
-(BOOL)Hflip {
	return hflip;
}

-glDraw {
	int bot,top,left,right;
	if (image) {
		if (!bound) {
			glGenTextures(1, &texture);
			glBindTexture(GL_TEXTURE_2D, texture);
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tw, th, 0, GL_RGBA, GL_UNSIGNED_BYTE, [image mutableBytes]);
			bound = YES;
		}

		GLboolean wasit,wasblend;

		wasit = glIsEnabled(GL_TEXTURE_2D);
		wasblend=glIsEnabled(GL_BLEND);
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);

		glBindTexture(GL_TEXTURE_2D, texture);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  GL_NEAREST);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_NEAREST);
		glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

		left=0;
		right=w;
		top=0;
		bot=h;

		if (vflip) {
			bot=0;
			top=h;
		}
		if (hflip) {
			right=0;
			left=w;
		}

		glColor4f(1.0,1.0,1.0,1.0);
		glBegin(GL_QUADS);
		glTexCoord2f(0.0,0.0);
		glVertex2i(left,top);
		glTexCoord2f(0.0,1.0);
		glVertex2i(left,bot);
		glTexCoord2f(1.0,1.0);
		glVertex2i(right,bot);
		glTexCoord2f(1.0,0.0);
		glVertex2i(right,top);
		glEnd();
	
		if (!wasit)
			glDisable(GL_TEXTURE_2D);
		if (!wasblend)
			glDisable(GL_BLEND);
	}
	return self;
}


-description {
	return [[self class] description];
}

@end
