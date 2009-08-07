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
#import "XYDataSet.h"

#define NEWLINE @"\n"

NSArray *getStringFields(NSString *str) {
	NSString *s;
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity: 10];
	NSScanner *scn = [NSScanner scannerWithString: str];
	while ([scn scanUpToCharactersFromSet: [NSCharacterSet whitespaceCharacterSet] intoString: &s] == YES) {
		[arr addObject: s];
	}
	return arr;
}

int findStringInArray(NSArray *arr,NSString *str) {
	NSString *s;
	int i,col = -1;
	if (arr)
		for (i=0;i<[arr count];i++) {
			s = [arr objectAtIndex: i];
			if ([s compare: str options: NSCaseInsensitiveSearch] == NSOrderedSame) 
				col = i;
		}
	return col;
}

@implementation XYDataSet
+alloc {
	XYDataSet *s=(XYDataSet *)[super alloc];
	s->xIndex=-1;
	s->yIndex=-1;
	s->colIndex=-1;
	return s;
}
-(void)readHeaders {
	NSString *str;
	NSArray *arr;
	char *ptr;
	char *d;
	long len;
	int i;
	if (!headersRead) {
		//this loads all the data is one chunk..
		rawData = [NSData dataWithContentsOfURL: dataURL];
		len = [rawData length];
		d=(char *)[rawData bytes];	
		for ( ptr=d, i=0; *ptr!='\n' && i<len; ptr++, i++ )
			;

		str = [NSString stringWithCString:d length: i];
		//NSLog(@"Headers String: %@",str);
		arr = getStringFields(str);
		columnCount = [arr count];
		if ([[NSScanner scannerWithString: str] scanCharactersFromSet: [NSCharacterSet letterCharacterSet] intoString: NULL]==YES) {
			//NSLog(@"Header found: %@",str);
			dataStart = i+1;
			headers = [arr retain];
		}
		else {
			dataStart = 0;
		}
		headersRead=YES;
	}
	return;
}


-initWithURL: (NSURL *)url columnNum: (int)col columnXNum: (int)x columnYNum: (int)y {
	theX = [[NSNumber numberWithInt: x] retain];
	theY = [[NSNumber numberWithInt: y] retain];
	xIndex = x;
	yIndex = y;
	return [self initWithURL: url columnNum: col];
}

-initWithURL: (NSURL *)url columnNum: (int)col {
	dataURL = [url retain];
	[self readHeaders];

	if (col < columnCount) {
		theCol = [[NSNumber numberWithInt: col] retain];
		colIndex = col;
		return [self initWithData];
	}
	else {
		NSLog(@"Bad Column Selector: %d > %d",col,columnCount);
		return nil;
	}
}

-initWithURL: (NSURL *)url columnName: (NSString *)col columnXName: (NSString *)x columnYName:(NSString*)y {
	int i;
	dataURL = url; // dont retain here, as the init we call later will do it for us.
	[self readHeaders];
	theX = [x retain];
	theY = [y retain];
	if (headers) {
		i = findStringInArray(headers,x);
		xIndex = i>=0?i:0;
		i = findStringInArray(headers,y);
		yIndex = i>=0?i:1;
	}
	else {
		NSLog(@"Headers missing, will use defaults for X and Y");
		xIndex=0;
		yIndex=1;
	}
	return [self initWithURL: url columnName: col];
}

