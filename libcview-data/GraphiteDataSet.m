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
#import <sys/param.h>  //for max/min
#import "cview-data.h"
#import "UpdateRunLoop.h"
#import "GraphiteDataSet.h"

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
#define LOG_STAGE 1
#endif
#if LOG_STAGE
#warning Logging Stages
#define LOGSTAGE(x,a...) NSLog(x,##a)
char *gstage[] = {"IDLE", "START", "DATA", "ERROR"};
#else
#define LOGSTAGE(x,a...)
#endif
NSComparisonResult numericSort(id one,id two,void *ctxt) {
	long o = [one integerValue];
	long t = [two integerValue];
	if (o>t) return NSOrderedDescending;
	if (o<t) return NSOrderedAscending;
	return NSOrderedSame;
}

@implementation GraphiteDataSet
-initWithUrl: (NSURL *)graphite named: (NSString *)thename andQuery: (NSString *)thequery {
	NSLog(@"GraphiteDataSet::initWithUrl: %@ name: %@ query: %@", graphite, thename, thequery);
	BOOL updateRepeats = YES;
	float interval = [[NSUserDefaults standardUserDefaults] floatForKey: @"dataUpdateInterval"];
	NSLog(@"Interval: %f",interval);
	graphiteURL = [graphite retain];
	[self setQuery: thequery];

	/* Sane Defaults until we have actual data */

	[super initWithName: thename Width: 32 Height: 32];

	dataValid=NO;
	from = GDS_DEFAULT_FROM;
	until = GDS_DEFAULT_UNTIL;
	stage = G_IDLE;
	Xticks = nil;
	sort = GDS_DEFAULT_SORT;
	rateSuffix = @"...";
	[data setData: [NSData dataWithBytes: blankdata length: sizeof(blankdata)]];
	incomingData = [[NSMutableData data] retain];

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

	[super initWithPList: list];

	NSURL *url = [NSURL URLWithString: [list objectForKey: @"graphiteURL"]];
	NSString *q = [list objectForKey: @"query"];
	NSString *n = [list objectForKey: @"name"];
	[self initWithUrl: url named: n andQuery: q];

	[self setFrom: [list objectForKey:@"from" missing: GDS_DEFAULT_FROM]];
	[self setUntil: [list objectForKey:@"until" missing: GDS_DEFAULT_UNTIL]];
	[self setSort: [[list objectForKey:@"sort" missing: GDS_DEFAULT_SORT_S] integerValue]];

	return self;
}

-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [super getPList];
	[dict setObject: graphiteURL forKey: @"graphiteURL"];
	[dict setObject: query forKey: @"query"];

	PLIST_SET_IF_NOT_DEFAULT_STR(dict,from);
	PLIST_SET_IF_NOT_DEFAULT_STR(dict,until);
	PLIST_SET_IF_NOT_DEFAULT_INT(dict,sort);

	return dict;
}

-(NSArray *)attributeKeys {
	return [NSArray arrayWithObjects: @"baseURL",@"query",@"from",@"until",@"sort",nil];
}

