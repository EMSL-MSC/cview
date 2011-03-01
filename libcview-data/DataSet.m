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
#import <sys/param.h>  //for max/min
#import "DataSet.h"
#import "DictionaryExtra.h"
#import "math.h"


@implementation DataSet

-initWithName: (NSString *)n Width: (int)w Height: (int)h {
	[self initWithWidth: w Height: h];
	name = n;
	[name retain];
	textDescription=name;
	return self;
}

-initWithWidth: (int)w Height: (int)h {
	if (name == nil)
		name = DS_DEFAULT_NAME;
	width=w;
	height=h;
	data = [[NSMutableData alloc] initWithLength: w*h*sizeof(float)];
	currentScale = 1.0;
	currentMax = 1.0;
	if (currentLimit==0.0)
		currentLimit = DS_DEFAULT_LIMIT;
	if (rateSuffix == nil)
		rateSuffix = DS_DEFAULT_RATE_SUFFIX;
	//lockedMax=0;
	allowScaling=YES;
	if (textDescription == nil)
		[self setDescription: name];
	labelFormat=DS_DEFAULT_LABEL_FORMAT;
	return self;
}

-initWithPList: (id)list {
	NSLog(@"initWithPList: DataSet:%@",[self class]);
	lockedMax = [[list objectForKey:@"lockedMax" missing: @"0"] floatValue];
	currentLimit = [[list objectForKey:@"limit" missing: DS_DEFAULT_LIMIT_S] floatValue];
	labelFormat=[list objectForKey:@"labelFormat" missing: DS_DEFAULT_LABEL_FORMAT];
	name = [[list objectForKey:@"name" missing: DS_DEFAULT_NAME] retain];
	rateSuffix=[list objectForKey:@"rateSuffix" missing: DS_DEFAULT_RATE_SUFFIX];
	return self;
}

-getPList {
	NSLog(@"getPList: DataSet:%@",self);
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: 5];
	if (lockedMax != 0)
		[dict setObject: [NSNumber numberWithFloat: lockedMax] forKey: @"lockedMax"];
	if (currentLimit != DS_DEFAULT_LIMIT)
		[dict setObject: [NSNumber numberWithFloat: currentLimit] forKey: @"limit"];
	if ([labelFormat compare: DS_DEFAULT_LABEL_FORMAT] != NSOrderedSame)
		[dict setObject: labelFormat forKey: @"labelFormat"];
	if ([name compare: DS_DEFAULT_NAME] != NSOrderedSame )
		[dict setObject: name forKey: @"name"];
	if ([rateSuffix compare: DS_DEFAULT_RATE_SUFFIX] != NSOrderedSame )
		[dict setObject: rateSuffix forKey: @"rateSuffix"];
	
	return dict;
}

-(NSArray *)attributeKeys {
	//isVisible comes from the DrawableObject
	return [NSArray arrayWithObjects: @"lockedMax",@"labelFormat",@"rateSuffix",nil];
}
-(void)dealloc {
	NSLog(@"DataSet dealloc: %@",name);
	[labelFormat autorelease];
	[data autorelease];
	[name autorelease];
	[rateSuffix autorelease];
	[super dealloc];
	return;
}

- (float *)dataRow: (int)row {
	float *d = (float *)[data mutableBytes];
	return d+row*height;
}

- (float *)data {
	return (float *)[data mutableBytes];
}

- (NSData *)dataObject {
	return data;
}

- shiftData: (int)num {
	int i;
	float *d = (float *)[data mutableBytes];
	int fsa; //From adjust
	int tsa; //to adjust
	int zero; //zeroing offset

	if (abs(num) > height) {
		NSLog(@"Bad Number in shiftData.... abs(%d) > %d",num,height);
		return nil;
	}

	if (num>0) {
		fsa = 0;
		tsa = num;
		zero = 0;
	}
	else {
		fsa = abs(num);
		tsa = 0;
		zero = width-abs(num);
	}
	for (i=0;i<width;i++) {
		//if (i==0) NSLog(@"Shift: %p %p %d",d+i*height+fsa,d+i*height+tsa,sizeof(float)*(height-abs(num)));
		memmove(d+i*height+tsa,d+i*height+fsa,sizeof(float)*(height-abs(num)));
		memset(d+i*height+zero,0,sizeof(float)*abs(num));
	}
	return self;
}

- (int)width {
	return width;
}

- (int)height {
	return height;
}

- (NSString *)rowTick: (int)row {
	return [NSString stringWithFormat: @"Row %d",row];
}