-initWithURL: (NSURL *)url columnName: (NSString *)col {
	dataURL = [url retain];
	[self readHeaders];

	int c;
	c = findStringInArray(headers,col);
	if (c == -1) {
		NSLog(@"Column '%@' not found in: %@, using default",col,headers);
		c=2;
	}

	theCol = [col retain];
	colIndex = c;
	return [self initWithData];
}
/*
	by the time we get here colIndex,xIndex, and yIndex should be valid. 

	we are going start with a smallish data array, and then grow it as needed by doubling it, then at the end shrink it if needed.
*/
#define FMTBUFLEN 1024
-initWithData {
	int x,y,i,num;
	int MaxX=1,MaxY=1;
	float val;
	NSString *str;
	char *ptr,*end,*sptr;
	char *tmp;
	char format[FMTBUFLEN]="";
	long fmtleft=FMTBUFLEN-1;

	//check for any defaults set in alloc
	if (xIndex==-1) xIndex=0;
	if (yIndex==-1) yIndex=1;
	if (colIndex==-1) colIndex=2;

	[self initWithName: [dataURL absoluteString] Width: 64 Height: 64];

	float *d = (float *)[data mutableBytes];
	char *s = (char *)[rawData bytes];
	ptr = s+dataStart;
	end = s+[rawData length];

	//NSLog(@"Keys: %d %d %d %d",xIndex,yIndex,colIndex,columnCount);
	while (ptr < end) {
		for (i=0;i<columnCount && ptr<end;i++) {
			sptr=ptr;
			if (i==xIndex)
				x = strtol(ptr,&ptr,10);
			else if (i==yIndex) 
				y = strtol(ptr,&ptr,10);
			else if (i==colIndex) 
				val = strtod(ptr,&ptr);
			else
				strtod(ptr,&ptr);
			if (sptr==ptr) {
				//NSLog(@"eat bad: %p '%x'",ptr,*ptr);
				ptr++; //eat bad input
			}
		}
		if (x>width || y>height) {
			d=[self expandDataSetForX: x andY: y];
		}
		MaxX=MAX(MaxX,x);
		MaxY=MAX(MaxY,y);
		d[x+y*width]=val;
		//if (y==0)
		//NSLog(@"scan: %p %p %d %d %f",ptr,end,x,y,val);
	}
	d=[self contractDataSetForX: MaxX+1 andY: MaxY+1];//base zero

	//NSLog(@"Scan Done");
	d[50+600*width]=5.0;
	currentScale = 128.0/10;
	[self lockMax: 10];

	return self;
}
-(float *)expandDataSetWidth: (int)w andHeight: (int)h;

-(float *)expandDataSetForX: (int)x andY: (int)y {
	int nw,nh;
	int r;
	float *d;
	
	nw=width;
	while (w>nw)
		nw*=2;
	nh=height;
	while (h>nh)
		nh*=2;
//	NSLog(@"expand: %d %d %d %d %d %d",x,width,nw,y,height,nh);
	
	if (nw!=width || nh!=height) {
		[data setLength: sizeof(float)*nw*nh];
		d = [data mutableBytes];
		
		if (nw!=width) {
			for (r=height-1;r>0;r--) {
				memcpy(d+r*nw,d+r*width,sizeof(float)*width);
				memset(d+r*width,0,sizeof(float)*(nw-width));
			}
		}
		height=nh;
		width=nw;
	}
	return d;
}

-(float *)contractDataSetWidth: (int)w andHeight: (int)h;
	int nw,nh;
	int r;
	float *d;

	nw=w;
	nh=h;

	if (nw!=width || nh != height) {
		//NSLog(@"contract: %d %d %d  %d %d %d",x,width,nw,y,height,nh);
#if 0
		//This seems backwards compared to the expand, but this works..
		if ( nh!=height) {
			d = [data mutableBytes];

			for (r=1;r<width;r++) 
				memcpy(d+r*nh,d+r*height,sizeof(float)*nh);
		}
#else
		if ( nw!=width) {
			d = [data mutableBytes];

			for (r=1;r<height;r++) 
				memcpy(d+r*nw,d+r*width,sizeof(float)*nw);
		}
#endif
		[data setLength: sizeof(float)*nw*nh];
		width=nw;
		height=nh;
	}
	return [data mutableBytes];

}

- autoScale {
	//figure out a scaling that will make the data be <limit> 'high'..  could be configuarable.
	int i;
	float u;
	float *d = (float *)[data mutableBytes];
	
	
		for (i=0;i<width*height;i++) {
			u=(d[i]*currentScale);
			u=MIN(129.0,MAX(u,0.0));
			d[i] = u;
		}
	return self;
}

-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);

	[super initWithPList: list];

	NSURL *url = [NSURL URLWithString: [list objectForKey: @"baseURL"]];
	id col = [list objectForKey: @"column"];

	if ([col isKindOfClass: [NSNumber class]]) {
		[self initWithURL: url columnNum: [(NSNumber *)col intValue]];
	}
	else {	///@todo check for string and error out?
		[self initWithURL: url columnName: col];
	}

	return self;
}

-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [super getPList];
	[dict setObject: dataURL forKey: @"dataURL"];
	[dict setObject: theCol forKey: @"column"];
	if (theX)
		[dict setObject: theX forKey: @"X"];
	if (theY)
		[dict setObject: theY forKey: @"Y"];
	return dict;
}

-(void)dealloc {
	NSLog(@"dealloc %@:%@",[self class],name);
	[dataURL autorelease];
	[theX autorelease];
	[theY autorelease];
	[theCol autorelease];
	[headers autorelease];
	[rawData autorelease];
	[super dealloc];
}

@end
