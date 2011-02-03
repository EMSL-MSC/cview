/*

This file is part of the CVIEW graphics system, which is goverened by the following License

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
#import "GLInfinibandNetwork.h"
#import "ListComp.h"
#import "DictionaryExtra.h"
static float box_quads[72] = {
0.0 , 1.0 , 0.0 , 1.0 , 1.0 , 0.0 , 1.0 , 1.0 , 1.0 , 0.0 , 1.0 , 1.0 , //Top  keep here.
0.0 , 0.0 , 1.0 , 0.0 , 1.0 , 1.0 , 1.0 , 1.0 , 1.0 , 1.0 , 0.0 , 1.0 , //Back
0.0 , 0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 1.0 , 0.0 , 1.0 , 1.0 , 0.0 , 0.0 , //Bottom
0.0 , 0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 1.0 , 1.0 , 0.0 , 0.0 , 1.0 , //Left
1.0 , 0.0 , 0.0 , 1.0 , 0.0 , 1.0 , 1.0 , 1.0 , 1.0 , 1.0 , 1.0 , 0.0 , //Right
0.0 , 0.0 , 0.0 , 1.0 , 0.0 , 0.0 , 1.0 , 1.0 , 0.0 , 0.0 , 1.0 , 0.0 , //Front Face
};

//Scan a nodemapfile..  format is: GUID "text" where GUID is a hex code witha a 0x preceding it.
// skip blank lines..
// anything that starts with # is a comment, ignore line.
// This really should be done with a Parser Class of some type that is not avalable in NSScanner or NSString
NSDictionary *scanNodeMapFile(NSFileHandle *file) {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSData *data = [file readDataToEndOfFile];
	NSString *linestring = [NSString stringWithCString: [data bytes] length: [data length]];
	NSArray *lines = [linestring componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"\n"]];
	NSString *line,*guid,*label;
	NSEnumerator *e;
	
	e = [lines objectEnumerator];
	while ( (line = [e nextObject] ) ) {
		//look for '#' and empty lines
		if ( [line hasPrefix: @"#"] || [line length]==0)
			continue;
		
		//verify the line looks like we want it to
		if ([line hasPrefix: @"0x"] && 
			[line hasSuffix: @"\""] &&
		    [line compare: @" \"" options: NSLiteralSearch range: NSMakeRange(15,2)] == NSOrderedSame ) {
			   guid = [line substringWithRange: NSMakeRange(0,15)];
			   label = [line substringWithRange: NSMakeRange(17,[line length]-18)];
			   //NSLog(@"%@,%@",guid,label);
			   [dict setObject:guid forKey: label];
		}
		//NSLog(@"%@",line);
	}
	return dict;
}

@interface IBChassis:DrawableObject <PList> {
	NSString *type;
	float locx,locy,locz;
	flts reference[4];
	float rotx,roty,rotz;
}
-(id)populateGraph: (Graph *)g nodeMap: (NSDictionary *)map;
-(NSString *)getLinePortKeyX: (int)x Y: (int)y nodeMap: (NSDictionary *)map;
-(NSString *)getFabricPortKey: (int)x Y: (int)y Port: (int)p nodeMap: (NSDictionary *)map;
-(flts *)getGLRef;
@end

@interface IBPort:DrawableObject {
	IBChassis *chassis;
	float colorR;
	float colorG;
	float colorB;
@public
	float x,y,z;
	float w,h;
}
-(void)glVertex;
-(id)setChassis: (IBChassis *)c;
-(id)setColorR: (float)r G: (float)g B: (float)b;
@end

@interface IBLink : NSObject
{
	int value;
}
+(IBLink *)link;
-(id)setValue:(int)i;
-(int)getValue;
@end

@implementation IBLink
/** returns an autoreleased IBLink object with a 0 value */
+(IBLink *)link {
	return [[[IBLink alloc] init] autorelease];
}
-(id)setValue:(int)i {
	value=i;
	return self;
}
-(int)getValue {
	return value;
}
@end


