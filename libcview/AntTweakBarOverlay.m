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
#import <sys/param.h>  //for max/min
#import <Foundation/Foundation.h>
#include <AntTweakBar.h>
#include "AntTweakBarOverlay.h"

#define MAX_STRING 255

//#define TwDefine(x...) do { NSLog(@"TwDefine:%s",x);TwDefine(x);} while (0)


@implementation ATB_Node
-initWithName: (NSString *)n andObject: (NSObject *)o {
	name = [n retain];
	object = [o retain];
	return self;
}
-(void)dealloc {
	[name autorelease];
	[object autorelease];
	[super dealloc];
	return;
}
@end

void TW_CALL floatSetCallback(const void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;

	[atb->object setValue: [NSNumber numberWithFloat: *(const float *)value] forKeyPath: atb->name];	
}

void TW_CALL floatGetCallback(void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;

	NSNumber *f=[atb->object valueForKeyPath: atb->name];
	*(float *)value = [f floatValue];
}

void TW_CALL intSetCallback(const void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;
	
	[atb->object setValue: [NSNumber numberWithInt: *(const int *)value] forKeyPath: atb->name];
}

void TW_CALL intGetCallback(void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;

	NSNumber *i=[atb->object valueForKeyPath: atb->name];
	*(int *)value = [i intValue];
}

void TW_CALL boolSetCallback(const void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;
	
	[atb->object setValue: [NSNumber numberWithBool: *(const char *)value] forKeyPath: atb->name];
}

void TW_CALL boolGetCallback(void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;
  
	NSNumber *i=[atb->object valueForKeyPath: atb->name];
	*(char *)value = [i boolValue];
}

/*The Setting of strings can be dangeous, as if there is not a set<attrib> Function call the string may overwrite
 *  things that are not retained properly.  It should be safe if the set<attib> is in place properly.  but we cant garruntee that here. */
void TW_CALL stringSetCallback(const void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;

	[atb->object setValue: [NSString stringWithUTF8String: (const char *)value] forKeyPath: atb->name];
}


void TW_CALL mutableStringSetCallback(const void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;

	NSMutableString *ms=[atb->object valueForKeyPath: atb->name];
	[ms setString: [NSString stringWithUTF8String: (const char *)value]];
}

void TW_CALL stringGetCallback(void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;
	const char *f;
	NSString *s=[atb->object valueForKeyPath: atb->name];
	f = [s UTF8String];
	strncpy((char *)value, f, MIN(strlen(f),MAX_STRING-1));
	((char *)value)[MIN(strlen(f),MAX_STRING)]=0;
}

/*
static void TW_CALL urlSetCallback(const void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;

	[atb->object 
		setValue: 
			[NSURL URLWithString: 
				[NSString stringWithUTF8String: (const char *)value]]
		forKeyPath: atb->name
	];
}

static void TW_CALL urlGetCallback(void *value, void *clientData) {
	ATB_Node *atb = (ATB_Node *)clientData;
	const char *f;
	NSURL *u = [atb->object valueForKeyPath: atb->name];
	NSString *s = [u description];
	f = [s UTF8String];
	strncpy((char *)value, f, MIN(strlen(f),MAX_STRING-1));
	((char *)value)[MIN(strlen(f),MAX_STRING)]=0;
}
*/

