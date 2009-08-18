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
	by the time we get here colIndex,xIndex, and yIndex should be valid, else defaults will be used. 

	we are going start with a smallish data array, and then grow it as needed by doubling it, then at the end shrink it if needed.
*/

-initWithData {
	int x,y,i;
	int MaxX=1,MaxY=1;
	float val;
	char *ptr,*end,*sptr;

	//check for any defaults set in alloc
	if (xIndex==-1) xIndex=0;
	if (yIndex==-1) yIndex=1;
	if (colIndex==-1) colIndex=2;

	[self initWithName: [NSString stringWithFormat: @"%@-%@", [dataURL absoluteString],theCol] Width: 2 Height: 2];

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
		if (x>=width || y>=height) {
			d=[self expandDataSetWidth: x+1 andHeight: y+1];
		}
		MaxX=MAX(MaxX,x);
		MaxY=MAX(MaxY,y);
		d[x+y*width]=val;
		//if (y==0)
		//NSLog(@"scan: %p %p %d %d %f",ptr,end,x,y,val);
	}
	NSLog(@"XYDataSet Max: %d %d",MaxX,MaxY);
	d=[self contractDataSetWidth: MaxX+1 andHeight: MaxY+1];//base zero

	//NSLog(@"Scan Done");
	[self autoScale];

	return self;
}

-(float *)expandDataSetWidth: (int)w andHeight: (int)h {
	int nw,nh;
	int r;
	float *d;
	int sw,sh;
	sw=width;
	sh=height;
	
	nw=width;
	while (w>nw)
		nw*=2;
	nh=height;
	while (h>nh)
		nh*=2;
	//NSLog(@"expand: %d %d %d    %d %d %d",w,width,nw,h,height,nh);
	
	if (nw!=width || nh!=height) {
		[data setLength: sizeof(float)*nw*nh];
		d = [data mutableBytes];
		
		if (nw!=width) {
			for (r=height-1;r>0;r--) {
				memcpy(d+r*nw,d+r*width,sizeof(float)*(width));
				memset(d+r*width,0,sizeof(float)*(nw-width));
			}
		}
		height=nh;
		width=nw;
	}
	return d;
}

-(float *)contractDataSetWidth: (int)w andHeight: (int)h {
	int nw,nh;
	int r;
	float *d;

	nw=w;
	nh=h;

	if (nw != width || nh != height) {
		//NSLog(@"contract: %d %d %d  %d %d %d",w,width,nw,h,height,nh);
#if 1
		//This seems backwards compared to the expand, but this works..
		if (nh != height) {
			d = [data mutableBytes];

			for (r=1;r<width;r++) {
				//NSLog(@"%d %d",r*nh,r*height);
				memcpy(d+r*nh,d+r*height,sizeof(float)*nh);
			}
		}
#else
		if (nw != width) {
			d = [data mutableBytes];

			for (r=1;r<height;r++) {
				//NSLog(@"%d %d",r*nw,r*width);
				memcpy(d+r*nw,d+r*width,sizeof(float)*nw);
			}
		}
#endif
		[data setLength: sizeof(float)*nw*nh];
		width=nw;
		height=nh;
	}
	return [data mutableBytes];

}

-(int)convertTagToIndex:(NSString *)col {
	int index=-1;
	NSLog(@"%@",col);
	
	index = findStringInArray(headers, (NSString *)col);

	if (index==-1) 
		index = [col intValue];
	
	return index;
}	

-initWithPList: (id)list {
	id tmp;
	NSLog(@"initWithPList: %@",[self class]);

	[super initWithPList: list];

	dataURL = [NSURL URLWithString: [list objectForKey: @"dataURL"]];
	theCol = [list objectForKey: @"column"]; //required field
	[self readHeaders];
	
	colIndex = [self convertTagToIndex: theCol];
				  
	if (colIndex==-1) {
		NSLog(@"Error finding Column Tag in plist");
		return nil;
	}

	tmp = [list objectForKey:@"X"];
	if (tmp) {
		theX = tmp;
		xIndex = [self convertTagToIndex: theX];
	}

	tmp = [list objectForKey:@"Y"];
	if (tmp) {
		theY = tmp;
		yIndex = [self convertTagToIndex: theY];
	}

	return [self initWithData];
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
