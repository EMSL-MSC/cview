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
#import <GL/osmesa.h>
#import <glut.h>
#import "Wand.h"
#import "WebDataSet.h"
#import "debug.h"
#import "PList.h"
#import "cview.h"

int main(int argc,char *argv[], char *env[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ENABLEDEBUGALLOC;
	OSMesaContext ctx;
	int width,height;
	NSMutableData *buffer;
	NSString *filename;
	NSString *config;
	NSString *err;

#ifndef __APPLE__
	//needed for NSLog
	[NSProcessInfo initializeWithArguments: argv count: argc environment: env ];
#endif
	
	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
	[args registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
			@"chinookworld.cview", @"c",
			@"1280",@"w",
			@"1024",@"h",
			@"oscview.png",@"f",
			nil]];

	config = [args stringForKey: @"c"];
	filename = [args stringForKey: 	@"f"];

	

	NSData *file = [NSData dataWithContentsOfFile: config];
	NSPropertyListFormat fmt;
	id plist = [NSPropertyListSerialization propertyListFromData: file 
				mutabilityOption: NSPropertyListImmutable 
				format: &fmt
				errorDescription: &err
				];
	//NSLog(@"plist: %@ %d %@",plist,fmt,err);
	if (plist==nil) {
		printf("Error loading PList: %s. Exiting\n",[config UTF8String]);
		exit(4);
	}

	GLWorld * g = [[GLWorld alloc] initWithPList:plist];
	NSLog(@"Setup done");

	plist = [g getPList];
	NSLog([NSPropertyListSerialization stringFromPropertyList: plist]);
	

	DUMPALLOCLIST(YES);
	width = [args integerForKey: @"w"];
	height = [args integerForKey: @"h"];

	ctx = OSMesaCreateContext( OSMESA_RGBA, NULL );

	buffer = [NSMutableData dataWithCapacity: width * height * 4 * sizeof(GLubyte) ];

	if (!OSMesaMakeCurrent( ctx, [buffer mutableBytes], GL_UNSIGNED_BYTE, width, height )) {
		NSLog(@"OSMesaMakeCurrent failed!");
		exit(5);
   	}
/////////////
	
	glViewport(0, 0, width, height);
	float ratio = 1.0f*width/height;
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();	
	
	gluPerspective(20.0,ratio,0.1,5000);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	//Gl init stuffage
    glShadeModel(GL_SMOOTH);
    glEnable(GL_DEPTH_TEST);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_POINT_SMOOTH);
    //glEnable(GL_LINE_SMOOTH);
   	
    glDepthFunc(GL_LEQUAL);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
    glClearDepth(1.0);

//////////////
	[g glDraw];

	MagickWandGenesis();
	MagickWand *wand = NewMagickWand();
	MagickSetType(wand,TrueColorType);
	MagickSetSize(wand,width,height);

	//glReadPixels(0,0,width,height,GL_RGBA,GL_UNSIGNED_BYTE,[pixels mutableBytes]);
	MagickConstituteImage(wand,width,height,"RGBA",CharPixel,[buffer mutableBytes]);

	MagickFlipImage(wand);
	MagickWriteImage(wand,[filename UTF8String]);

	DestroyMagickWand(wand);

	MagickWandTerminus();

	OSMesaDestroyContext( ctx );
	[g autorelease];
	[pool release];

	return 0;
}