@implementation IBPort 
-(id)init {
	[super init];
	colorR=1.0;
	colorG=0.0;
	colorB=0.0;
	return self;
}
-(id)setChassis: (IBChassis *)c {
	[c retain];
	[chassis autorelease];
	chassis=c;
	return self;
}

-(void)dealloc {
	[chassis autorelease];
	[super dealloc];
}

-(void)glVertex {
	flts v,r,*c;
	v.f[0]=x+w/2.0;
	v.f[1]=y+h/2.0;
	v.f[2]=z;
	v.f[3]=1.0;

	c=[chassis getGLRef];
	r=multQbyV(c,v);
	//NSLog(@"V");
	//dumpV(v);
	//NSLog(@"M");
	//for (i=0;i<4;i++)
	//	dumpV(c[i]);
	//NSLog(@"R");

	//dumpV(r);
	glVertex4fv((GLfloat *)&r.f);

//	glVertex3f(x+w/2.0,y+h/2.0,z);
//	NSLog(@"%f %f %f",x+w/2.0,y+h/2.0,z);
}


-(id) glDraw {
	flts *m = [chassis getGLRef];
	
	glPushMatrix();
	//glVertexPointer(3, GL_FLOAT, 0, box_quads);
	glLoadMatrixf((GLfloat*)m);
		

	glColor3f(colorR,colorG,colorB);
	glBegin(GL_LINE_LOOP);
	glVertex3f(x,y,z);
	glVertex3f(x+w,y,z);
	glVertex3f(x+w,y+h,z);
	glVertex3f(x,y+h,z);
	glEnd();

	glPopMatrix();
	/*end bounding*/
		
	return self;
}

-(id)setColorR: (float)r G: (float)g B: (float)b {
	colorR=r;
	colorG=g;
	colorB=b;
	return self;
}
@end

@implementation IBChassis
-(id)getPList {
	NSMutableDictionary *list = [super getPList];
	[list setObject: type forKey: @"type"];
	#define SD(x,k) [list setObject: [NSNumber numberWithFloat: x] forKey: k];
	SD(rotx,@"rotx");
	SD(roty,@"roty");
	SD(rotz,@"rotz");
	SD(locx,@"locx");
	SD(locy,@"locy");
	SD(locz,@"locz");
	#undef SD
	return list;
}

-(id)initWithPList: (id)list {
	[super initWithPList: list];
	type = [[list objectForKey: @"type" missing: @"ISR2012"] retain];
	#define GD(x,k,m) x=[[list objectForKey: k missing: m] floatValue]
	GD(rotx,@"rotx",@"0.0");
	GD(roty,@"roty",@"0.0");
	GD(rotz,@"rotz",@"0.0");
	GD(locx,@"locx",@"0.0");
	GD(locy,@"locy",@"0.0");
	GD(locz,@"locz",@"0.0");
	#undef GD
	return self;
}

-(NSArray *)attributeKeys {
	//isVisible comes from the DrawableObject
	return [NSArray arrayWithObjects: @"locx",@"locy",@"locz",@"rotx",@"roty",@"rotz",nil];
}

-(void)dealloc {
	[type autorelease];
	[super dealloc];
}

