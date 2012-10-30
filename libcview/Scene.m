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
#import <gl.h>
#import <glut.h>
#import <Foundation/Foundation.h>
#import "cview.h"
#import "cview-data.h"

@interface SceneObject: NSObject <PList> {
@public
	DrawableObject *object;
	float x,y,z;
	float rotx,roty,rotz;
	int halign,valign;
	BOOL align;
}
@end

@implementation SceneObject
-getPList {
	id o = [object getPList];
	NSLog(@"SceneObject: %@ %f %f %f",object,x,y,z);
	if (o) 
		return [NSDictionary dictionaryWithObjectsAndKeys: 
			[object class],@"objectclass",
			o,@"object",
			[NSNumber numberWithFloat: x],@"x",
			[NSNumber numberWithFloat: y],@"y",
			[NSNumber numberWithFloat: z],@"z",
			[NSNumber numberWithFloat: rotx],@"rotx",
			[NSNumber numberWithFloat: roty],@"roty",
			[NSNumber numberWithFloat: rotz],@"rotz",
			[NSNumber numberWithInt: halign],@"halign",
			[NSNumber numberWithInt: valign],@"valign",
			[NSNumber numberWithBool: align],@"align",
			nil];
	else
		return [NSNull null];
}

-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
	[self init];
	
	x = [[list objectForKey: @"x" missing: @"0.0"] floatValue];
	y = [[list objectForKey: @"y" missing: @"0.0"] floatValue];
	z = [[list objectForKey: @"z" missing: @"0.0"] floatValue];
	rotx = [[list objectForKey: @"rotx" missing: @"0.0"] floatValue];
	roty = [[list objectForKey: @"roty" missing: @"0.0"] floatValue];
	rotz = [[list objectForKey: @"rotz" missing: @"0.0"] floatValue];
	halign = [[list objectForKey: @"halign" missing: @"0"] intValue];
	valign = [[list objectForKey: @"valign" missing: @"0"] intValue];
	align = [[list objectForKey: @"align" missing: @"NO"] boolValue];	

	Class c;
	c = NSClassFromString([list objectForKey: @"objectclass"]);
	
	if (c && [c conformsToProtocol: @protocol(PList)] && [c isSubclassOfClass: [DrawableObject class]]) {
		object=[c alloc];
		[object initWithPList: [list objectForKey: @"object"]];
		[object retain];		

	}
	return self;
}

-(NSDictionary *)tweaksettings {
	return [NSDictionary dictionaryWithObjectsAndKeys:
		@"help='Horizontal Alignment' min=-1 max=1 step=1",@"halign",
		@"help='Vertical Alignment' min=-1 max=1 step=1",@"valign",
		@"help='Use alignment Values' min=0 max=1 step=1",@"align",
		@"min=-180 max=180 step=2 precision=0",@"rotx",
		@"min=-180 max=180 step=2 precision=0",@"roty",
		@"min=-180 max=180 step=2 precision=0",@"rotz",
		nil];
}

-(NSArray *)attributeKeys {
	return [NSArray arrayWithObjects: @"x",@"y",@"z",@"rotx",@"roty",@"rotz",@"halign",@"valign",@"align",@"object",nil];
}

-(DrawableObject *)getObject {
	return object;
}

-description {
	return @"SceneObject";
}
@end

@implementation Scene
-init {
	[super init];
	objects = [NSMutableArray arrayWithCapacity: 4];
	[objects retain];
	return self;
}

-(void)dealloc {
	NSLog(@"GLScene dealloc");
	SceneObject *o;
	NSEnumerator *list;
	list = [objects objectEnumerator];
	while ( (o = [list nextObject]) ) {
		[o->object autorelease];  // we wouldent need this if the SceneObject was a proper class that would retain/release things...
	}
	[objects autorelease];
	[super dealloc];
	return;
}

-initWithObject: (DrawableObject *) o atX: (float)x Y: (float)y Z: (float)z {
	[self init];
	[self addObject: o atX: x Y: y Z: z];
	return self;
}
-initWithObject: (DrawableObject *) o alignHoriz:(int)h Vert: (int)v  {
	[self init];
	[self addObject: o alignHoriz: h Vert: v];
	return self;
}

-addObject: (DrawableObject *) o atX: (float)x Y: (float)y Z: (float)z {
	SceneObject *obj = [[SceneObject alloc] init];
	[o retain];
	obj->object = o;
	obj->x=x;
	obj->y=y;
	obj->z=z;
	obj->valign=0;
	obj->halign=0;
	obj->align=0;
	[objects addObject: obj];
	return self;
}

