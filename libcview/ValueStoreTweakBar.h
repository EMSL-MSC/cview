/*
 This file is port of the CVIEW graphics system

 Copyright 2014 Battelle Memorial Institute.

 This software is licensed under the Battelle “BSD-style” open source license;
 the full text of that license is available in the COPYING file in the root of the repository

*/

#import <Foundation/Foundation.h>
#include <AntTweakBar.h>
#import "AntTweakBarManager.h"
#import "AntTweakBarOverlay.h"
#import "ValueStore.h"

/**
	Manage Editing of data sets in the Value Store using a TweakBar

	@author Evan Felix
	@ingroup cview
*/
@interface ValueStoreTweakBar: NSObject {
	TwBar *myBar;
  AntTweakBarManager *manager;
  NSString *name;
  NSMutableSet *atbNodes;
}
/** initalize the class */
-initWithManager: (AntTweakBarManager *)mgr;
-populateBar;
@end