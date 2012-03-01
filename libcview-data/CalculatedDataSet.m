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
#import "DataSet.h"
#import "CalculatedDataSet.h"
#import "calcdataset.h"
#import "ListComp.h"

@implementation CalculatedDataSet
-init {
	NSLog(@"init: %@",[self class]);
	dataPlanes = [[NSMutableArray arrayWithCapacity: 5] retain]; //guess number
	newData = nil;//[[NSMutableData alloc] initWithLength: width*height*sizeof(float)];
	updatedCount = 0;
    nonCongruentPlanes = YES;
	return self;
}
-initWithName: (NSString *)n usingFormula: (NSString *)c onPlanes: (id)first, ... {
	NSLog(@"initWithName: %@",[self class]);
	id object;
	va_list argList;

	[self init];
	
	width = [first width];
	height = [first height];

	va_start(argList, first);
	object = first;
	while (object) {
		NSLog(@"DataSet: %p",object);
		DataSet *ds = (DataSet *)object;
		if (width == [ds width] && height == [ds height]) {
			//[ds disableScaling];
			[dataPlanes addObject: object];
		}	
		else {
			NSLog(@"Data Set not compatible in calculation: %@ %d=?=%d %d=?=%d",ds,width, [ds width], height, [ds width]);
			[dataPlanes release];
			va_end(argList);
			return nil;
		}
		object = va_arg(argList,id);
	}
	va_end(argList);

	formula = [c retain];
	[self setCalculation: calc_data_set];
	[super initWithName: n Width: width Height: height];
	[self checkAndResetDataPlanes];
	[self performCalculation];
	[self registerForNotifications];
	//newData = [[NSMutableData alloc] initWithLength: width*height*sizeof(float)];
	return self;
}
-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);

	[super initWithPList: list];
	[self init];

	formula = [[list objectForKey: @"formula"] retain];

	NSArray *arr  = [list objectForKey: @"planes"];
	NSArray *typs = [list objectForKey: @"classes"];

	NSString *myName = [list objectForKey: @"name"];
	if (myName == nil) {
		myName = @"None";
	}
	NSString *myRateSuffix = [list objectForKey: @"rateSuffix"];
	if (myRateSuffix == nil) {
		myRateSuffix = @"None";
	}

	DataSet *ds=nil;
	id pl,cls;
	NSEnumerator *p,*c;
	Class newc;

	p = [arr objectEnumerator];
	c = [typs objectEnumerator];
	while ((pl = [p nextObject]) && (cls = [c nextObject])) {
		newc = NSClassFromString((NSString *)cls);
		if (newc && [newc conformsToProtocol: @protocol(PList)] && [newc isSubclassOfClass: [DataSet class]]) {
			ds=[newc alloc];
			[ds initWithPList: pl];
			[ds disableScaling];
			[dataPlanes addObject: ds];
		}
	}
	if (ds) {
		[self setCalculation: calc_data_set];
		NSLog(@"%@'s name is: %@", self, myName);
		[super initWithName: myName Width: [ds width] Height: [ds height]];
		//newData = [[NSMutableData alloc] initWithLength: width*height*sizeof(float)];
		rateSuffix = [myRateSuffix copy];
		[rateSuffix retain];
		[myRateSuffix autorelease];
		[self checkAndResetDataPlanes];
		[self performCalculation];
		[self registerForNotifications];
		return self;
	}
	else {
		return nil;
	}
}
-(void)dealloc {
	NSLog(@"CalculatedDataSet dealloc: %@",name);
	[newData autorelease];
	[formula autorelease];
	[dataPlanes autorelease];
	[super dealloc];
	return;
}
-(NSString *)columnTick: (int)col {
	NSString *retval;
	if ((retval = [[dataPlanes objectAtIndex: 0] columnTick: col]) == nil) {
		retval = [NSString stringWithFormat: @"Column %d",col];
	}
	return retval;
}
-(NSString *)rowTick: (int)row {
	NSString *retval;
	if ((retval = [[dataPlanes objectAtIndex: 0] rowTick: row]) == nil) {
		retval = [NSString stringWithFormat: @"Row %d",row];
	}
	return retval;
}
-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [super getPList];
	[dict setObject: formula forKey: @"formula"];
	[dict setObject: name forKey: @"name"];
	[dict setObject: rateSuffix forKey: @"rateSuffix"];
	[dict setObject: [dataPlanes arrayObjectsFromPerformedSelector:@selector(getPList)] forKey: @"planes"];
	[dict setObject: [dataPlanes arrayObjectsFromPerformedSelector:@selector(class)] forKey: @"classes"];
	return dict;
}
-(NSArray *)attributeKeys {
	return [NSArray arrayWithObjects: @"formula",@"dataPlanes",@"name",@"rateSuffix",nil];
}

-(void)registerForNotifications {
	id plane;
	NSEnumerator *planesEnum = [dataPlanes objectEnumerator];
	while ((plane = [planesEnum nextObject]) != nil) {
		NSLog(@"Registering plane %@ to notification center %@", plane, [NSNotificationCenter defaultCenter]);
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"DataSetUpdate" object:plane];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveResizeNotification:) name:@"DataSetResize" object:plane];
	}
}
- (float)resetMax {
	/*
	 * Overridden here because we are rewriting the data each time, so
	 * dividing the current data in the dataset by the new values makes the
	 * data blow up.
	 *
	 * Since the target dataset is recerated each update we simply need to
	 * find the current max of the data.
	 */
	//NSLog(@"[CalculatedDataSet(%@) resetMax]", self);
	int i;
	float max = 0;
	float *d = [newData mutableBytes];
	for(i = 0; i < width*height; i++) {
		if ( i % height == 0 )
			continue;
		max = MAX(max, d[i]);
	}
	currentMax = max;
	return max;
}
- autoScale {
	//figure out a scaling that will make the data be <limit> 'high'..  could be configuarable.
	//NSLog(@"[CalculatedDataSet(%@) autoScale]", self);
	int i;
	float *d = (float *)[newData mutableBytes];
	double newscale;
	float oldmax = [self resetMax];
	if (allowScaling) {
		//newscale = MAX(1.0,currentLimit/oldmax);
		if (oldmax != 0 )
			newscale = currentLimit/oldmax;
		else
			newscale = 1;
	
		for (i=0;i<width*height;i++)
			d[i] = d[i]*newscale;
		
		currentScale=newscale;
		//NSLog(@"CalculatedDatSet scale(%@): %.2f %.10f %.2f %d %.2f",self,oldmax,newscale,currentMax,currentLimit, [[dataPlanes objectAtIndex: 0] resetMax]);
	}
	oldData = data;
	data = newData;
	newData = oldData;
	return self;
}