-(id)populateGraph: (Graph *)g nodeMap: (NSDictionary *)map {
	//add all the ports..
	int i,j,p;
	float pw,ph,spw,fpw;
	IBPort * port;
	NSString *s;
	
	if ([type compare: @"ISR2012" ] == NSOrderedSame) {
		pw = 300.0/12;
		ph = 300.0/24;
		spw = 100.0/12;

		//fabric ports
		for (i=0;i<12;i++)
			for (j=0;j<24;j++) {
				//Front Port
				port = [[[IBPort alloc] init] autorelease];
				port->x = i*pw+0.5;
				port->y = (24-j)*ph+0.5;
				port->z = 0;
				port->w = pw-1;
				port->h = ph-1;
				[port setChassis: self];
				s = [self getLinePortKeyX: i Y: j nodeMap: map];
				[g addVertex: s withInfo: port];
				//switch back port
				port = [[[IBPort alloc] init] autorelease];
				port->x = 100+i*spw+0.5;
				port->y = (24-j)*ph+0.5;
				port->z = 90.5;
				port->w = spw-1;
				port->h = 4;
				[port setChassis: self];
				s = [self getLinePortKeyX: i+12 Y: j nodeMap: map];
				[g addVertex: s withInfo: port];
			}
			
		//Fabric Switches
		fpw=65.0/24;
		for (i=0;i<4;i++)
			for (j=0;j<3;j++) {
				/*glVertex3f(5+i*75,50+j*100.0,210);
				glVertex3f(70+i*75,50+j*100.0,210);
				glVertex3f(70+i*75,50+j*100.0,240);
				glVertex3f(5+i*75,50+j*100.0,240);      WTF*/
				for (p=0;p<24;p++) {
					port = [[[IBPort alloc] init] autorelease];
					port->x = 5+i*75+fpw*p+0.5;
					port->y = 50+j*100+0.5;
					port->z = 210;
					port->w = fpw-1;
					port->h = 4;
					[port setChassis: self];
					s = [self getFabricPortKey: i Y: j Port: p nodeMap: map];
					[g addVertex: s withInfo: port];
				}
			}
	}
	
	if ([type compare: @"TEST040208" ] == NSOrderedSame) {
		pw = 40.0/4;
		ph = 40.0/4;
		spw = 30.0/4;

		for (i=0;i<4;i++)
			for (j=0;j<4;j++) {
				//Front Port
				port = [[[IBPort alloc] init] autorelease];
				port->x = i*pw+0.5;
				port->y = (4-j)*ph+0.5;
				port->z = 0;
				port->w = pw-1;
				port->h = ph-1;
				[port setChassis: self];
				s = [NSString stringWithFormat: @"%@-%d",[map objectForKey: [NSString stringWithFormat: @"%@L%d",name,j+1]],i+5];
				//NSLog(@"FP: %@ %@",s,port);
				[g addVertex: s withInfo: port];
				//switch back port
				port = [[[IBPort alloc] init] autorelease];
				port->x = 5+i*spw+0.5;
				port->y = (4-j)*ph+0.5;
				port->z = 15.5;
				port->w = spw-1;
				port->h = 4;
				[port setChassis: self];
				s = [NSString stringWithFormat: @"%@-%d",[map objectForKey: [NSString stringWithFormat: @"%@L%d",name,j+1]],1+i];
				//NSLog(@"BP: %@ %@",s,port);
				[g addVertex: s withInfo: port];
			}
			
		//Fabric Switches
		fpw=30.0/8;
		for (i=0;i<1;i++)
			for (j=0;j<2;j++) {
				for (p=0;p<8;p++) {
					port = [[[IBPort alloc] init] autorelease];
					port->x = 5+i*20+fpw*p+0.5;
					port->y = 10+j*10+0.5;
					port->z = 25;
					port->w = fpw-1;
					port->h = 4;
					[port setChassis: self];
					s = [NSString stringWithFormat: @"%@-%d",[map objectForKey: [NSString stringWithFormat: @"%@F%d",name,j+1]],p+1];
					//NSLog(@"FS: %@ %@",s,port);
					[g addVertex: s withInfo: port];
				}
			}
	}
	//[g dumpToLog];
	return self;
}

-(NSString *)getLinePortKeyX: (int)x Y: (int)y  nodeMap: (NSDictionary *)map {
    NSString *s;
    int line,chip,port;
    //	"CU1 IB Switch - Spine 1 Chip 1"
    port = 24-x;
    line = 1+y/2;
    chip = (y&0x1)+1;
    
    s = [NSString stringWithFormat: @"%@ - Line %d Chip %d", name, line, chip];
    return [NSString stringWithFormat: @"%@-%d",[map objectForKey: s],port];
}

