/*

This file is port of the CVIEW graphics system, which is goverened by the following License

Copyright © 2016, Battelle Memorial Institute
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
#import "DefaultGLScreenDelegate.h"
#import "GLGrid.h"
#import "GraphiteDataSet.h"
#import "cview.h"

#define SCENE1 1
//#define SCENE2 1

@interface Toggle: DefaultGLScreenDelegate
@end

@implementation Toggle
-(BOOL)keyPress: (unsigned char)key atX: (int)x andY: (int)y inGLWorld: (GLWorld *)world; {
	if ([super keyPress: key atX: x andY: y inGLWorld: world] == NO && key == 'g') {
		//Find the GLGrids:
		id o;
		NSEnumerator *list;
		list = [[[world scene] getAllObjects] objectEnumerator];
		while ( (o = [list nextObject]) ) {
			if ([o isKindOfClass: [GLGrid class]]) {
				GLGrid *g = (GLGrid *)o;
				[g setGridType: ([g getGridType]+1)%G_COUNT];
			}
		}
		return YES;
	}
	return NO;
}
@end

int main(int argc,char *argv[], char *env[]) {
	DrawableObject *o;
	Toggle *toggler;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#ifndef __APPLE__
	//needed for NSLog
	[NSProcessInfo initializeWithArguments: argv count: argc environment: env ];
#endif
	@try {
		NSURL *graphite = [NSURL URLWithString: @"https://graphite.emsl.pnl.gov/render/"];
		#ifdef SCENE1
		GraphiteDataSet *d = [[GraphiteDataSet alloc] initWithUrl: graphite named: @"Lustre" andQuery: @"aliasByNode(cascade.lustre.*.lusost.writekbs.*,5)"];
		[[ValueStore valueStore] setKey: @"d" withObject: d];
		[d setDescription: @"OSD Space Used"];
		[d setRate:@"Bytes/s"];
		[d setFrom:@"-3h"];
		[d setSort:1];
		#endif
		#ifdef SCENE2
		GraphiteDataSet *f = [[GraphiteDataSet alloc] initWithUrl: graphite named: @"CascadeAppUse" andQuery: @"aliasByNode(highestAverage(cascade.squeue.appnode.*,10),3)"];
		[[ValueStore valueStore] setKey: [f name] withObject: f];
		[f setDescription: @"Cascade Application Use"];
		[f setRate:@"Count"];
		[f setFrom:@"-3h"];
		#endif

		GLScreen * g = [[GLScreen alloc] initName: @"Graphite Test" withWidth: 1200 andHeight: 600];

		#ifdef SCENE1
		Scene * scene1 = [[Scene alloc] init];

		o=[[[[GLGrid alloc] initWithDataSet: d] setXTicks: 50] setYTicks: 32];
		[scene1 addObject: o atX: 0 Y: 0 Z: 0];

		[[[g addWorld: @"TL" row: 0 col: 0 rowPercent: 50 colPercent:50]
			setScene: scene1]
			setEye: [[[Eye alloc] init] setX: 367.0 Y: 740.0 Z: 591.0 Hangle:-5.27 Vangle: -2.45]
		];
		#endif
		#ifdef SCENE2
		// SCENE2
		Scene * scene2 = [[Scene alloc] init];
		o=[[[[GLGrid alloc] initWithDataSet: f] setXTicks: 1] setYTicks: 32];
		[o setValue: [NSNumber numberWithInt: 10] forKey: @"xscale"];

		[scene2 addObject: o atX: 0 Y: 0 Z: 0];

		[[[g addWorld: @"TR" row: 0 col: 2 rowPercent: 50 colPercent:50]
			setScene: scene2]
			setEye: [[[Eye alloc] init] setX: 367.0 Y: 740.0 Z: 591.0 Hangle:-5.27 Vangle: -2.45]
		];
		#endif
		toggler = [[Toggle alloc] initWithScreen: g];
		[g setDelegate: toggler];
		[g getPList];
		[g run];
	}
	@catch (NSException *localException) {
		NSLog(@"Error: %@", localException);
		NSArray *arr = [localException callStackSymbols];
		NSEnumerator *e = [arr objectEnumerator];
		NSObject *o;
		while ( (o=[e nextObject]) != nil) {
			NSLog(@"Stack: %@",o);
		}
		return -1;
	}
	[pool release];

	return 0;
}
