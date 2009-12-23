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
#import "WebDataSet.h"


@implementation WebDataSet
/*
-(NSData *)_downloadURL: (NSURL *)url useCache: (BOOL) cachedok {
	NSData *d;
	NSURLHandle *handle;

	d = [handle loadInForeground];
	[handle release];
	allowRescale = NO;
	NSLog(@"LEN:%d",[d length]);
	return d;
}
*/
-initWithUrlBase: (NSURL *)base andKey: (NSString *)key {
    indexByString = nil;
	int w,h,retrys;
	Class handlerClass;
	NSURLHandle *handle;
	NSDate *d;

    indexByString = nil;
	baseURL = [base retain];
	dataKey = key;
	dataURL = [[NSURL URLWithString: [NSString stringWithFormat: @"%@.data",key] relativeToURL: base] retain];
	XticksURL = [[NSURL URLWithString: @"xtick" relativeToURL: base] retain];
	YticksURL =  [[NSURL URLWithString: [NSString stringWithFormat: @"%@.ytick",key] relativeToURL: base] retain];

	handlerClass = [NSURLHandle URLHandleClassForURL: dataURL];

	w=0;
	h=0;
	retrys=10;
	while ((w==0 || h==0) && retrys-- >0) {
		//calculate size based on downloaded data
		handle = [[handlerClass alloc] initWithURL: XticksURL cached: NO];
		Xticks = [[NSMutableData dataWithData: [handle loadInForeground]] retain];
		[handle release];
		handle = [[handlerClass alloc] initWithURL: YticksURL cached: NO];
		Yticks = [[NSMutableData dataWithData: [handle loadInForeground]] retain];
		[handle release];
	
		if (Xticks == nil || Yticks == nil) {
			NSLog(@"Error loading URLS for dataset: %@ %s %@ %@",base,key,Xticks,Yticks);
		}
		else {
			w = [Xticks length]/32;
			h = [Yticks length]/32;
			NSLog(@"Sizes: %d,%d",w,h);
		}
		if (w==0 || h==0) {
			d=[NSDate dateWithTimeIntervalSinceNow: 2];
			[NSThread sleepUntilDate:d];
		}
	}
	if (retrys < 0 )
		return nil;

	[super initWithName: key Width: w Height: h];
	while ([self updateData] == YES)
		//Get a valid dataset first
		NSLog(@"Getting a dataset");
		;
	NSLog(@"Loaded:%@",dataURL);
	allowRescale = YES;
	rateSuffix = [NSString stringWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@.rate",key] relativeToURL: base]];
	[rateSuffix retain];
	textDescription = [NSString stringWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@.desc",key] relativeToURL: base]];
	[textDescription retain];
	NSLog(@"description: %p",textDescription);
	NSLog(@"rateSuffix: %@",rateSuffix);
    [self initializeIndexByStringDictionary];
	return self;
}
/**@objcdef dataUpdateInterval specify how often the thread will reload the DataSet*/
-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
    indexByString = nil;

	[super initWithPList: list];

	NSURL *url = [NSURL URLWithString: [list objectForKey: @"baseURL"]];
	NSString *key = [list objectForKey: @"key"];

	thread = [[UpdateThread alloc] initWithUpdatable: self];

	[self initWithUrlBase: url andKey: key];

	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
	[thread startUpdateThread: [args floatForKey: @"dataUpdateInterval"]];
    [self initializeIndexByStringDictionary];
	return self;
}

-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [super getPList];
	[dict setObject: baseURL forKey: @"baseURL"];
	[dict setObject: dataKey forKey: @"key"];
	return dict;
}
/*
-(NSArray *)attributeKeys {
	return [NSArray arrayWithObjects: @"baseURL",@"dataKey",nil];
}
*/
-(void)dealloc {
	NSLog(@"dealloc WebDataSet:%@",name);
	[dataURL autorelease];
	[XticksURL autorelease];
	[YticksURL autorelease];
	[Xticks autorelease];
	[Yticks autorelease];
	[rateSuffix autorelease];
	[baseURL autorelease];
	[[thread terminate] autorelease];
	[super dealloc];
}

-(BOOL)updateData {
    NSLog(@"WebDataSet: Updating web data....");
	BOOL abort;
	NSData *Xt;
	NSData *Yt;
	NSData *Data;
	Class handlerClass = [NSURLHandle URLHandleClassForURL: dataURL];
	NSURLHandle *X,*Y,*D;
	//now get the data validating size;
	
	//this is difficult way to do this, but needed so we dont leak sockets
	X = [[handlerClass alloc] initWithURL: XticksURL cached: YES];
	Xt = [X loadInForeground];
	Y = [[handlerClass alloc] initWithURL: YticksURL cached: NO];
	Yt = [Y loadInForeground];
	D = [[handlerClass alloc] initWithURL: dataURL cached: NO];
	Data = [D loadInForeground];

	abort = NO;
	if ([Data length] != width*height*sizeof(float)) {
		NSLog(@"Data Size Invalid: %d*%d*%d != %d",width,height,sizeof(float),[Data length]);
		abort = YES;
	}
	if ([Xt length] != width*TICK_LEN) {
		NSLog(@"Xt Size Invalid: %d*%d != %d",width,TICK_LEN,[Xt length]);
		abort = YES;
	}
	if ([Yt length] != height*TICK_LEN) {
		NSLog(@"Yt Size Invalid: %d*%d != %d",height,TICK_LEN,[Yt length]);
		abort = YES;
	}

	if ( ! abort) {
		[Xticks setData: Xt];
		[Yticks setData: Yt];
	
		[self autoScaleWithNewData: Data];
	}

	[X autorelease];
	[Y autorelease];
	[D autorelease];

	return abort;
} 

- (NSString *)rowTick: (int)row {
	char *ticks = (char *)[Yticks mutableBytes];
	return [NSString stringWithCString: ticks+TICK_LEN*row];
}

- (NSString *)columnTick: (int)col {
	char *ticks = (char *)[Xticks mutableBytes];
//	NSLog(@"col: %d %s",col,ticks+TICK_LEN*col);
	return [NSString stringWithCString: ticks+TICK_LEN*col];
}

-(NSString *)getDataKey {
	return dataKey;
}
-(float*)dataRowByString:(NSString*)xTick {
    if(indexByString != nil) {
        //NSLog(@"index is: %d, xTick = %@", [[indexByString objectForKey: xTick] intValue], xTick);
        id obj = [indexByString objectForKey: xTick];
        if(obj != nil)
            return [self dataRow: [obj intValue]]; 
        else
            return NULL;
    }else{
        NSLog(@"Uh-oh, just tried to find stuff when the dictionary wasn't even instantialized!!!!");
        return NULL;   // Hasn't been instantialized!!!
    }
}
-initializeIndexByStringDictionary {
    // Must read all xTicks to determine their appropriate index
    if(indexByString != nil)
        [indexByString autorelease];
    indexByString = [[NSMutableDictionary alloc] init];
    int i;
    for(i=0;i<[self width]; ++i) {
        //NSLog(@"key = %@, object = %d, i = %d", [self columnTick: i], [[NSNumber numberWithInt: i] intValue], i);
        [indexByString setObject: [NSNumber numberWithInt: i]
            forKey: [[self columnTick: i] uppercaseString]];
    }
    return self;
}
@end