-addObject: (DrawableObject *)o alignHoriz:(int)h Vert: (int)v {
	SceneObject *obj = [[SceneObject alloc] init];
	[o retain];
	obj->object = o;
	obj->x=0.0;
	obj->y=0.0;
	obj->z=0.0;
	obj->valign=v;
	obj->halign=h;
	obj->align=1;
	[objects addObject: obj];
	return self;
}

-removeObject: (DrawableObject *)o {
	NSEnumerator *e;
	SceneObject *obj;
	e = [objects objectEnumerator];
	while ((obj = [e nextObject])) {
		if (obj->object == o) {
			[obj->object autorelease];
			[objects removeObject: obj];
			[obj release];
			break;
		}
	}
	return self;
}
-removeAllObjects {
	NSEnumerator *e;
	SceneObject *obj;
	e = [objects objectEnumerator];
	while ((obj = [e nextObject])) {
			[obj->object autorelease];
			[obj release];
			break;
	}
	[objects removeAllObjects];
	return self;
}
-(int)objectCount {
	return [objects count];
}

-(NSArray *)getAllObjects {
	return [objects arrayObjectsFromPerformedSelector: @selector(getObject)];
}

-doTranslate: (SceneObject *)o {
	if (o->align) {
		int x,y;
        int width = glutGet(GLUT_WINDOW_WIDTH);
        int height = glutGet(GLUT_WINDOW_HEIGHT);

		switch( o->halign ){
			case -1:
				x=0;
				break;
			case 0:
				x=(width-[[o getObject] width])/2;
				break;
			case 1:
				x=(width-[[o getObject] width]);
				break;
			default:
				NSLog(@"Bad Horizontal Alignment: %d",o->halign);
				x=0;
				break;
		}
		switch( o->valign ){
			case -1:
				y=0;
				break;
			case 0:
				y=(height-[o->object height])/2;
				break;
			case 1:
				y=(height-[o->object height]);
				break;
			default:
				NSLog(@"Bad Vertical Alignment: %d",o->valign);
				y=0;
				break;
		}
		glTranslatef(x,y,0);
	}
	else 
		glTranslatef(o->x,o->y,o->z);
	return self;
}

-doRotate: (SceneObject *)o {
	glRotatef(o->rotx,1.0,0.0,0.0);
	glRotatef(o->roty,0.0,1.0,0.0);
	glRotatef(o->rotz,0.0,0.0,1.0);
	return self;
}

-glDraw {
	SceneObject *o;
	NSEnumerator *list;
	list = [objects objectEnumerator];
	while ( (o = [list nextObject]) ) {
			if ([o->object visible]) {
				glPushMatrix();
				[self doTranslate: o];
				[self doRotate: o];
				[o->object glDraw];
				glPopMatrix();
			}
	}

	return self;
}
/// identical to glDraw except that it calls glPickDraw on all scene objects
-glPickDraw {
	SceneObject *o;
	NSEnumerator *list;
	list = [objects objectEnumerator];
	while ( (o = [list nextObject]) ) {
			if ([o->object visible]) {
				glPushMatrix();
				[self doTranslate: o];
				[o->object glPickDraw];
				glPopMatrix();
			}
	}
	return self;
}

- (void) encodeWithCoder: (NSCoder*)aCoder {
	[aCoder encodeObject: objects forKey: @"objects"];
}

- (id) initWithCoder: (NSCoder*)aDecoder {
	[super init];
	objects=[aDecoder decodeObjectForKey: @"objects"];
	[objects retain];
	return self;
}
-getPList {
    if(objects == nil)
        return self;
	NSArray *os = [objects arrayObjectsFromPerformedSelector: @selector(getPList)];
	//Remove any Null objects
	NSMutableArray *mos = [NSMutableArray arrayWithArray: os];
	[mos removeObject: [NSNull null]]; 
	return [NSDictionary dictionaryWithObjectsAndKeys: mos, @"objects", nil];
}

-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
	[self init];
	
	NSArray *arr=[list objectForKey: @"objects"];
	//NSLog(@"%@",arr);
	SceneObject *so;
	id l;
	NSEnumerator *e;

	e = [arr objectEnumerator];
	while ((l = [e nextObject])) {
		so=[SceneObject alloc];
		[so initWithPList: l];
		[objects addObject: so];
	}
	return self;
}

-(NSArray *)attributeKeys {
	return [NSArray arrayWithObjects: @"objects",nil];
}
-description {
	return @"Scene";
}
@end