BOOL parseTree(TwBar *bar, NSString *name, NSObject *tree, NSString *grp, NSMutableSet *nodeTracker) {
	
	//Add all attributes from this tree
	NSArray *att = [tree attributeKeys];
	NSString *key;
	NSEnumerator *list;
	NSDictionary *settings;
	NSString *keybase;
  
  
  
	if (grp)
		keybase=[NSString stringWithFormat:@"%@.",grp];
    else
      keybase=@"";
      
      //NSLog(@"Node props: %@ keybase: %@",att, keybase);
      if (att) {
        
        if ([tree respondsToSelector: @selector(tweaksettings)])
          settings = [tree valueForKey: @"tweaksettings"];
        else
          settings = [NSDictionary dictionary];
        
        //NSLog(@"settings=%@",settings);
        list = [att objectEnumerator];
        while ((key = [list nextObject])) {
          NSObject *o = [tree valueForKey: key];
          //NSLog(@"O:%p key=%@",o,key);
          /** @fixme probably leaking keypath */
          //NSString *keypath = [[NSString stringWithFormat:@"%@%@",keybase,key] retain];
          NSString *keypath = [NSString stringWithFormat:@"%@%@",keybase,key];
          ATB_Node *atb = [[ATB_Node alloc] initWithName: key andObject: tree];
          [nodeTracker addObject:atb];
          
          NSString *setting = [settings objectForKey: key];
          
          const char *data="";
          
          if (setting)
            data=[setting UTF8String];
          data=[[NSString stringWithFormat:@"label='%@' %s",key,data] UTF8String];
          //NSLog(@"name: %@, class: %@ keypath: %@ settings: %s",key,[o class],keypath, data);
          
          if ([o isKindOfClass: [NSNumber class]]) {
            NSNumber *n = (NSNumber *)o;
            //NSLog(@"is number:%c",*[n objCType]);
            switch (*[n objCType]) {
              case 'f':
                TwAddVarCB(bar, [keypath UTF8String], TW_TYPE_FLOAT, floatSetCallback, floatGetCallback, atb, data);
                break;
              case 'i':
                TwAddVarCB(bar, [keypath UTF8String], TW_TYPE_INT32, intSetCallback, intGetCallback, atb, data);
                break;
              case 'c': /* this is probably handled badly, but so far we only have bool values that come back as 'c' type */
                TwAddVarCB(bar, [keypath UTF8String], TW_TYPE_BOOL8, boolSetCallback , boolGetCallback, atb, data);
                break;
              default:
                NSLog(@"Unhandled Number Type: %s",[n objCType]);
                break;
            }
            if (grp)
              TwDefine([[NSString stringWithFormat:@"%@/%@ group=%@",name,keypath,grp] UTF8String]);
          }
          
          else if ([o isMemberOfClass: [NSMutableString class]]) {
            TwAddVarCB(bar, [keypath UTF8String], TW_TYPE_CSSTRING(MAX_STRING), mutableStringSetCallback, stringGetCallback, atb, data);
            
            if (grp)
              TwDefine([[NSString stringWithFormat:@"%@/%@ group=%@",name,keypath,grp] UTF8String]);
          }
          
          else if ([o isKindOfClass: [NSString class]]) {
            TwAddVarCB(bar, [keypath UTF8String], TW_TYPE_CSSTRING(MAX_STRING), stringSetCallback, stringGetCallback, atb, data);
            
            if (grp)
              TwDefine([[NSString stringWithFormat:@"%@/%@ group=%@",name,keypath,grp] UTF8String]);
          }
          /*
           else if ([o isKindOfClass: [NSURL class]]) {
           NSURL *u=(NSURL *)o;
           
           TwAddVarCB(myBar, [keypath UTF8String], TW_TYPE_CSSTRING(MAX_STRING), urlSetCallback, urlGetCallback, atb, data);
           
           if (grp)
           TwDefine([[NSString stringWithFormat:@"%@/%@ group=%@",name,keypath,grp] UTF8String]);
           }
           */
          else if ([o isKindOfClass: [NSArray class]]) {
            NSArray *a = (NSArray *)o;
            int i;
            
            for (i=0;i<[a count];i++) {
              NSString *newpath=[NSString stringWithFormat:@"%@.%d",keypath,i];
              NSString *newkey=[NSString stringWithFormat:@"%@[%d]",key,i];
              //NSLog(@"Array Member: %@  keypath: %@",newpath,newkey);
              if ( parseTree(bar, name, [a objectAtIndex: i], newpath,nodeTracker)) {
                if (grp)
                  TwDefine([[NSString stringWithFormat:@"%@/%@ group=%@ label='%@-%@' close",name,newpath,grp,newkey,[[a objectAtIndex: i] description]] UTF8String]);
                else
                  TwDefine([[NSString stringWithFormat:@"%@/%@ label=%@-%@ close",name,newpath,newkey,[[a objectAtIndex: i] description]] UTF8String]);
              }
            }
          }
          else {
            //NSLog(@"Class Type Unhandled: %@  keypath: %@",[o class],keypath);
            if ( parseTree(bar, name, o, keypath, nodeTracker ) ) {
              if (grp)
                TwDefine([[NSString stringWithFormat:@"%@/%@ group=%@ label='%@-%@' close",name,keypath,grp,key,[o description]] UTF8String]);
              else
                TwDefine([[NSString stringWithFormat:@"%@/%@ label=%@-%@ close",name,keypath,key,[o description]] UTF8String]);
            }
          }
        }
        return YES; //we added something to the tree
      }
	return NO;//nothing in the tree had attributes
}