-(NSString *)getFabricPortKey: (int)x Y: (int)y Port: (int)p nodeMap: (NSDictionary *)map {
	NSString *s;
	// "CU1 IB Switch - Spine 1 Chip 3"
    s = [NSString stringWithFormat: @"%@ - Spine %d Chip %d", name, x+1, y+1];
	return [NSString stringWithFormat: @"%@-%d",[map objectForKey: s],p+1];
}

-(id) glDraw {
	int l,i,j;
	float pw,ph;
	glPushMatrix();
	glTranslatef(locx,locy,locz);
	glRotatef(rotx,1.0,0.0,0.0);
	glRotatef(roty,0.0,1.0,0.0);
	glRotatef(rotz,0.0,0.0,1.0);

	
	glGetFloatv(GL_MODELVIEW_MATRIX,(GLfloat *)reference);


	
	//Line switches
	if ([type compare: @"ISR2012" ] == NSOrderedSame) {
		/* bounding box */
		for (l=0;l<60;l+=12) {
			if (l==0)
				glColor3f(1.0,0.0,0.0);
			else
				glColor3f(0.5,0.5,0.5);

			glBegin(GL_LINE_LOOP);		
			for (i=l;i<l+12;i+=3)
				glVertex3f(box_quads[i]*300,box_quads[i+1]*300,box_quads[i+2]*300);
			glEnd();
		}
		/*end bounding*/

		pw = 300.0/12;
		ph = 300.0/24;
		for (i=0;i<24;i++) {
			glColor3f(0.0,0.0,0.7);
			glBegin(GL_LINE_LOOP);
			glVertex3f(100,i*ph,60);
			glVertex3f(200,i*ph,60);
			glVertex3f(200,i*ph,90);
			glVertex3f(100,i*ph,90);
			glEnd();
			glColor3f(0.0,0.0,0.4);
			glBegin(GL_LINES);
			for (l=0;l<12;l++) {
				glVertex3f(pw*l+pw/2,i*ph,0);
				glVertex3f(100+l*(100.0/12.0),i*ph,60);
			}
			glEnd();
		}
		
		//Fabric Switches
		for (i=0;i<4;i++)
			for (j=0;j<3;j++) {
				glColor3f(0.0,0.0,0.7);
				glBegin(GL_LINE_LOOP);
				glVertex3f(5+i*75,50+j*100.0,210);
				glVertex3f(70+i*75,50+j*100.0,210);
				glVertex3f(70+i*75,50+j*100.0,240);
				glVertex3f(5+i*75,50+j*100.0,240);
				glEnd();
			}
	}
	
	if ([type compare: @"TEST040208" ] == NSOrderedSame) {
		/* bounding box */
		for (l=0;l<60;l+=12) {
			if (l==0)
				glColor3f(1.0,0.0,0.0);
			else
				glColor3f(0.5,0.5,0.5);

			glBegin(GL_LINE_LOOP);		
			for (i=l;i<l+12;i+=3)
				glVertex3f(box_quads[i]*40,box_quads[i+1]*40,box_quads[i+2]*40);
			glEnd();
		}
		/*end bounding*/

		pw = 40.0/4;
		ph = 40.0/4;
		for (i=0;i<4;i++) {
			glColor3f(0.0,0.0,0.7);
			glBegin(GL_LINE_LOOP);
			glVertex3f(5,i*ph,5);
			glVertex3f(35,i*ph,5);
			glVertex3f(35,i*ph,15);
			glVertex3f(5,i*ph,15);
			glEnd();
			glColor3f(0.0,0.0,0.4);
			glBegin(GL_LINES);
			for (l=0;l<4;l++) {
				glVertex3f(pw*l+pw/2,i*ph+ph/2,0);
				glVertex3f(10+l*(30.0/4.0),i*ph,5);
			}
			glEnd();
		}
		
		//Fabric Switches
		for (i=0;i<1;i++)
			for (j=0;j<2;j++) {
				glColor3f(0.0,0.0,0.7);
				glBegin(GL_LINE_LOOP);
				glVertex3f(5+i*20,10+j*10.0,25);
				glVertex3f(35+i*20,10+j*10.0,25);
				glVertex3f(35+i*20,10+j*10.0,35);
				glVertex3f(5+i*20,10+j*10.0,35);
				glEnd();
			}
	}
	
	glPopMatrix();	
	return self;
}

