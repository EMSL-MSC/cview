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
#import "CViewScreenDelegate.h"
#import "GLGrid.h"
#import "WebDataSet.h"


#if HAVE_ANTTWEAKBAR

void TW_CALL cv_setGridType(const void *value, void *clientData)
{ 
    NSLog(@"Setit: %d",*(GridTypesEnum *)value);
	GLGrid *grid = (GLGrid *)clientData;
	[grid setGridType: *(GridTypesEnum *)value];
}

void TW_CALL cv_getGridType(void *value, void *clientData)
{ 
	GLGrid *grid = (GLGrid *)clientData;
    *(GridTypesEnum *)value = [grid getGridType];
}
#endif

@implementation CViewScreenDelegate 
-init {
	PListOutputFile = nil;
	return self;
}

-(void)setOutputFile: (NSString *)file {
	[file retain];
	[PListOutputFile autorelease];
	PListOutputFile= file;
	return;
}

-(NSString *)getOutputFile {
	return PListOutputFile;
}

-dealloc {
	NSLog(@"CViewScreenDelegate dealloc");
	[PListOutputFile autorelease];
	[super dealloc];
	return self;	
}
#if HAVE_ANTTWEAKBAR

-setupTweakers: (GLWorld *)world {
	[super setupTweakers: world];

	NSLog(@"Tweaker: %@",tweaker);
	if (tweaker) {
		modbar = [tweaker addBar: @"modbar"];
		
		TwEnumVal gridTypes[] = {
			{ G_LINES,"Lines" },
			{ G_RIBBON,"Ribbons" },
			{ G_SURFACE,"Surface" },
			{ G_POINTS,"Points" } 
		};
		TwType gridType = TwDefineEnum("Grid Type",gridTypes,4);

		id o;
		NSEnumerator *list;
		list = [[[world scene] getAllObjects] objectEnumerator];
		while ( (o = [list nextObject]) ) {
			if ([o isKindOfClass: [GLGrid class]]) {	
				//Try to get a friendly name
				id name = [(GLGrid *)o getDataSet];
				//if ([name isKindOfClass: [WebDataSet class]])
				//	name = [(WebDataSet *)name getDataKey];
				NSString *string = [NSString stringWithFormat: @"Grid: %@",name];
				TwAddVarCB(modbar,[string UTF8String],gridType,cv_setGridType,cv_getGridType,o,NULL);
			}
		}
		TwDefine("modbar iconified=true");
	}
	return self;
}

-cleanTweakers: (GLWorld *)world {
	if (tweaker && modbar) {
		[tweaker removeBar: modbar];
	}
	[super cleanTweakers:world];
	return self;
}
#endif

-(BOOL)keyPress: (unsigned char)key atX: (int)x andY: (int)y inGLWorld: (GLWorld *)world; {
	if ([super keyPress: key atX: x andY: y inGLWorld: world] == NO) {
		switch (key) {
			case '~':
				if (PListOutputFile != nil) {
					NSString *err;
					id plist = [myScreen getPList];
				
					NSData *nsd = [NSPropertyListSerialization dataFromPropertyList: (NSDictionary *)plist
						format: NSPropertyListOpenStepFormat errorDescription: &err];
					[nsd writeToFile: PListOutputFile atomically: YES];
				}
				break;
#ifdef CLS_DUMP
			case '!':
				a=GSDebugAllocationListRecordedObjects(CLS_DUMP);
				i = [a objectEnumerator];
				
				while ((o = [i nextObject])) {
					NSLog(@"%d:%@",[o retainCount],[o description]);
				}
				break;
#endif
			default:
				NSLog(@"key: %c",key);
				return NO;
				break;		
		}
		return YES;
	}
	return NO;
}
@end