- autoScaleWithNewData: (NSData *)newdata {
	[self checkAndResetDataPlanes];
	[super autoScaleWithNewData: newdata];
	return self;
}

-(void)checkAndResetDataPlanes {
	//NSLog(@"Entering [CalculatedDataSet(%@) checkAndResetDataPlanes]", self);
	NSEnumerator *list;
	DataSet *ds;
	int planew=0,planeh=0;
	[self lock];
	[dataPlanes makeObjectsPerformSelector: @selector(lock)];
	//NSLog(@"Checking congruence: %p %dx%d",newData,width,height);
	//We want to detect a size change from our current plane size
	nonCongruentPlanes = NO;
	
	list = [dataPlanes objectEnumerator];
	while ((ds = [list nextObject])) {
		if ([ds width] != width || [ds height] != height)
			nonCongruentPlanes = YES;
		planew += [ds width];
		planeh += [ds height];
		//NSLog(@"plane: %@ %dx%d",ds,[ds width],[ds height]);
	}
	ds = [dataPlanes objectAtIndex:0];
	//NSLog(@"plane info: %d %d %d",planew,planeh,[dataPlanes count]);
	if (nonCongruentPlanes || newData == nil) {
		//NSLog(@"here: %d %d %d %d",planew/[dataPlanes count], [ds width], planeh/[dataPlanes count],[ds height]);
		//now check if th sizes were all the same.
		if (planew/[dataPlanes count] == [ds width] && planeh/[dataPlanes count] == [ds height]) {
			NSLog(@"create Newdata & data");
			[self setWidth: [ds width]];
			[self setHeight: [ds height]];
			newData = [[NSMutableData alloc] initWithLength: width*height*sizeof(float)];
			nonCongruentPlanes = NO;
		}
		else {
			NSLog(@"Planes are incongruent, waiting for congruency");
		}

	}
	[dataPlanes makeObjectsPerformSelector: @selector(unlock)];
	[self unlock];
	//NSLog(@"Exiting [CalculatedDataSet(%@) checkAndResetDataPlanes]", self);
}

-(void)performCalculation {

	//NSLog(@"Entering [CalculatedDataSet(%@) performCalculation] calculating to %p len:%d", self, newData,[newData length]);
	
	//[self checkAndResetDataPlanes];
	if (nonCongruentPlanes) {
		NSLog(@"NonCongruence detected... no re-calc");
		return;
	}
	
	[self lock];

	[dataPlanes makeObjectsPerformSelector: @selector(lock)]; //  possible deadlock...
	
	NSMutableData *ptrs = [NSMutableData dataWithCapacity: sizeof( float * )*[dataPlanes count]]; //is autoreleased later
	float const **datap = (float const **)[ptrs mutableBytes];
	int i;
	NSRange dataResetRange;
	dataResetRange.location = 0;
	dataResetRange.length = width*height*sizeof(float);

	[newData resetBytesInRange: dataResetRange];
	float *new_data_bytes = [newData mutableBytes];
	for (i=0;i<[dataPlanes count];i++)
		datap[i] = (float *)[(DataSet *)[dataPlanes objectAtIndex: i] data];
	calculation([formula UTF8String],width,height,new_data_bytes,[dataPlanes count],datap);
	int max = 0;
	for (i = 0; i < width*height; i++) {
		if (new_data_bytes[i] > max) {
			max = new_data_bytes[i];
		}
	}
	[dataPlanes makeObjectsPerformSelector: @selector(unlock)];
	[self autoScale];

	[self unlock];
	//NSLog(@"Exiting [CalculatedDataSet(%@:%u) performCalculation] %p %p", self,self,data, newData);
}

-(void)receiveNotification: (NSNotification *)notification {
	updatedCount++;
	//NSLog(@"Notified..  count=%d",updatedCount);
	if ( updatedCount == [dataPlanes count] ) {
		[self performCalculation];
		updatedCount = 0;
	}
}

-(void)receiveResizeNotification: (NSNotification *)notification {
	NSLog(@"Resize notification: %@",notification);
	[self checkAndResetDataPlanes];
}

- (float *)dataRow: (int)row {
	float *retdata;
	retdata = [super dataRow: row];
	/* The last point in a row is going to be bogus on certain classes of calculated data
	 * sets. Particularly anything that uses shiftvariables.
	 */
	retdata[height] = 1;
	return retdata;
}
- (float *)data {
	float *retdata;
	retdata = [super data];
	return retdata;
}
- (NSData *)dataObject {
	return [super dataObject];
}

-setCalculation: (calc_data_set_func)calc {
	calculation = calc;
	return self;
}

-(calc_data_set_func)calculation {
	return calculation;
}

-setFormula: (NSString *)f {
	[formula autorelease];
	formula = f;
	[formula retain];
	return self;
}

-(NSString *)formula {
	return formula;
}
@end
