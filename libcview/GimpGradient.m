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

#import "cview.h"
typedef enum { BLEND_LINEAR=0, BLEND_CURVED, BLEND_SINUSOIDAL,
				BLEND_SPERICAL_INCREASING, BLEND_SPERICAL_DECREASING } BlendType;
typedef enum { CT_FIXED=0, CT_FG, CT_FGT, CT_BG, CT_BGT } ColorType;
@interface GimpSegment: NSObject {
	@public
	float left,mid,right;
	float leftRGBA[4];
	float rightRGBA[4];
	BlendType blend;
	ColorType colortype,leftcolortype,rightcolortype;
}
/**should be a string with 15 numbers*/
-initWithString: (NSString *)str;
/**is a float with the segment */
-(BOOL)inside: (float)i;
@end

@implementation GimpSegment
-initWithString: (NSString *)str {
    NSScanner *scan = [NSScanner scannerWithString: str];
    BOOL error=NO;
    if ( ! [scan scanFloat: &left] ) error=YES;
    if ( ! [scan scanFloat: &mid] ) error=YES;
    if ( ! [scan scanFloat: &right] ) error=YES;
    if ( ! [scan scanFloat: &leftRGBA[0]] ) error=YES;
    if ( ! [scan scanFloat: &leftRGBA[1]] ) error=YES;
    if ( ! [scan scanFloat: &leftRGBA[2]] ) error=YES;
    if ( ! [scan scanFloat: &leftRGBA[3]] ) error=YES;
    if ( ! [scan scanFloat: &rightRGBA[0]] ) error=YES;
    if ( ! [scan scanFloat: &rightRGBA[1]] ) error=YES;
    if ( ! [scan scanFloat: &rightRGBA[2]] ) error=YES;
    if ( ! [scan scanFloat: &rightRGBA[3]] ) error=YES;
    if ( ! [scan scanInt: (int*)&blend] ) error=YES;
    if ( ! [scan scanInt: (int*)&colortype] ) error=YES;
    if ( ! [scan scanInt: (int*)&leftcolortype] ) error=YES;
    if ( ! [scan scanInt: (int*)&rightcolortype] ) error=YES;

    if (error) {
        NSLog(@"Bad Segment Parse: %@",str);
        return nil;
    }
	return self;
}

-description {
    return [NSString stringWithFormat: @"Segment: %f %f %f %f-%f-%f-%f %f-%f-%f-%f %d %d %d",
            left,mid,right,
            leftRGBA[0],leftRGBA[1],leftRGBA[2],leftRGBA[3],
            rightRGBA[0],rightRGBA[1],rightRGBA[2],rightRGBA[3],
            blend,colortype,leftcolortype,rightcolortype];
}
-(BOOL)inside: (float)i {
    return (left <= i &&  i <= right);
}  
@end

@implementation GimpGradient
-init {
	source = FROMNONE;
	return self;
}

-initWithFile: (NSString*)filename {
    NSLog(@"initWithFile: %@",filename);
    NSString *linestring = [NSString stringWithContentsOfFile: filename];
	
    source = FROMFILE;
    lastcolor = -1.0;
    dataSource = [filename retain];
    
    return [self parseGGR: linestring];
}

-initWithString: (NSString*)string {
    
    source = FROMSTRING;
    lastcolor = -1.0;
    dataSource = [string retain];
    
	return [self parseGGR:string];
}

-getPList {
	NSString *from;
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];

	if (source == FROMSTRING)
		from = FROMSTRING_STRING;
	else if (source == FROMFILE)
		from = FROMFILE_STRING;
	else {
		NSLog(@"Invalid From Type: %d",source);
		return nil;
	}

	[dict setObject: from forKey: @"source"];
	[dict setObject: dataSource forKey: @"gradient"];
	return dict;
}

-initWithPList: (id)list {
	NSString *from;
	NSLog(@"initWithPList: %@",[self class]);
	
	from = [list objectForKey: @"source"];
	dataSource = [list objectForKey: @"gradient"];
	NSLog(@"GGR: %@ %@",from,dataSource);
	
	if ([from compare: FROMSTRING_STRING] == NSOrderedSame) {
		return [self initWithString: dataSource];
	}
	else if ([from compare: FROMFILE_STRING] == NSOrderedSame) {
		return [self initWithFile: find_resource_path(dataSource)];
	}
	else {
		NSLog(@"Bad Source in GGR:%@",from);
		return nil;
	}
}