-(void)dealloc {
	NSLog(@"dealloc WebDataSet:%@",name);
	[baseURL autorelease];
	[incomingData autorelease];
	[timer invalidate];
	[timer autorelease];
	[webConn autorelease];
	[Xticks autorelease];
	[graphiteURL autorelease];
	[from autorelease];
	[until autorelease];
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	int code;
	LOGSTAGE(@"Incoming Data[%@]: %s %@",name,gstage[stage],response);
	if ([response respondsToSelector:@selector(statusCode)]) {
		code = [((NSHTTPURLResponse *)response) statusCode];
		switch (code) {
			case 200:
				break;
			default:
				NSLog(@"URL request to %@ returned %d",[response URL],code);
				stage = G_ERR;
				break;
		}
	}
	[incomingData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)indata {
	LOGSTAGE(@"Data Recieved[%@]: %@ - %ld - %s",name,connection, [indata length],gstage[stage]);
	[incomingData appendData: indata];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	LOGSTAGE(@"Error Recieved: %s %@ %@",gstage[stage],connection,error);
	[connection autorelease];
	stage = IDLE;
}


- (NSDictionary *)processLines: (NSArray *)lines {
	NSString *line,*line_name,*s;
	int line_start,line_end,line_step,count,num=0;
	NSMutableDictionary *line_data = [NSMutableDictionary dictionaryWithCapacity:[lines count]];
	float *d;
	NSArray *chunks;
	NSMutableData *line_points;
	NSEnumerator *e,*c;
	NSCharacterSet *commaNpipe = [NSCharacterSet characterSetWithCharactersInString: @",|"];

	/* Expected Data Format:
    10,1467067140,1467070680,60|2.62995262669e+12,2.62995376947e+12,2.62995474432e+12,...
    <target name>,<start timestamp>,<end timestamp>,<series step>|[data]*
	| seperates metadata from metric data.
	metdata fields:
		metric id, or X tick in the dataset
		Start time, End Time used to generate ticks
		series step - how long between each datapoint..
    */

	e = [lines objectEnumerator];
	while ((line = [e nextObject])) {
    //NSLog(@"line: %@",line);
		chunks = [line componentsSeparatedByCharactersInSet: commaNpipe];
		if ([chunks count] < 4) {
			//NSLog(@"Strange Line: %@",chunks);
			continue;
		}
		c = [chunks objectEnumerator];
		line_name = [c nextObject];
		line_start = [[c nextObject] integerValue];
		line_end = [[c nextObject] integerValue];
		line_step = [[c nextObject] integerValue];
		//NSLog(@"%@ %d %d %d",line_name,line_start,line_end,line_step);
		if (num==0) {
			// re work this to set everything, sort keys, then load data??
			start_time = line_start;
			end_time = line_end;
			step_time = line_step;
			[self setHeight: (end_time-start_time)/line_step];
		}
		else {
			/// check if other lines match the first line...???
			if (line_start != start_time || line_end != end_time || line_step != step_time)
				NSLog(@"Differing times: %d!=%d || %d!=%d || %d!=%d \n%@",
							line_start,start_time,line_end,end_time,line_step,step_time,line);
		}
		count=0;
    line_points = [line_data objectForKey: line_name];
    if (line_points == nil)
      line_points = [NSMutableData dataWithCapacity: (height)*sizeof(float)];
		d = (float *)[line_points mutableBytes];
		while ((s = [c nextObject])) {
      if ([s compare: @"None"] == NSOrderedSame)
        count++;
      else
        d[count++] = [s floatValue];
		}
		//NSLog(@"count=%d num=%d height=%d line_data.count=%d",count,num,height,[line_data count]);
		num++;
		[line_data setObject: line_points forKey: line_name];
	}
	return line_data;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection  {
	//NSLog(@"connection Finished: %@ - %d",connection,stage);

	switch (stage) {

		case G_START:
		case G_IDLE:
			NSLog(@"Should not recieve data during IDLE/START stage");
			LOGSTAGE(@"%@:%s finish: len=%ld",name,gstage[stage],[incomingData length]);
			break;

		case G_DATA:
			LOGSTAGE(@"%@:%s finish: len=%ld",name,gstage[stage],[incomingData length]);

			NSDictionary *line_data;
			const float *ld;
			float *d;
			long num;
			NSEnumerator *e;
			NSString *line;
			NSArray *keys;

			NSString *string = [[[NSString alloc] initWithData: incomingData encoding: NSUTF8StringEncoding] autorelease];
			NSArray *lines = [string componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];


			line_data = [self processLines:lines];
			if (sort == 0) {
				keys = [[line_data allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
			}
			else {
				keys = [[line_data allKeys] sortedArrayUsingFunction: numericSort context: nil];
			}

			[self setWidth: [keys count]];
			e = [keys objectEnumerator];

			[dataLock lock];
			[keys retain];
			[Xticks autorelease];
			Xticks = keys;
			num=0;
			d = [data mutableBytes];
			while ((line = [e nextObject])) {
				ld = [[line_data objectForKey:line] bytes];
				memcpy(d + height * num++,ld,height*sizeof(float));
			}
			[self resetMax];
			[dataLock unlock];

			//NSLog(@"Data Done");
			dataValid=YES;
			[[NSNotificationCenter defaultCenter] postNotificationName: @"DataSetUpdate" object: self];
			stage = G_START;
			webConn=nil;
			break;
		case G_ERR:
			NSLog(@"error stage seen");
			stage = G_IDLE;
			break;
		default:
			LOGSTAGE(@"Invalid Stage in state machine: %s",gstage[stage]);
			break;
	}
	[connection autorelease];
	return;
}

-(void)fireTimer:(NSTimer*)aTimer {
	NSLog(@"%@::fireTimer()",[self class]);
	NSURLRequest *req;

    switch (stage) {
		case G_IDLE:
			LOGSTAGE(@"%@:%s begin",name,gstage[stage]);

			//do we need sanitaztion?
			NSString *params = [NSString stringWithFormat: @"?target=%@&format=raw&from=%@&until=%@",query,from,until];
			baseURL = [[NSURL URLWithString: params relativeToURL: graphiteURL] retain];
			NSLog(@"baseURL: %@",baseURL);
			NSLog(@"graphiteURL: %@",graphiteURL);
			stage = G_START;
			//intentional Fall Through to G_START
		case G_START:
			LOGSTAGE(@"%@:%s begin",name,gstage[stage]);
			stage = G_DATA;
			req = [NSURLRequest requestWithURL: baseURL cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 60.0];
			webConn = [[NSURLConnection connectionWithRequest: req delegate: self] retain];
			break;
		default:
			LOGSTAGE(@"%@:Timer Invalid Stage in state machine:%s",name,gstage[stage]);
			break;
	}
	return;
}

- (NSString *)rowTick: (int)row {
	//char *ticks = (char *)[Yticks mutableBytes];
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:start_time+row*step_time];
  return [date descriptionWithCalendarFormat: @"%Y-%m-%d-%H:%M:%S" timeZone: [NSTimeZone defaultTimeZone] locale: nil];
	//return [NSString stringWithUTF8String: ticks+TICK_LEN*row];
}

- (NSString *)columnTick: (int)col {
	if (Xticks)
		return [Xticks objectAtIndex: col];
	else
		return @"No Data Yet";
}
- (void)setQuery: (NSString *)newquery {
	query = [newquery retain];
	stage = G_IDLE;/// what happens if we set this during a data load?
}

- (NSString *)getQuery {
	return query;
}
- (void)setFrom: (NSString*)_from {
	NSLog(@"New From: %@",_from);
	[from autorelease];
	from = [_from retain];
	stage = G_IDLE;
}
- (NSString *)getFrom {
	return from;
}
- (void)setUntil: (NSString*)_until {
	NSLog(@"New until: %@",_until);
	[until autorelease];
	until = [_until retain];
	stage = G_IDLE;
}
- (NSString *)getUntil {
	return until;
}
- (void)setBaseURL: (NSURL *)_url {
	NSLog(@"New URL: %@",_url);
	[from autorelease];
	baseURL = [_url retain];
	stage = G_IDLE;
	//trigger an update?
	[timer fire];
}
- (NSURL *)getBaseURL {
	return baseURL;
}

- (void)setSort:(int) _sort {
	sort = _sort;
	//stage = G_IDLE;
}
- (int)getSort {
  return sort;
}
@end