@implementation AntTweakBarOverlay

-initWithName: (NSString *)aName andManager: (AntTweakBarManager *)theManager {
	[super init];
	manager = [theManager retain];
	myNodes = [[NSMutableSet setWithCapacity: 10] retain];
	name = [aName retain];
	myBar = [manager addBar: name];
	NSLog(@"The BAR: %p",myBar);
	return self;
}

-addNodeNamed: (NSString *)n andObject: (NSObject *)o {
	ATB_Node *atb = [[ATB_Node alloc] initWithName: n andObject: o];
	//@todo track these..
	[myNodes addObject: atb];
	return [atb autorelease];
}

-(void)setValues: (NSObject *)setValue forKey: (NSString *)setKey {
	[self setValues: setValue forKey: setKey inTree: myTree];
}
-(void)setValues: (NSObject *)setValue forKey: (NSString *)setKey inTree: (NSObject *) tree {
	//Add all attributes from this tree
	NSArray *att = [tree attributeKeys];
	NSString *key;
	NSEnumerator *list;
	NSDictionary *settings;
	//NSLog(@"Node props: %@",att);
	if (att) {
		if ([tree respondsToSelector: @selector(tweaksettings)])
			settings = [tree valueForKey: @"tweaksettings"];
		else
			settings = [NSDictionary dictionary];
		//NSLog(@"settings=%@",settings);
		list = [att objectEnumerator];
		while ((key = [list nextObject])) {
			NSObject *o = [tree valueForKey: key];
			//NSLog(@"O:%p key=%@",o,key);
			if ([setKey compare: key] == NSOrderedSame) {
				if ([o isKindOfClass: [setValue class]] || [setValue isKindOfClass: [o class]])
					[tree setValue: setValue forKey: setKey];
//				NSLog(@"o class: %@ <- %@ setValue class: %@ <- %@", [o class], [o superclass], [setValue class], [setValue superclass]);
			} else if ([o isKindOfClass: [NSArray class]]) {
				NSArray *a = (NSArray *)o;
				int i;
				for (i=0;i<[a count];i++)
					[self setValues: setValue forKey: setKey inTree: [a objectAtIndex: i]];
			} else {
//				NSLog(@"Class Type Unhandled: %@  keypath: %@",[o class],keypath);
				[self setValues: setValue forKey: setKey inTree: o];
			}
		}
	}
}


-treeChanged: (NSNotification *)note {
	if ([note object] == myTree) {// should alwasy happen, but check anyway.
		//NSLog(@"Tree change Notification: %@",note);
		TwRemoveAllVars(myBar);
		parseTree(myBar, name, myTree, nil, myNodes);
	}
	else {
		NSLog(@"Strange notification: %@",note);
	}
	return self;
}

-(BOOL)setTree: (NSObject *)tree {
	TwRemoveAllVars(myBar);
	[myNodes removeAllObjects];
	
	[tree retain];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"DataModelModified" object: myTree];
	[myTree autorelease];
	myTree = tree;
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(treeChanged:) name: @"DataModelModified" object: myTree];
	return parseTree(myBar, name, tree, nil, myNodes);
}

-(void)dealloc {
	NSLog(@"%@ dealloc",[self class]);
	[manager removeBar: myBar];
	[name autorelease];
	[manager autorelease];
	[myNodes autorelease];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"DataModelModified" object: myTree];
	[myTree autorelease];
	[super dealloc];
	return;
}
@end
