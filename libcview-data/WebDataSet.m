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
#import "cview-data.h"
#import "UpdateRunLoop.h"
#import "WebDataSet.h"

static float blankdata[] = {
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  6, 26,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  6, 26,  0,  0,  0,
  0,  0,  0,  6, 51,103,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 25,109, 26,  0,  0,  0,
  0,  0,  0,  0, 25,127,110,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 25,133,104,  0,  0,  0,  0,
  0,  0,  0,  0,  0, 25,147,136,  6,  0,  0,  2, 14, 26, 39, 50, 50, 48, 36, 24, 11,  0,  0,  0, 25,149,130, 11,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 25,208,155,  6,  3, 39,112,164,214,255,255,244,193,142, 87, 22,  0, 25,149,203, 44,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0, 25,208,165,104,175,255,255,255,255,255,255,255,255,233,135, 99,149,203, 44,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0, 40,238,247,255,249,211,153,127,127,134,172,229,255,250,237,225, 44,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  3, 70,230,255,254,207, 83, 26,  0,  0,  6, 44,128,234,255,254,197, 22,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  1, 39,175,255,250,255,242,107,  0,  0,  0,  0, 25,157,255,253,255,233,126, 11,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 14,112,255,249,198,173,255,239,107,  0,  0, 25,152,255,247,176,229,255,219, 62,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 26,164,255,230,103, 25,152,255,239,113, 26,156,255,246,129, 25,152,255,232,114,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 39,214,255,211, 26,  0, 25,152,255,243,163,255,249,130,  0,  6, 76,255,244,165,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 50,255,255,205,  0,  0,  0, 25,168,255,255,249,154, 11,  0,  0, 50,255,255,205,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 50,255,255,205,  0,  0,  0, 25,156,255,255,243,120,  1,  0,  0, 50,255,255,205,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 48,244,255,211, 26,  0, 25,152,255,249,187,255,243,113,  0,  6, 76,255,253,194,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 36,193,255,230,103, 25,152,255,246,153, 35,168,255,239,107, 25,152,255,241,143,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 23,142,255,249,198,173,255,246,129,  0,  0, 25,152,255,239,162,229,255,229, 92,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 11, 87,233,255,250,255,248,129,  0,  0,  0,  0, 25,157,255,252,255,252,194, 40,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0, 22,135,248,255,255,214, 83, 26,  0,  0,  6, 44,128,234,255,255,225, 81,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0, 65,237,254,255,249,211,153,128,128,134,172,229,255,254,252,220,  6,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0, 25,149,213,197,233,255,255,255,255,255,255,255,255,252,218,161,208,155,  6,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 25,149,203, 44, 22,126,219,232,244,255,255,253,241,229,194, 81,  0, 25,208,155,  6,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0, 25,133,200, 44,  0,  0, 11, 62,114,165,205,205,194,143, 92, 40,  0,  0,  0, 25,208,136,  1,  0,  0,  0,  0,
  0,  0,  0,  0, 25,127,127, 11,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 25,147,110,  0,  0,  0,  0,
  0,  0,  0,  6, 51,103,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 25,109, 26,  0,  0,  0,
  0,  0,  0,  6, 26,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  6, 26,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
};
#ifndef LOG_STAGE
#define LOG_STAGE 0
#endif
#if LOG_STAGE
#define LOGSTAGE(x,a...) NSLog(x,##a)
#else
#define LOGSTAGE(x,a...)
#endif

