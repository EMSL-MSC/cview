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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#import "cview-data.h"
#import "debug.h"

#define NEWLINE @"\n"

@implementation StreamDataSet

-initWithCommand: (NSString *)cmd arguments: (NSArray *)args {
	return [self initWithCommand: cmd arguments: args depth: DEFAULT_DEPTH];
}

-initWithCommand: (NSString *)cmd arguments: (NSArray *)args depth: (int)d {
	NSArray *arr=nil,*headers=nil;
	int i;
	BOOL nodata;
	NSNull *n;

	//1. Start command Stream
	command = [cmd retain];
	arguments = [args retain];
	theTask = [[NSTask alloc] init];
	[theTask setArguments: arguments];
	[theTask setLaunchPath: command];
	thePipe = [[NSPipe pipe] retain];
	[theTask setStandardOutput: thePipe];
	theFile = [thePipe fileHandleForReading];
	[theTask launch];

	//2. Read first line of data to detemine width of dataStart
	remainingData = [[NSMutableData dataWithCapacity:1024] retain];
	i=10;
	nodata = YES;
	while (nodata && i > 0) {
		arr=[self getNextLineArray];
		//NSLog(@"Line: %@",arr);
		switch ([self getRowType:arr]) {
			case ROW_HEADER:
				headers = arr;
				break;
			case ROW_DATA:
				nodata=NO;
				break;
			default:
				break;
		}
		i--;
	}

	//3. initialze superclass.
	[super initWithName: command Width: ([arr count]-1) Height: d];
	Yticks = [[NSMutableArray arrayWithCapacity: d] retain];
	for (i=0;i<d;i++)
		[Yticks addObject: @"None"];
	Xticks = [[NSMutableArray arrayWithCapacity: [arr count]] retain];
	meta = [[NSMutableArray arrayWithCapacity: [arr count]] retain];
	n = [NSNull null];
	for (i=0;i<[arr count];i++) {
		[Xticks addObject: [NSString stringWithFormat: @"Col %d",i]];
		[meta addObject: [NSMutableDictionary dictionaryWithCapacity: 4]];
	}

	//4. insert first row of data
	[self addRow: arr];
	if ([headers count]-1 == [arr count]) {
		[self addRow: headers];
	}


	//5. Start thread to read rest of data.
	running = YES;
	[NSThread detachNewThreadSelector: @selector(run:) toTarget: self withObject: nil];

	return self;
}

-(RowTypeEnum)getRowType: (NSArray *)arr {
	//1. blank line
	if ([arr count] == 0)  {
		return ROW_BLANK;
	}
	//2. header line
	else if ([(NSString *)[arr objectAtIndex: 0] compare: @"#"] == NSOrderedSame) {
		return ROW_HEADER;
	}
	//3. info line
	else if ([(NSString *)[arr objectAtIndex: 0] compare: @"$"] == NSOrderedSame) {
		return ROW_META;
	}
	//4. data line
	else if ([arr count]>0) {
		return ROW_DATA;
	}
	else
		return ROW_CRAP;
}

-addRow: (NSArray *)arr {
	float *d;
	int i;
	NSEnumerator *e;
	NSString *str,*host,*key;
	NSNumber *num;
	NSMutableDictionary *info;

	switch ([self getRowType: arr]) {
		case ROW_HEADER:
			e=[arr objectEnumerator];
			[e nextObject];
			[e nextObject];
			i=0;
			while ((str = [e nextObject]) != nil) {
				[Xticks insertObject: str atIndex: i ];
				i++;
			}
			break;
		case ROW_META:
			if ([arr count] == 4) {
				e=[arr objectEnumerator];
				[e nextObject];
				host = [e nextObject];
				key = [e nextObject];
				num = [NSNumber numberWithInt: [(NSString *)[e nextObject] intValue]];
				NSLog(@"meta info: %@ %@ %@",host,key,num);
				i = [Xticks indexOfObject:host];
				if (i != NSNotFound) {
					info = [meta objectAtIndex: i];
					[info setObject: num forKey: key];
				}
				else
					NSLog(@"bad meta host: %@",host);
			}
			break;
		case ROW_DATA:
			[self shiftData: 1];
			d = [data mutableBytes];
			e=[arr objectEnumerator];
			str = (NSString *)[e nextObject];
			[Yticks insertObject: str atIndex: 0];
			[Yticks removeLastObject];

			i=0;
			while ((str = [e nextObject]) != nil) {
				d[i*height+0] = [str floatValue]*currentScale;
				i++;
			}
			[self autoScale];
			break;
		default:
			NSLog(@"Bad Row Seen: %@",arr);
			break;
	}
	return self;
}