-(flts *)getGLRef {
	return reference;
}
-description {
	return name;
}
@end


@implementation GLInfinibandNetwork
-(id)getPList {
	NSMutableDictionary *list = [super getPList];
	[list setObject: portSpeed forKey: @"portspeed"];
	[list setObject: nodemapfile forKey: @"nodemapfile"];
	[list setObject: netlinksfile forKey: @"netlinksfile"];
	[list setObject: netcountfile forKey: @"netcountfile"];
	if (colorMax != 0)
		[list setObject: [NSNumber numberWithInt: colorMax] forKey: @"colorMax"];

	[list setObject: [chassis arrayObjectsFromPerformedSelector:@selector(getPList)] forKey: @"chassis"];

	return list;
}

-(id)initWithPList: (id)list {
	NSArray *c;
	NSEnumerator *e;
	IBChassis *ibc;
	NSDictionary *d;
	[super initWithPList: list];
	
	graph = [[Graph alloc] init];
	chassis = [[NSMutableArray arrayWithCapacity: 16] retain];
	
	colorMax = [[list objectForKey: @"colorMax" missing: @"0"] intValue];
	netcountfile = [[list objectForKey: @"netcountfile" missing: @"ib_med.linkcounts"] retain];
	netlinksfile = [[list objectForKey: @"netlinksfile" missing: @"ib_med.ibnetdiscover"] retain];
	nodemapfile = [[list objectForKey: @"nodemapfile" missing: @"ib-node-names.map"] retain];
	nodemap = [scanNodeMapFile(find_resource(nodemapfile)) retain];
	
	portSpeed = [[list objectForKey: @"portspeed" missing: @"DDR"] retain];
	
	c = [list objectForKey: @"chassis" missing: [NSArray array]];
	e = [c objectEnumerator];
	while ( (d = [e nextObject]) ) {
		//NSLog(@"%@",d);
		ibc = [[[IBChassis alloc] initWithPList: d] autorelease];
		[chassis addObject: ibc];
		[ibc populateGraph: graph nodeMap: nodemap];
	}
	[self loadNetLinks: find_resource(netlinksfile)];
	//This sets up the ColorMap as well
	[self loadNetCounts: find_resource(netcountfile)];

	return self;
}

-(NSArray *)attributeKeys {
	//isVisible comes from the DrawableObject
	return [NSArray arrayWithObjects: @"chassis",@"nodemapfile",@"netlinksfile",@"netcountfile",@"nodemap",@"colorMax",nil];
}

-(void)dealloc {
	NSLog(@"%@ dealloc",[self class]);
	[graph autorelease];
	[nodemapfile autorelease];
	[chassis autorelease];
	[nodemap autorelease];
	[colorMap autorelease];
	[portSpeed autorelease];
	[super dealloc];
	return;
}

