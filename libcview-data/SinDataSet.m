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
#import "SinDataSet.h"
#import "math.h"

@implementation SinDataSet
-initWithName: (NSString *)key Width: (int)w Height: (int)h interval: (float)timer;{
	[super initWithName: key Width: w Height: h];
	dx=0.0;
	rateSuffix=@"Nums";
	currentMax=100.0;
	
	[[UpdateRunLoop runLoop] addTimer: 
								[[NSTimer alloc] initWithFireDate: [NSDate dateWithTimeIntervalSinceNow: 1] 
								 interval: timer 
								 target:self 
								 selector: @selector(fireTimer:) 
								 userInfo:nil 
								 repeats:YES]
						 forMode: NSDefaultRunLoopMode];

	return self;
}

- initWithWidth: (int)w Height: (int)h interval: (float)timer {
	return [self initWithName: @"Sin()" Width: w Height:h interval: timer];
}

-fireTimer: (NSTimer *)timer {
	int i,j;
	float *d;
	dx += 0.1;
	for (i=0;i<width;i++) {
		d = [self dataRow: i];
		for (j=0;j<height;j++)
			d[j]=50*sin(j/10.0+i*0.1+dx)+50.0;
		d[j-1]=100;
	}
	d = [self dataRow: 0];
	for (j=0;j<height;j++)
			d[j]=50;

	[[NSNotificationCenter defaultCenter] postNotificationName: @"DataSetUpdate" object: self];
	return NO;
}

-initWithPList: (id)list {
	int w,h;
	NSLog(@"initWithPList: %@",[self class]);

	w = [[list objectForKey: @"width"] intValue];
	h = [[list objectForKey: @"height"] intValue];
	dx = [[list objectForKey: @"dx"] intValue];

	[super initWithWidth: w Height: h];
	return self;
}

-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [super getPList];
	[dict setObject: [NSNumber numberWithInt: width] forKey: @"width"];	
	[dict setObject: [NSNumber numberWithInt: height] forKey: @"height"];	
	[dict setObject: [NSNumber numberWithInt: dx] forKey: @"dx"];	

	return dict;
}

-(NSArray *)attributeKeys {
	return [NSArray arrayWithObjects: @"dx",nil];
}

-(void)dealloc {
	NSLog(@"dealloc SinDataSet:%@",name);
	[super dealloc];
}

- (NSString *)columnTick: (int)col {
	float f = dx+col/100.0;
	return [NSString stringWithFormat: @"Sin(%f) = %f",f,sin(f)];
}

@end /* SinDataSet */