-(NSArray *)getNextLineArray {
	NSArray * arr;
	NSString *str;
	NSData * d;

	d = [self getNextLine];
	if (d != nil) {
		str = [NSString stringWithUTF8String:[d bytes]];
		arr=getStringFields(str);
		//NSLog(@"array: %@",arr);
		return arr;
	}
	return nil;
}

-(NSData *)getNextLine {
	NSRange range;
	NSData *linedata,*newdata;
	char *d,*newline;
	int len,i,count;
	///@todo error handling

	@try {
		//while line not found:
		count=20;
		while (count--) {
			//NSLog(@"data: %@",remainingData);
		//  search for newline in remainingData
			len = [remainingData length];
			d = (char *)[remainingData bytes];
			newline=memchr(d,'\n',len);

			if (newline) {
				i=newline-d;
		//    save extra data
				range.location = 0;
				range.length = ++i; //hold onto the newline
				linedata = [remainingData subdataWithRange: range];
				d=(char *)[linedata bytes];
				d[[linedata length]-1]=0; //switch newline to null byte
				range.location = i;
				range.length = len-i;
				newdata = [remainingData subdataWithRange: range];
				[remainingData autorelease];
				remainingData = [[NSMutableData dataWithData: newdata] retain];
				return linedata;
			}
		// get more data, blocking if necessary
			newdata = [theFile availableData];
			if (newdata != nil && [newdata length] > 0 ) {
				[remainingData appendData: newdata];
			}
			else {
				return nil;
			}
		}
	}
	@catch (NSException *localException) {
		NSLog(@"Error: %@", localException);
	}
	return nil;
}

-(void)run:(id)args {
	int count;
	NSArray *arr;
	NSAutoreleasePool *tpool = [[NSAutoreleasePool alloc] init];

	count=0;
	while (running) {
		arr = [self getNextLineArray];
		if (arr == nil) {
			running = NO;
		}
		else {
			[self addRow:arr];
		}


		[[NSNotificationCenter defaultCenter] postNotificationName: @"DataSetUpdate" object: self];

		if (count++ >= 1000 ) {
			[tpool release];
			tpool = [[NSAutoreleasePool alloc] init];
			DUMPALLOCLIST(YES);
			count=0;
		}
	}
	[tpool release];
	return;
}

- (NSString *)rowTick: (int)row {
	return [Yticks objectAtIndex:row];
}

- (NSString *)columnTick: (int)col {
	return [Xticks objectAtIndex:col];
}

- (NSDictionary *)columnMeta: (int)row {
	return [meta objectAtIndex: row];
}

-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
	NSString *cmd;
	NSString *str;
	NSArray *arr;
	int d;

	[super initWithPList: list];

	cmd = [list objectForKey:@"command" missing: @"echo"];
	arr = [list objectForKey:@"arguments" missing: [NSArray arrayWithObjects: nil]];
	d = [[list objectForKey:@"depth" missing: S(DEFAULT_DEPTH)] intValue];

	[self initWithCommand: cmd arguments: arr depth:d ];
	/*fixup the name if needed */
	str = [list objectForKey:@"description"];
	if (str != nil)
		[self setDescription: str];

	return self;
}

-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [super getPList];

	[dict setObject: command forKey: @"command"];
	[dict setObject: arguments forKey: @"arguments"];
	[dict setObject: textDescription forKey: @"description"];
	if (height != DEFAULT_DEPTH)
		[dict setObject: [NSNumber numberWithInt: height] forKey: @"depth"];
	return dict;
}

-(void)dealloc {
	NSLog(@"dealloc %@:%@",[self class],name);
	[command autorelease];
	[arguments autorelease];
	if ([theTask isRunning])
		[theTask terminate];
	[theTask autorelease];
	[thePipe autorelease];
	[Yticks autorelease];
	[Xticks autorelease];
	[meta autorelease];
	[remainingData autorelease];
	[super dealloc];
}

@end