-(BOOL)loadNetLinks: (NSFileHandle *)file {
	NSData *data = [file readDataToEndOfFile];
	NSString *linestring = [NSString stringWithCString: [data bytes] length: [data length]];
	NSArray *lines = [linestring componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"\n"]];
	NSString *line;
	NSEnumerator *e;
	NSString *from,*to,*speed;
	int tport,fport;
	BOOL good;
	
	e = [lines objectEnumerator];
	while ( (line = [e nextObject] ) ) {
		if ( [line length]==0 )
			continue;

		from = [line substringWithRange: NSMakeRange(12,18)];
		to = [line substringWithRange: NSMakeRange(52,18)];
		fport = [[line substringWithRange: NSMakeRange(9,2)] intValue];
		tport = [[line substringWithRange: NSMakeRange(49,2)] intValue];
		speed = [line substringWithRange: NSMakeRange(34,3)];
		
		
		if ([from hasPrefix: @"0x000"])
			from = [NSString stringWithFormat: @"0x%@",[from substringFromIndex: 5]];
		if ([to hasPrefix: @"0x000"])
			to = [NSString stringWithFormat: @"0x%@",[to substringFromIndex: 5]];
		//NSLog(@"%@ %d  %@ %d  %@",from,fport,to,tport,speed);
		
		
		if ([from length]>0 && [to length]>0) {
			good = [graph addEdge: 
					[NSString stringWithFormat: @"%@-%d",from,fport] and: 
					[NSString stringWithFormat: @"%@-%d",to,tport] withInfo:
					[IBLink link]
					];
		}
		
		if ([speed compare: portSpeed ] == NSOrderedSame) {
			if ([from length]>0)
				[[graph vertexData: [NSString stringWithFormat: @"%@-%d",from,fport]] setColorR: 0.4 G: 0.2 B: 0.2];
			if ([to length]>0)
				[[graph vertexData: [NSString stringWithFormat: @"%@-%d",to,tport]] setColorR: 0.4 G: 0.2 B: 0.2];
		}
	}
	return YES;
}


-(BOOL)loadNetCounts: (NSFileHandle *)file {
	NSData *data = [file readDataToEndOfFile];
	NSString *linestring = [NSString stringWithCString: [data bytes] length: [data length]];
	NSArray *lines = [linestring componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"\n"]];
	NSString *line;
	NSArray *parts;
	NSEnumerator *e;
	NSString *from,*to;
	IBLink *link;
	int count;
	int max=1;
	
	
	e = [lines objectEnumerator];
	while ( (line = [e nextObject] ) ) {
		if ( [line length]==0 )
			continue;
		parts = [line componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
		count = [[parts objectAtIndex: 0] intValue];
		from = [parts objectAtIndex: 1];
		to = [parts objectAtIndex: 2];


		//NSLog(@"Link: %@ %@ %d",from,to,count);
		link = [graph edgeData: from and: to];
		if (link) {
			[link setValue: count];
			max = MAX(max,count);
		}
	}
	[colorMap autorelease];
	if (colorMax > 0) {
		if (max > colorMax)
			NSLog(@"colorMax is lower than data max, continuing anyway: %d > %d",max,colorMax);
		max = colorMax;
	}
	colorMap = [[ColorMap mapWithMax: max] retain];
	return YES;
}

-(id) glDraw {
	NSEnumerator *e;
	IBChassis *c;
	NSArray *a;
	id o;
	
	glPushMatrix();
	glScalef(0.5,0.5,0.5);
	e = [chassis objectEnumerator];
	while ( (c = [e nextObject]) ) {
		[c glDraw];
	}
	
	glColor3f(0.4,0.2,0.2);
	e = [graph vertexEnumerator];
	while ( (o = [e nextObject]) ) {
		o=[graph vertexData: o];
		//NSLog(@"%@",o);
		[o glDraw];
	}
	
	glPushMatrix();
	glLoadIdentity();
	glColor3f(0.0,0.0,1.0);
	e = [graph edgeEnumerator];
	while ( (a = [e nextObject]) ) {
		[colorMap glMap: [[graph edgeData: a] getValue]];
		glBegin(GL_LINES);
		[[graph vertexData: [a objectAtIndex: 0]] glVertex];
		[[graph vertexData: [a objectAtIndex: 1]] glVertex];
		glEnd();
	}
	glPopMatrix();
	
	glPopMatrix();
	return self;
}

-description {
	return @"IBnet";
}
@end