- (NSString *)columnTick: (int)col {
	return [NSString stringWithFormat: @"Col %d",col];
}

- (NSDictionary *)columnMeta: (int)col {
	return nil;
}

- (float)resetMax {
	int i;

	//NSLog(@"allowScaling: %d",allowScaling);
	if (lockedMax > 0.0) {
		currentMax=lockedMax;
		return lockedMax;
	}
	///@todo lameway to get max FIXME?
	float *d = (float *)[data mutableBytes];
	float max = 0.001;
	for (i=0;i<width*height;i++)
		max = MAX(max,d[i]/currentScale);
	NSLog(@"The Max(%@): %f",name,max);

	float pct = currentMax/max;
	if (pct > 2.0) {
		NSLog(@"<%@>PCT: %f",name,pct);
	}	

	currentMax=max;
	return max;
}

- (float)getMax {
	return currentMax;
}

- (float)getScaledMax {
	//NSLog(@"scaled maxes: %10f %10f %10f",currentMax,currentScale,(currentMax*currentScale)*1.0);
	return currentMax*currentScale;
}

- lockMax: (int)max {
	lockedMax = (float)max;

	[self autoScale];
	return self;
}

- autoScale: (int)limit {
	currentLimit = limit;
	[self autoScale];
	return self;
}

- autoScale {
	//figure out a scaling that will make the data be <limit> 'high'..  could be configuarable.
	int i;
	float *d = (float *)[data mutableBytes];
	float newscale,u;
	float oldmax = [self resetMax];
	
	if (allowScaling) {
		//newscale = MAX(1.0,currentLimit/oldmax);
		newscale = currentLimit/oldmax;
	
		for (i=0;i<width*height;i++) {
			u=(d[i]/currentScale)*newscale;
			d[i]=MIN(currentLimit+1,MAX(u,0.0));
		}
		currentScale=newscale;
		[self resetMax];
		//NSLog(@"scale(%@): %.2f %6f %.2f %d",name,oldmax,newscale,currentMax,currentLimit);
	}

	return self;
}

- disableScaling {
	int i;
	float *d = (float *)[data mutableBytes];
	allowScaling = NO;
	//undo any previos scaling
	if ( currentScale != 1.0 ) {
		for (i=0;i<width*height;i++)
				d[i] = (d[i]/currentScale);
		currentMax /= currentScale;
		currentScale = 1.0;
	}
	return self;
}

- autoScaleWithNewData: (NSData *)newdata {
	BOOL rescale = NO;
	int i;
	float *frm = (float *)[newdata bytes];
	float *to = (float *)[data mutableBytes];
	float max = 0.001;
		
	for (i=0;i<width*height;i++) {
		to[i] = frm[i]*currentScale;
		max = MIN(currentLimit+1,MAX(max,frm[i]));
		if (frm[i] > currentMax) {
			//NSLog(@"bigger(%@): %6f > %6f",name,frm[i],currentMax);
			rescale = YES;
		}	
	}

	float pct = currentMax/max;
	if (pct > 2.0) {
		NSLog(@"<%@>aswnd PCT: %f",name,pct);
		rescale = YES;
	}	

	if (rescale) {
		NSLog(@"rescale active(%@): %6f %6f",name,currentScale,currentMax);
		
		[self autoScale];
	}

	return self;
}


- (NSString *)getLabel: (float)rate {
	//FIXME scaling?
	return [NSString stringWithFormat: labelFormat,rate/currentScale,rateSuffix];
}
- (NSString *)getLabelFormat {
	return labelFormat;
}

- setLabelFormat: (NSString *)fmt {
	[labelFormat autorelease];
	labelFormat = fmt;
	[labelFormat retain];
	return self;
}

-setDescription: (NSString *)description {
	[textDescription autorelease];
	textDescription = description;
	[textDescription retain];
	return self;
}

- (NSString *)getDescription {
	//NSLog(@"%p",textDescription);
	//NSLog(@"%@",textDescription);
	return textDescription;
}

- setRate:(NSString *)r {
	if ( ((id)r == [NSNull null]) ) {
		NSLog(@"Null rate set for dataset, please dont do that, using a default");
	}
	else {
		[rateSuffix autorelease];
		rateSuffix=r;
		[rateSuffix retain];
	}
	return self;
}

-(NSString *)getRate {
	return rateSuffix;
}

- description {
	return [NSString stringWithFormat: @"%@-%@",[self class],name];
}

@end /* DataSet */