@implementation WebDataSet
-initWithUrlBase: (NSURL *)base andKey: (NSString *)key {
	NSLog(@"WebDataSet::initWithUrlBase: %@ key: %@", base, key);
	BOOL updateRepeats = YES;
	float interval = [[NSUserDefaults standardUserDefaults] floatForKey: @"dataUpdateInterval"];
	indexByString = nil;
	baseURL = [base retain];
	dataKey = key;
	dataURL = [[NSURL URLWithString: [NSString stringWithFormat: @"%@.data",key] relativeToURL: base] retain];
	XticksURL = [[NSURL URLWithString: @"xtick" relativeToURL: base] retain];
	YticksURL =  [[NSURL URLWithString: [NSString stringWithFormat: @"%@.ytick",key] relativeToURL: base] retain];
	rateURL = [[NSURL URLWithString: [NSString stringWithFormat: @"%@.rate",key] relativeToURL: base] retain];
	descURL = [[NSURL URLWithString: [NSString stringWithFormat: @"%@.desc",key] relativeToURL: base] retain];

	/* Sane Defaults until we have actual data */

	if([self getDescription] == nil)
		[super initWithName: name Width: 32 Height: 32];
	else
		[super initWithWidth: 32 Height: 32];

	if (name==nil)
		name = [key retain];

	dataValid=NO;
	Xticks = [[NSMutableData dataWithLength: 32*TICK_LEN] retain];
	Yticks = [[NSMutableData dataWithLength: 32*TICK_LEN] retain];
	allowRescale = YES;
	rateSuffix = @"...";
	[data setData: [NSData dataWithBytes: blankdata length: sizeof(blankdata)]];
	currentMax = 255.0;

	incomingData = [[NSMutableData data] retain];
	stage = START;
	if(interval <= 0.0f)
		updateRepeats = NO;
	timer = [[NSTimer alloc] initWithFireDate: [NSDate dateWithTimeIntervalSinceNow: 1]
							 interval: interval
							 target:self
							 selector: @selector(fireTimer:)
							 userInfo:nil
							 repeats:updateRepeats];
	[[UpdateRunLoop runLoop] addTimer: timer forMode: NSDefaultRunLoopMode];

	return self;
}
/**@objcdef dataUpdateInterval specify how often the thread will reload the DataSet*/
-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
	indexByString = nil;

	[super initWithPList: list];

	NSURL *url = [NSURL URLWithString: [list objectForKey: @"baseURL"]];
	NSString *key = [list objectForKey: @"key"];

	[self initWithUrlBase: url andKey: key];

	return self;
}

-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [super getPList];
	[dict setObject: baseURL forKey: @"baseURL"];
	[dict setObject: dataKey forKey: @"key"];
	if(isCustomTextDescription)
		[dict setObject: textDescription forKey: @"textDescription"];
	return dict;
}

-(NSArray *)attributeKeys {
	return [NSArray arrayWithObjects: @"baseURL",@"dataKey",nil];
}