-parseGGR: (NSString *)ggr {
    NSArray *lines = [ggr componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"\n"]];
	NSString *line;
    NSEnumerator *e;
    GimpSegment *gs;
    int n;
    
    //NSLog(@"parse: %@",lines);
    
    e=[lines objectEnumerator];
    
    line = [e nextObject];
    if ( [line compare: @"GIMP Gradient"] != NSOrderedSame ) {
        NSLog(@"Error reading Gimp Header string");
        return nil;
    }
    
    line = [e nextObject];
    if ([[line substringToIndex: 6] compare: @"Name: "] != NSOrderedSame ) {
        NSLog(@"Error reading Name of GGR");
        return nil;
    }
    name = [[line substringFromIndex: 6] retain];
    
    line = [e nextObject];
    n = [line intValue];
    NSLog(@"GGR: %@ Segs: %d",name,n);
    
    segments = [[NSMutableArray arrayWithCapacity: n] retain];
    while ( (line=[e nextObject]) ) {
        if ([line length]<1)
            continue;
        gs = [[GimpSegment alloc] initWithString: line];
        if (!gs) {
            continue;
        }
        [segments addObject: gs];
        [gs autorelease];
    }
    return self;
}

-interpolateColor: (float)i {
    NSEnumerator *e;
    GimpSegment *gs;
    float mid,pos,f;
    int j;
    
    if ( i != lastcolor ) {
        //find segment
        e = [segments objectEnumerator];
        while ( (gs = [e nextObject])) {
            if ([gs inside:i]) {
                break;
            }
        }
        if (gs == nil) {
            NSLog(@"No segment found: %f",i);
            memset(lastRGBA,0,4*sizeof(float));
        }
        else {  // valid segment
            //NSLog(@"Segment found: %@",gs);
            
            mid = (gs->mid - gs->left) / (gs->right - gs->left);
            pos = (i - gs->left) / (gs->right - gs->left);
            
            if (pos <= mid)
            	f = 0.5*pos/mid;
            else
            	f = 0.5*(pos-mid)/(1-mid) + 0.5;
            
            switch (gs->blend) {
            	case BLEND_LINEAR:
            		break;
            	case BLEND_CURVED:
            		f = powf(pos,log(0.5)/log(mid));
            		break;
            	case BLEND_SINUSOIDAL:
            		f = 0.5 * (sin(M_PI*(f-0.5))+1);
            		break;
            	case BLEND_SPERICAL_INCREASING:
            		f -= 1;
            		f = sqrt(1 - f*f);
            		break;
            	case BLEND_SPERICAL_DECREASING:
            		f = 1 - sqrt(1 - f*f);
            		break;
            
            	default:
            		NSLog(@"Unsupported GGR blend function");
            		break;
            }
            
            //only do RGBA segment space.
            for (j=0;j<4;j++) {
            	lastRGBA[j] = gs->leftRGBA[j] +( gs->rightRGBA[j] - gs->leftRGBA[j] ) * f;
            }
        }
    }
    return self;
}

-(float)getR: (float)i {
    [self interpolateColor: i];
	return lastRGBA[0];
}
-(float)getG: (float)i {
    [self interpolateColor: i];
	return lastRGBA[1];
}
-(float)getB: (float)i {
    [self interpolateColor: i];
	return lastRGBA[2];
}
-(float)getA: (float)i {
    [self interpolateColor: i];
	return lastRGBA[3];
}
-putRGBA: (float)i into: (float*)array {
    [self interpolateColor: i];
    memcpy(array,lastRGBA,sizeof(float)*4);
	return self;
}

-(void)dealloc {
    NSLog(@"dealloc %@:%@",[self class],name);
    [name autorelease];
    [segments autorelease];
    [dataSource autorelease];
    [super dealloc];
}

-description {
    return [NSString stringWithFormat: @"GimpGradient: %@ -> %@",name,segments];
}
@end


