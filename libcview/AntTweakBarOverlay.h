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
/**
	Overlay Tweakbar that takes a tree of objects that support The KeyValueCoding scheme, it then presents this tree to the user in a Tweak bar.  Classes can advertise which attributes are modifyable by return a list of them with the NSObject attributeKeys.  A tweakSettings message is optional in each class that allows a class to specify how an item is changeable. 

	@author Evan Felix
	@ingroup cview3d
*/


#import <Foundation/Foundation.h>
#include <AntTweakBar.h>
#import "AntTweakBarManager.h"

void TW_CALL floatSetCallback(const void *value, void *clientData);
void TW_CALL floatGetCallback(void *value, void *clientData);
void TW_CALL intSetCallback(const void *value, void *clientData);
void TW_CALL intGetCallback(void *value, void *clientData);
void TW_CALL boolSetCallback(const void *value, void *clientData);
void TW_CALL boolGetCallback(void *value, void *clientData);
void TW_CALL stringSetCallback(const void *value, void *clientData);
void TW_CALL mutableStringSetCallback(const void *value, void *clientData);
void TW_CALL stringGetCallback(void *value, void *clientData);
BOOL parseTree(TwBar *bar, NSString *name, NSObject *tree, NSString *grp, NSMutableSet *nodeTracker);
/**
 Data Node to store a representation of the users tweakable tree for the AntTweakBarOverlay & others.  normally given to AntTweakBar calls as data
     for the get/set Callbacks
 
 @author Evan Felix
 @ingroup cview3d
 */
@interface ATB_Node:NSObject {
@public
	NSObject *object;
	NSString *name;
}
-initWithName: (NSString *)n andObject: (NSObject *)o;
@end


@interface AntTweakBarOverlay:NSObject {
	NSString *name;
	AntTweakBarManager *manager;
	TwBar *myBar;
	NSObject *myTree;
	NSDictionary *tweakSettings;
	NSMutableSet *myNodes;
}
-initWithName: (NSString *)aName andManager: (AntTweakBarManager *)theManager;
-(void)setValues: (NSObject *)setValue forKey:(NSString *)setKey;
-(void)setValues: (NSObject *)setValue forKey:(NSString *)setKey inTree: (NSObject *) tree;
-(BOOL)setTree: (NSObject *)tree;
-(void)dealloc;
@end