-(void)dealloc {
	NSLog(@"dealloc WebDataSet:%@",name);
	[dataURL autorelease];
	[XticksURL autorelease];
	[YticksURL autorelease];
	[timer invalidate];
	[timer autorelease];
	[webConn autorelease];
	[incomingData autorelease];
	[Xticks autorelease];
	[Yticks autorelease];
	[rateSuffix autorelease];
	[baseURL autorelease];
    [indexByString autorelease];
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	int code;
	LOGSTAGE(@"Incoming Data: %d %@",stage,response);
	if ([response respondsToSelector:@selector(statusCode)]) {
		code = [((NSHTTPURLResponse *)response) statusCode];
		switch (code) {
			case 200:
				break;
			default:
				NSLog(@"URL request to %@ returned %d",[response URL],code);
				stage = ERR;
				break;
		}
	}
    [incomingData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)indata {
	//NSLog(@"Data Recieved: %@ - %ld - %d",connection, [indata length],stage);
	[incomingData appendData: indata];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	LOGSTAGE(@"Error Recieved: %@ %@",connection,error);
	[connection autorelease];
	stage = IDLE;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection  {
//	NSLog(@"connection Finished: %@",connection);
	NSURLRequest *req;
	float *to,*from;
	int w,h,i;

	switch (stage) {
		case DESC:
			LOGSTAGE(@"DESC finish");
			[incomingData increaseLengthBy:1];
			if([[self getDescription] compare: DS_DEFAULT_NAME] == NSOrderedSame)
				[self setDescription: [NSString stringWithUTF8String: [incomingData bytes]]];
			NSLog(@"desc: %@ %@",textDescription,[NSString stringWithUTF8String: [incomingData bytes]]);

			stage = RATE;
			req = [NSURLRequest requestWithURL: rateURL cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 60.0];
			webConn = [[NSURLConnection connectionWithRequest: req delegate: self] retain];
			break;

		case RATE:
			LOGSTAGE(@"RATE finish");
			[incomingData increaseLengthBy:1];
			[self setRate: [NSString stringWithUTF8String: [incomingData bytes]]];
			//NSLog(@"rate: %@",rateSuffix);

			stage = IDLE;
			[self fireTimer:nil]; //Start the data download in the timer code
			break;

		case START:
		case IDLE:
			NSLog(@"Should not recieve data during IDLE/START stage");
			break;

		case XTICK:
			LOGSTAGE(@"XTICK finish: %@",dataKey);
			w = [incomingData length];
			if (w%TICK_LEN != 0 || w == 0) { //inproper read
				stage = IDLE;
				break;
			}
			w /= TICK_LEN;
			L();
			[dataLock lock];
			if (w != width)
				[self setWidth: w];

			[Xticks setData: incomingData];
			//Is this where this goes?
		    [self initializeIndexByStringDictionary];

			U();
			[dataLock unlock];
			stage = YTICK;
			req = [NSURLRequest requestWithURL: YticksURL cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 60.0];
			webConn = [[NSURLConnection connectionWithRequest: req delegate: self] retain];
			break;

		case YTICK:
			LOGSTAGE(@"YTICK finish: %@",dataKey);
			h = [incomingData length];
			if (h%TICK_LEN != 0) { //inproper read
				stage = IDLE;
				break;
			}
			h /= TICK_LEN;
			L();
			[dataLock lock];
			if (h != height && h>0)
				[self setHeight: h];

			[Yticks setData: incomingData];
			U();
			[dataLock unlock];
			stage = DATA;
			req = [NSURLRequest requestWithURL: dataURL cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 60.0];
			webConn = [[NSURLConnection connectionWithRequest: req delegate: self] retain];
			break;

		case DATA:
			LOGSTAGE(@"DATA finish: %@ len=%ld",dataKey,[incomingData length]);

			if (width*height*sizeof(float) == [incomingData length]) {
				[self setNewData: incomingData];
			} else {
				NSLog(@"Possible Badness! Incoming data was not the correct size. Width = %d Height = %d Width * Height = %d DataSet Size = %ld", width, height, width * height, [incomingData length] / sizeof(float));
				//If the data is too big lets just truncate for now, as the depth stretching could be ok
				if (width*height*sizeof(float)<[incomingData length]) {
					h = [incomingData length]/(width*sizeof(float));
					NSMutableData *d = [NSMutableData dataWithLength: width*height*sizeof(float)];
					from = [incomingData mutableBytes];
					to = [d mutableBytes];
					for (i=0;i<width;i++)
						memcpy(to+i*height,from+i*h,sizeof(float)*height);
					}
			}


			dataValid=YES;
			[[NSNotificationCenter defaultCenter] postNotificationName: @"DataSetUpdate" object: self];
			stage = IDLE;
			webConn=nil;
			break;
		case ERR:
			NSLog(@"error stage seen");
			stage = IDLE;
			break;
		default:
			LOGSTAGE(@"Invalid Stage in state machine..");
			break;
	}
	[connection autorelease];
	return;
}

-(void)fireTimer:(NSTimer*)aTimer {
	//NSLog(@"WebDataSet::fireTimer()");
	[self initializeIndexByStringDictionary];
	[self resetMax];


	NSURLRequest *req;

	if (stage == IDLE) {
		LOGSTAGE(@"IDLE begin");
		req = [NSURLRequest requestWithURL: XticksURL cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 60.0];
		stage = XTICK;
		webConn = [[NSURLConnection connectionWithRequest: req delegate: self] retain];
	}
	else if (stage == START) {
		LOGSTAGE(@"START begin");
		req = [NSURLRequest requestWithURL: descURL cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 60.0];
		stage = DESC;
		webConn = [[NSURLConnection connectionWithRequest: req delegate: self] retain];
	}

	return;
}

- (NSString *)rowTick: (int)row {
	char *ticks = (char *)[Yticks mutableBytes];
	return [NSString stringWithUTF8String: ticks+TICK_LEN*row];
}

- (NSString *)columnTick: (int)col {
	char *ticks = (char *)[Xticks mutableBytes];
	return [NSString stringWithUTF8String: ticks+TICK_LEN*col];
}

-(NSString *)getDataKey {
	return dataKey;
}
/**
	@author: Brock Erwin
	Returns an array of data (a row) by searching the dictionary
	for the column name (xTick).
 */
-(float*)dataRowByString:(NSString*)xTick {
	if(indexByString != nil) {
//        NSLog(@"index is: %d, xTick = %@", [[indexByString objectForKey: xTick] intValue], xTick);
		id obj = [indexByString objectForKey: xTick];
		if(obj != nil)
			return [self dataRow: [obj intValue]];
		else {
//			NSLog(@"Tried to find %@ but could not!", xTick);
			return NULL;
		}
	}else{
		//NSLog(@"Uh-oh, just tried to find stuff when the dictionary wasn't even instantialized!!!!");
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
