/*
 This file is port of the CVIEW graphics system

 Copyright 2014 Battelle Memorial Institute.

 This software is licensed under the Battelle “BSD-style” open source license;
 the full text of that license is available in the COPYING file in the root of the repository

*/

#import "ValueStoreTweakBar.h"

@implementation ValueStoreTweakBar

-initWithManager: (AntTweakBarManager *)mgr {
	[super init];
	manager = [mgr retain];
  name = @"ValueStore";
  atbNodes = [[NSMutableSet setWithCapacity: 10] retain];
  myBar = [manager addBar: name];
  TwDefine([[NSString stringWithFormat: @"%@ iconified=true color='128 64 64'",name] UTF8String]);
  [self populateBar];
	return self;
}

-populateBar {
  ValueStore *vs = [ValueStore valueStore];
  NSArray *keys = [vs getKeys];
  NSEnumerator *list;
  NSString *key;
  id item;
  
  list = [keys objectEnumerator];
  while ((key = [list nextObject])) {
    item = [vs getObject: key];
    //NSLog(@"vskey: %@",key);
    parseTree(myBar, name, item, key, atbNodes);
  }
  return self;
}
-(void)dealloc {
  NSLog(@"%@ dealloc",[self class]);
	[manager removeBar: myBar];
	[name autorelease];
	[manager autorelease];
	[atbNodes autorelease];
//	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"DataModelModified" object: myTree];
	[super dealloc];
	return;
}
@end