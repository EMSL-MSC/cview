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
#import "CViewAllScreenDelegate.h"
#import "WebDataSet.h"
#import "GLGrid.h"

#if HAVE_ANTTWEAKBAR

static void TW_CALL CVASD_boolSetCallback(const void *value, void *clientData) {
	NSArray *a = (NSArray *)clientData;
	CViewAllScreenDelegate *cvasd = [a objectAtIndex: 0];
	NSString *metric = [a objectAtIndex:1];
	
	[cvasd setMetric: metric to: (*(const int *)value)!=0];
	[cvasd populateWorld: YES];
	return;
}

static void TW_CALL CVASD_boolGetCallback(void *value, void *clientData) {
	NSArray *a = (NSArray *)clientData;
	CViewAllScreenDelegate *cvasd = [a objectAtIndex: 0];
	NSString *metric = [a objectAtIndex:1];
	
	*(int *)value = [cvasd getMetric: metric];
}

static void TW_CALL CVASD_intSetCallback(const void *value, void *clientData) {
	NSArray *a = (NSArray *)clientData;
	CViewAllScreenDelegate *cvasd = [a objectAtIndex: 0];
	NSString *name = [a objectAtIndex:1];

	[cvasd setValue: [NSNumber numberWithInt: *(const int *)value] forKeyPath: name];
	[cvasd populateWorld: NO];
}

static void TW_CALL CVASD_intGetCallback(void *value, void *clientData) {
	NSArray *a = (NSArray *)clientData;
	CViewAllScreenDelegate *cvasd = [a objectAtIndex: 0];
	NSString *name = [a objectAtIndex:1];

	NSNumber *i=[cvasd valueForKeyPath: name];
	*(int *)value = [i intValue];
}

#endif

@implementation CViewAllScreenDelegate 
-initWithScreen: (GLScreen *)screen; {
	gridWidth=1;
	heightPadding=128;
	widthPadding=200;
	activeGrids = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	[self toggleTweakersVisibility];
	return [super initWithScreen: screen];	
}

-(void)dealloc {
	NSLog(@"%@ dealloc",[self class]);
	[metricFlags autorelease];
	[glWorld autorelease];
	[tweakObjects autorelease];
	[activeGrids autorelease];
	[super dealloc];
	return;
}

-setGridWidth:(int)w {
	gridWidth=w;
	return self;
}

-setMetricFlags:(NSMutableDictionary *)mf {
	[mf retain];
	[metricFlags autorelease];
	metricFlags = mf;
	return self;	
}

-setMetric: (NSString *)metric to: (BOOL)b {
	NSNumber *n = [NSNumber numberWithBool: b];
	[metricFlags setObject: n forKey: metric];
	return self;
}

-(BOOL)getMetric: (NSString *)metric {
	NSNumber *n = [metricFlags objectForKey:metric];
	return [n boolValue];
}

-setWorld:(GLWorld *)world {
	[world retain];
	[glWorld autorelease];
	glWorld=world;
	return self;	
}

-setURL:(NSURL *)u {
	[u retain];
	[url autorelease];
	url=u;
	return self;	
}

-screenHasStarted {
	NSLog(@"Screen has started");
	[self populateWorld: YES];
	return self;	
}

-(void)receiveResizeNotification: (NSNotification *)notification {
       NSLog(@"CViewAllDataSetResize notification: %@",notification);
       [self populateWorld: YES];
}

-populateWorld: (BOOL)repopulate {
	int posy=0,posx=0,x=0;
	NSEnumerator *list;
	NSNumber *n;	
	GLGrid *grid;
	NSString *key;
	WebDataSet *wds;
	
	NSArray *metricList = [[metricFlags allKeys] sortedArrayUsingSelector: @selector(compare:)];
	Scene *scene = [glWorld scene];
	NSLog(@"count: %d",[scene objectCount]);
	
	//NSMutableArray *sets = [NSMutableArray arrayWithCapacity: [metricFlags count]];
	NSArray *activeKeys = [activeGrids allKeys];

	list = [metricList objectEnumerator];
	while ( (key = (NSString *)[list nextObject]) ) {
		n = [metricFlags objectForKey: key];
		if ([n boolValue]) {
			if ( ![activeKeys containsObject: key] ) {
				wds = [[WebDataSet alloc] initWithUrlBase: url andKey: key];
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveResizeNotification:) name:@"DataSetResize" object:wds];
				[wds autoScale: 100];	
				grid=[[[[[GLGrid alloc] initWithDataSet: wds] setXTicks: 50] setYTicks: 32] show];
				
				[activeGrids setObject: grid forKey: key];
				[wds autorelease];
				[grid autorelease];
			}
			//[sets addObject: [activeSets objectForKey: key]];
		}
		else {
			[activeGrids removeObjectForKey: key];
		}
	}
	list = [[activeGrids allKeys] objectEnumerator];
	//WebDataSet *d;
	[scene removeAllObjects];
	while ( (key = (NSString *)[list nextObject]) ) {
			//wait for valid data
			//while ([d dataValid] != YES)
			//	[NSThread sleepForTimeInterval: 0.1];

			grid = [activeGrids objectForKey: key];
			//NSLog(@"%@",grid);
			[scene addObject: grid atX: posx Y: 0 Z: -posy];
	
			x++;
			if (x >= gridWidth) {
				x=0;
				posy += [[grid getDataSet] height]+heightPadding;
				posx = 0;
			}
			else {
				posx += [[grid getDataSet] width]+widthPadding;
			}
	
			//[grid autorelease];
			//[o autorelease];
	}
	
	if (repopulate)
		//we changed stuff, update the other tweakbar.
		[[NSNotificationCenter defaultCenter] postNotificationName: @"DataModelModified" object: glWorld];
	return self;
}

#if HAVE_ANTTWEAKBAR
-setupTweakers {
	GLWorld *w;

	[super setupTweakers];
	tweakObjects = [[NSMutableArray arrayWithCapacity: [metricFlags count]] retain];
	
	if (tweaker) {
		NSArray *worlds = [myScreen getWorlds];
		NSEnumerator *wlist;
		wlist = [worlds objectEnumerator];
		/* there should only be one... */
		w = [wlist nextObject];
		TwSetCurrentWindow([w context]);

		NSString *key;
		NSEnumerator *list;
		NSArray *arr;
		metricbar = [tweaker addBar: @"metricbar"];
		NSArray *metricList = [[metricFlags allKeys] sortedArrayUsingSelector: @selector(compare:)];
		list = [metricList objectEnumerator];
		while ( (key = (NSString *)[list nextObject]) ) {
			arr = [NSArray arrayWithObjects: self,key,nil];
			[tweakObjects addObject: arr];
			//NSLog(@"metric: %s %p",[key UTF8String],arr);
			TwAddVarCB(metricbar,[key UTF8String],TW_TYPE_BOOL32,CVASD_boolSetCallback,CVASD_boolGetCallback,
						arr,"true='Show' false='Hide'");
		}
		TwDefine("metricbar label='Metric Selection'");
		
		settingsBar = [tweaker addBar: @"settingsbar"];

		arr=[NSArray arrayWithObjects: self,@"heightPadding",nil];
		[tweakObjects addObject: arr];
		TwAddVarCB(settingsBar,"heightPadding",TW_TYPE_INT32,
					CVASD_intSetCallback,CVASD_intGetCallback,
					arr,"label='Height Padding'");
		
		arr=[NSArray arrayWithObjects: self,@"widthPadding",nil];
		[tweakObjects addObject: arr];
		TwAddVarCB(settingsBar,"widthPadding",TW_TYPE_INT32,
					CVASD_intSetCallback,CVASD_intGetCallback,
					arr,"label='Width Padding'");


		arr=[NSArray arrayWithObjects: self,@"gridWidth",nil];
		[tweakObjects addObject: arr];
		TwAddVarCB(settingsBar,"gridWidth",TW_TYPE_INT32,
					CVASD_intSetCallback,CVASD_intGetCallback,
					arr,"label='GridWidth' min=1");
	}
	return self;
}

-cleanTweakers {
	[super cleanTweakers];
	return self;
}
#endif
@end

