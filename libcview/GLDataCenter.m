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
#include <string.h>
#import <Foundation/Foundation.h>
#import <gl.h>
#import <glut.h>
#import "cview.h"
#import "DataSet.h"
#import "GLDataCenter.h"
#import "DictionaryExtra.h"
#include <genders.h>
#import "DataCenter/Node.h"
void drawString3D(float x,float y,float z,void *font,NSString *string,float offset);
extern GLuint g_textureID;
@implementation  GLDataCenter
-init {
    [super init];
	self->drawLegend = YES;
	self->legend_location = 1;
	self->legend_padd_side = 50;
	self->legend_padd_top = 50;
	self->scale = 1.0;
	self->selectedNode = nil;
	self->red = 0.38;
	self->green = 0.38;
	self->blue = 0.38;
    self->floor = nil;
    self->floorVertCount = 0;
    self->gendersFilePath = nil;
    self->jobIds = nil;
    self->jobIdIndex = 0;
	self->dataSet = nil;
	self->gltName = nil;
	self->colorMap = nil;
	self->currentMax = 0;

    [Rack setGLTName: nil];
    //[Node setGLTName: nil];
    return self;
}
-(float)scale { return self->scale; }
-doInit {
    self->racks = [[NSMutableDictionary alloc] init];
    [self initWithGenders]; // use the genders file to initialize the data center
    return self;
}

-(Node*)findNodeObjectByName:(NSString*) _name {
    if(self->racks == nil)
        return nil;
    NSEnumerator *enumerator = [self->racks objectEnumerator];
    if(enumerator == nil)
        return nil;
    id element;
    Node *node;
    while((element = [enumerator nextObject]) != nil) {
        node = [element findNodeObjectByName: _name];
        if(node != nil)
            return node;
    }
    return nil;
}
-(NSArray*)getNodesRunningAJobID:(float) jobid {
    int i;
    float *dl;
    NSMutableArray *nodeArray = [[NSMutableArray alloc] init];
    for(i=0;i<[jobIds width];++i) {
        dl = [jobIds dataRow: i];
//        dl[0] should be all we care about here...
        if(jobid == dl[0]) {
            Node *node =  [self findNodeObjectByName: [jobIds columnTick: i]];
            if(node != nil)
                [nodeArray addObject: node];
        }
    }
    [nodeArray autorelease];//auto or regular, not really sure which to use....
    return nodeArray;
}
-seeNextJobId {
    if(jobIds == nil) {
        NSLog(@"jobIds was nil!!!");
        return self;
    }
    float *dr = [jobIds dataRow: jobIdIndex];
    float job = dr[0];

    NSLog(@"(%d) Now displaying jobs from jobid : %f", jobIdIndex, job);
    [self fadeEverythingExceptJobID: job];
    while(job == [jobIds dataRow: jobIdIndex++][0])
        ;
    return self;
}
-(float)getJobIdFromNode:(Node*)n {
    if(n == nil)
        return 0;
    float *row = [jobIds dataRowByString: [n getName]];
    if(row != NULL)
        return row[0];
    return 0;
}
-unfadeEverything {
    if(self->racks == nil)
        return self;
//    [self->aisles makeObjectsPerformSelector: @selector(startUnFading)];
    return self;

}
-fadeEverythingExceptJobID:(float) jobid {
    if(self->racks == nil)
        return self;
    // first fade everything
    [[self->racks allValues] makeObjectsPerformSelector: @selector(startFading)];

    NSArray *arr = [self getNodesRunningAJobID: jobid];
    if(arr == nil)
        return self;
    // then unfade the ones we want
    [arr makeObjectsPerformSelector: @selector(startUnFading)];
    return self;
}
-(Rack*)findRack: (NSString*) rackName {
    NSEnumerator *enumerator = [racks objectEnumerator];
    if(enumerator == nil)
        return nil;
    id element;
    while((element = [enumerator nextObject]) != nil) {
        // Compare aisle names
        if(NSOrderedSame == [rackName compare: [element getName]])
            return element; // Found it, return it!
    }
    return nil;
}
// Compares each string in the attrList to attr.  If the same, returns the index that it was found at. otherwise returns -1
-(int)indexOfAttr: (char**) attrList andLen: (int) len withAttr:(NSString*) attr {
    int i;
    for(i = 0; i < len; ++i) {
        NSString *s1 = [NSString stringWithUTF8String: attrList[i]];
        if([s1 compare: attr] == NSOrderedSame)
            return i;
    }
    return -1;
}
-cleanUp {
    NSLog(@"Cleaning up the GLDataCenter.");
    floorVertCount = 0;
    if(floor != nil)
        [floor autorelease];
    if(racks == nil)
        return self;
    NSEnumerator *enumerator = [racks objectEnumerator];
    if(enumerator != nil) {
        id element;
        while((element = [enumerator nextObject]) != nil)
            [element cleanUp];
    }
    [racks removeAllObjects];
    return self;
}
/* This method simply makes a bunch of **genders** calls to get information about the nodes
   specific information is as follows:
   -name
   -rack
   -position (x,y)
   -facing direction [NESW] (north, east, south, or west) TODO: in the future should this be changed to degrees???
   -color
   Once it has that information it is put into the data stuctures 'aisles' which is a list of aisles in the data center
   */
-initWithGenders {
    if(self->gendersFilePath == nil) {
        NSLog(@"No genders file found (check your .cview file), cannot load the DataCenter");
        return self;
    }
    genders_t handle = genders_handle_create();
    if(handle == NULL) {
        NSLog(@"genders_handle_create() failed miserably!");
        return self;
    }
    if(genders_load_data(handle, [self->gendersFilePath UTF8String]) != 0) {
        NSLog(@"Error returned from 'genders_load_data' with file (%s)%@",genders_errormsg(handle),self->gendersFilePath);
        return self;
    }
    char **nodelist, **attrlist, **vallist;
    int count, attrlen, vallen;
    count = genders_nodelist_create(handle, &nodelist);
    if(count <= 0) {
        NSLog(@"There was an error getting the nodelist from genders.");
        return self;
    }
    attrlen = genders_attrlist_create(handle, &attrlist);
    if(attrlen <= 0) {
        NSLog(@"There was an error creating an attribute list by genders.");
        return self;
    }
    vallen = genders_vallist_create(handle, &vallist);
    if(vallen <= 0) {
        NSLog(@"There was an error creating an value list by genders.");
        return self;
    }
    int i,setcount,indexOf;

    // queries the genders library to return all nodes that have the attribute "floor" 
    // this means we want the set of all floor verticies
    genders_nodelist_clear(handle,nodelist);
    if(( setcount = genders_query(handle,nodelist,count,"floor")  ) < 1) {
        NSLog(@"Error calling 'genders_getnodes()', or couldn't find any nodes with attribute \"floor\": errmsg: %s",genders_errormsg(handle));
        return self;
    }
    if(floor != nil) {
        NSLog(@"Uh-oh, expected 'nil' in 'floor'.  Can't continue.");
        return [self cleanUp];
    }
    if(setcount > 0) // need to alloc the floor if we found any definitions in the genders file
    //    self->floor = [NSData dataWithBytes: NULL length: 0];
    self->floor = [[NSMutableData dataWithLength:0] retain];//dataWithBytes: NULL length: 0];
    self->floorVertCount = 0;
    for(i = 0; i < setcount; ++i) {
        genders_attrlist_clear(handle,attrlist); genders_vallist_clear(handle,vallist);
        genders_getattr(handle,attrlist,vallist,attrlen,nodelist[i]); // get the floor vertex attributes
        //char zeroes[8];
        //[floor appendBytes: zeroes length: 8];
        int j;
        V3F v[3];
        float *val;
        for(j=0;j<9;++j) {
            NSString *search;
            switch(j) {
                case 0: search = @"x1"; val=&v[0].x; break;
                case 1: search = @"y1"; val=&v[0].y; break;
                case 2: search = @"z1"; val=&v[0].z; break;
                case 3: search = @"x2"; val=&v[1].x; break;
                case 4: search = @"y2"; val=&v[1].y; break;
                case 5: search = @"z2"; val=&v[1].z; break;
                case 6: search = @"x3"; val=&v[2].x; break;
                case 7: search = @"y3"; val=&v[2].y; break;
                case 8: search = @"z3"; val=&v[2].z; break;
            }
            if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:search]) == -1) {
                NSLog(@"Expected a \"%@\" attribute in the genders file for floor triangle: %s but found none! Cannot continue loading the GLDataCenter!",search,nodelist[i]);
                return [self cleanUp];
            }
            (*val) = [[NSString stringWithUTF8String: vallist[indexOf]] floatValue];
        }
        [floor appendBytes: (const void*) v length: sizeof(V3F)*3];
    }

    self->floorVertCount = setcount * 3;
    NSLog(@"Finished loading %d triangles in the floor (from genders file)",setcount);
    
    // queries the genders library to return all nodes that have the attribute "racktype=XXX" 
    // this means we want the set of all racks
    genders_nodelist_clear(handle,nodelist);
    if(( setcount = genders_query(handle,nodelist,count,"racktype")  ) < 1) {
        NSLog(@"Error calling 'genders_getnodes()', or couldn't find any nodes with attribute \"racktype\": errmsg: %s",genders_errormsg(handle));
        return [self cleanUp];
    }
    for(i = 0; i < setcount; ++i) {
        // intanstiate a new rack    //   printf("rack: %s \n",nodelist[i]);
        Rack *rack = [[Rack alloc] initWithName: [[NSString stringWithUTF8String: nodelist[i]] retain]]; //        printf("created that rack\n");
        genders_attrlist_clear(handle,attrlist); genders_vallist_clear(handle,vallist);
        genders_getattr(handle,attrlist,vallist,attrlen,nodelist[i]); // get the rack's attributes

        // Don't need to check this one: we know "racktype" is an attribute in this nodelist because genders_guery(...) guarantees this
        NSString *racktype = [NSString stringWithUTF8String: vallist[[self indexOfAttr:attrlist andLen:attrlen withAttr:@"racktype"]]];

        // The location of the rack
        Vector *l = [[Vector alloc] init];
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"gridx"]) == -1) {
            NSLog(@"Expected a \"gridx\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack getName]);
            return [self cleanUp];
        }
        [l setX: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"gridy"]) == -1) {
            NSLog(@"Expected a \"gridy\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack getName]);
            return [self cleanUp];
        }
        [l setY: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"gridz"]) == -1) {
            NSLog(@"Expected a \"gridz\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack getName]);
            return [self cleanUp];
        }
        [l setZ: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
        [rack setLocation: l];

        // Set the rotation of the rack
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"face"]) == -1) {
            NSLog(@"Expected a \"face\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack getName]);
            return [self cleanUp];
        }
        Vector *r = [[Vector alloc] init];
        NSString *face = [NSString stringWithUTF8String: vallist[indexOf]];
        if([face compare: @"N"] == NSOrderedSame)
            [r setY: -90];
        else if([face compare: @"E"] == NSOrderedSame)
            [r setY: 0];
        else if([face compare: @"S"] == NSOrderedSame)
            [r setY: 90];
        else if([face compare: @"W"] == NSOrderedSame)
            [r setY: 180];
        else
            NSLog(@"Expected face=[N|E|S|W] but found \"%@\", defaulting to \"E\"",face);
        [rack setRotation: r];

        racktype = [[NSString stringWithString: @"rack-"] stringByAppendingString: racktype];
        // racktype will now look something like: "rack-HP"
        genders_getattr(handle,attrlist,vallist,attrlen,[racktype UTF8String]);
        // this is ugly and cryptic (but that's my evil plan...)
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"width"]) == -1) {
            NSLog(@"Expected a \"width\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack getName]);
            return [self cleanUp];
        }
        [rack setWidth: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"height"]) == -1) {
            NSLog(@"Expected a \"height\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack getName]);
            return [self cleanUp];
        }
        [rack setHeight: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"depth"]) == -1) {
            NSLog(@"Expected a \"depth\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack getName]);
            return [self cleanUp];
        }
        [rack setDepth: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
/*        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"color"]) == -1) {
            NSLog(@"Expected a \"color\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack getName]);
            return [self cleanUp];
        }
        [rack setColor: [[NSString stringWithUTF8String: vallist[indexOf]] retain]];*/
        [self addRack: rack];
        [rack autorelease];
    } // at this point we should have all the racks created that we need....
    NSLog(@"Finished creating the racks (loaded from genders file).");
    // Now, query the genders library to return all nodes that have the attribute "rack=XXX" 
    // for us, this means that this set of nodes is a list of nodes
    genders_nodelist_clear(handle,nodelist); setcount = genders_query(handle,nodelist,count,"rack");
    for(i = 0; i < setcount; i++) {
        Node *node; int indexOf;
        // Try to get the nodetype attribute list
        genders_attrlist_clear(handle,attrlist); genders_vallist_clear(handle,vallist);
        if(genders_getattr(handle,attrlist,vallist,attrlen,nodelist[i]) != -1) {
            // Instantiate the node
            node = [[Node alloc] initWithName: [[NSString stringWithUTF8String: nodelist[i]] retain] andDataCenter: self];
            [node setTemperature: 0];

            if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"nodetype"]) == -1) {
                NSLog(@"Expected a \"nodetype\" attribute in the genders file for node=%s but found none! Cannot continue loading the GLDataCenter!",nodelist[i]);
                return [self cleanUp];
            }
            NSString *nodetype = [NSString stringWithUTF8String: vallist[indexOf]]; // save the nodetype name
            nodetype = [[NSString stringWithString: @"node-"] stringByAppendingString: nodetype];

            genders_attrlist_clear(handle,attrlist); genders_vallist_clear(handle,vallist);
            if(genders_getattr(handle,attrlist,vallist,attrlen,[nodetype UTF8String]) == -1) {
                NSLog(@"Error finding nodetype name %@ in the genders file! Cannot continue loading the GLDataCenter!\n",nodetype);
                return [self cleanUp];
            }
            if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"width"]) == -1) {
                NSLog(@"Expected a \"width\" attribute in the genders file for nodetype=%@ but found none! Cannot continue loading the GLDataCenter!",nodetype);
                return [self cleanUp];
            }
            [node setWidth: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
            if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"height"]) == -1) {
                NSLog(@"Expected a \"height\" attribute in the genders file for nodetype=%@ but found none! Cannot continue loading the GLDataCenter!",nodetype);
                return [self cleanUp];
            }
            [node setHeight: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
            if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"depth"]) == -1) {
                NSLog(@"Expected a \"depth\" attribute in the genders file for nodetype=%@ but found none! Cannot continue loading the GLDataCenter!",nodetype);
                return [self cleanUp];
            }
            [node setDepth: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
            // Now, get the node's attribute list
            genders_attrlist_clear(handle,attrlist); genders_vallist_clear(handle,vallist);
            if(genders_getattr(handle,attrlist,vallist,attrlen,nodelist[i]) != -1) {
                int indexOf;
                if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"rack"]) == -1) {
                    NSLog(@"Expected a \"rack\" attribute in the genders file for node=%s but found none! Cannot continue loading the GLDataCenter!",nodelist[i]);
                    return [self cleanUp];
                }
                NSString *rackName = [[NSString stringWithUTF8String: vallist[indexOf]] retain];
                Rack *actualRack = [racks objectForKey: rackName];
                if(actualRack == nil) { 
                    NSLog(@"Error finding rack name %@ in the genders file! Cannot continue loading the GLDataCenter!\n",rackName);
                    return [self cleanUp];
                }
                int y = [actualRack nodeCount];
                // the reason we do this is because we want the node names to be displayed differently
                // for even nodes (left aligned), odd nodes (right aligned) or something like that
                if(y % 2 != 0) [node setIsodd: YES];    // make every other node odd...
                Vector *l = [[Vector alloc] init];
                if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"vposition"]) == -1) {
                    NSLog(@"Expected a \"vposition\" attribute in the genders file for node=%s but found none! Cannot continue loading the GLDataCenter!",nodelist[i]);
                    return [self cleanUp];
                }
                [[[l setX: 0] setY: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]] setZ: 0];
                [node setLocation: l];
                [actualRack addNode: node]; // Add the node object to the rack object
            }else{
                NSLog(@"genders_getattr(handle,attrlist,vallist,attrlen,\"%s\") failed with msg: \"%s\" attrlen=%d\n",nodelist[i],genders_errormsg(handle),attrlen);
                [self cleanUp];
            }
        }
    }
    NSLog(@"Finished creating the nodes (loaded from genders file).");
    // destroy the nodelist,attrlist,and vallist
    if(genders_nodelist_destroy(handle, nodelist) == -1) NSLog(@"There was an error when calling 'genders_nodelist_destroy(handle,nodelist)'");
    if(genders_attrlist_destroy(handle, attrlist) == -1) NSLog(@"There was an error when calling 'genders_attrlist_destroy(handle,attrlist)'");
    if(genders_vallist_destroy(handle, vallist) == -1) NSLog(@"There was an error when calling 'genders_vallist_destroy(handle,vallist)'");
    
    /* print to std out */
	/*
    NSEnumerator *e = [racks objectEnumerator];

    Rack *r;
    while( (r = [e nextObject]) ) {
        printf("%s %s\n",[[r getName] UTF8String], [[r getNodeNames] UTF8String]);
    }*/
    return self;
}
-initWithPList: (id)list {
	NSLog(@"initWithPList: %@",[self class]);
	[super initWithPList: list];
	/// @todo error checking or exception handling.
	Class c;
	DataSet *ds;
	c = NSClassFromString([list objectForKey: @"dataSetClass"]);
	if (c && [c conformsToProtocol: @protocol(PList)] && [c isSubclassOfClass: [DataSet class]]) {
		ds=[c alloc];
		[[ds initWithPList: [list objectForKey: @"dataSet"]] disableScaling];
        self->dataSet = ds;
	}
    self->gendersFilePath = [[list objectForKey: @"gendersFilePath" missing: @"/etc/genders"] retain];

    NSLog(@"gendersFilePath = %@", self->gendersFilePath);
	c = NSClassFromString([list objectForKey: @"dataSetClass"]);
	if (c && [c conformsToProtocol: @protocol(PList)] && [c isSubclassOfClass: [DataSet class]]) {
		ds=[c alloc];
		[ds initWithPList: [list objectForKey: @"jobIDDataSet"]];
        jobIds = [[ds retain] disableScaling];
	}
	self->drawLegend = [[list objectForKey: @"drawLegend"] boolValue];
	self->legend_padd_side = [[list objectForKey: @"legend_padd_side"] floatValue];
	self->legend_padd_top = [[list objectForKey: @"legend_padd_top"] floatValue];
	self->red = [[list objectForKey: @"red" missing: [NSNumber numberWithFloat: self->red]] floatValue];
	self->green = [[list objectForKey: @"green" missing: [NSNumber numberWithFloat: self->green]] floatValue];
	self->blue = [[list objectForKey: @"blue" missing: [NSNumber numberWithFloat: self->blue]] floatValue];
    [self doInit];
    //[Node setWebDataSet: (WebDataSet*)self->dataSet];
    return self;
}
-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [super getPList]];
	[dict setObject: [dataSet getPList] forKey: @"dataSet"];
	[dict setObject: [jobIds getPList] forKey: @"jobIDDataSet"];
	[dict setObject: [dataSet class] forKey: @"dataSetClass"];
	[dict setObject: self->gendersFilePath forKey: @"gendersFilePath"];
	[dict setObject: [NSNumber numberWithBool: self->drawLegend] forKey: @"drawLegend"];
	[dict setObject: [NSNumber numberWithFloat: self->legend_padd_side] forKey: @"legend_padd_side"];
	[dict setObject: [NSNumber numberWithFloat: self->legend_padd_top] forKey: @"legend_padd_top"];
	[dict setObject: [NSNumber numberWithFloat: self->red] forKey: @"red"];
	[dict setObject: [NSNumber numberWithFloat: self->green] forKey: @"green"];
	[dict setObject: [NSNumber numberWithFloat: self->blue] forKey: @"blue"];

	return dict;
}
-(void)dealloc {
    [self->gendersFilePath autorelease];
    [self->floor autorelease];
    [super dealloc];
}
-(DataSet*)dataSet {
	return dataSet;
}
-(WebDataSet*)jobIds {
	return self->jobIds;
}
-(GLText*)gltName {
	return gltName;
}
-setGltName:(GLText*)_gltName{
	self->gltName = _gltName;
	return self;
}
-(ColorMap*)colorMap {
	return colorMap;
}
-setColorMap:(ColorMap*) _colorMap{
	self->colorMap = _colorMap;
	return self;
}
-(double)currentMax {
	return currentMax;
}
-setCurrentMax:(double) _currentMax {
	self->currentMax = _currentMax;
	return self;
}

// Used for debugging purposes only
-drawOriginAxis {
    glPushMatrix();
    //glLoadIdentity();
    glBegin(GL_LINES);
    //glLineWidth(5.0); // this generates a GL_INVALID_OPERATION, comment out
    glColor3f(1.0,0,0);
    glVertex3f(-10000,0,0);
    glVertex3f(10000,0,0);
    glVertex3f(0,-100000,0);
    glVertex3f(0,10000,0);
    glVertex3f(0,0,-10000);
    glVertex3f(0,0,10000);
    glEnd();
    int x = 1000;
    glColor3f(0,0,1);
    drawString3D( x,0,0,GLUT_BITMAP_HELVETICA_12,@"  +X-Axis", 0);
    drawString3D(-x,0,0,GLUT_BITMAP_HELVETICA_12,@"  -X-Axis", 0);
    drawString3D(0, x,0,GLUT_BITMAP_HELVETICA_12,@"  +Y-Axis", 0);
    drawString3D(0,-x,0,GLUT_BITMAP_HELVETICA_12,@"  -Y-Axis", 0);
    drawString3D(0,0, x,GLUT_BITMAP_HELVETICA_12,@"  +Z-Axis", 0);
    drawString3D(0,0,-x,GLUT_BITMAP_HELVETICA_12,@"  -Z-Axis", 0);
    glPopMatrix();
    return self;
}
-drawGrid {
#define TILE_WIDTH              24
#define TILE_LENGTH             24
    glBegin(GL_LINES);
    glColor3f(0,0,0);
    int nx = -10, ny = 100;
    int i;
    for(i=nx;i<ny;++i) {
        glVertex3f(-nx*TILE_WIDTH,-1,i*TILE_WIDTH);
        glVertex3f(-ny*TILE_WIDTH,-1,i*TILE_WIDTH);
        glVertex3f(-i*TILE_WIDTH,-1,nx*TILE_WIDTH);
        glVertex3f(-i*TILE_WIDTH,-1,ny*TILE_WIDTH);
   }
    glEnd();
    return self;
}
-addRack: (Rack*) rack {
    // Add the passed rack to our rackArray
    if(self->racks != nil) {
        [self->racks setObject: rack forKey: [rack getName]];
    }
    return self;
}
-drawFloor {
    // No textures for now...
    glDisable(GL_TEXTURE_2D);
    glColor3f(0.5,0.5,0.5);  // grey
    // Draw the rack itself, consisting of 6 sides
//    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glInterleavedArrays(GL_V3F, 0, [self->floor mutableBytes]);
    glDrawArrays(GL_TRIANGLES, 0, self->floorVertCount);
    //glCullFace(GL_FRONT);*/
    return self;
}
-glPickDraw {
    [[self->racks allValues] makeObjectsPerformSelector:@selector(glPickDraw)];
    return self;
}
-glDrawLegend {
	float width,height;
	
//	NSLog(@"currentMax = %f", currentMax);
//	return self;
/*
	if(currentMax < .0000001 && currentMax > -.000000001) {
		NSLog(@"currentMax = 0.0: drawing the legend would cause a divide by zero! not drawing it.");
		return self;
	}*/
//	NSLog(@"width = %f, height = %f", [dataSet width], [dataSet height]);
	GLint viewport[4];
	glGetIntegerv(GL_VIEWPORT, viewport);
	width=viewport[2];
	height=viewport[3];
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	gluOrtho2D(0, width, 0, height);
	glScalef(1.0, -1.0, 1.0);
	glTranslatef(0.0, -height, 0.0);
	glMatrixMode(GL_MODELVIEW);
	glEnable(GL_BLEND);
	glPushMatrix();
	glClear(GL_DEPTH_BUFFER_BIT);
	//glScalef(xscale,yscale,zscale); 	
//	glClear (GL_COLOR_BUFFER_BIT);
	glLoadIdentity();
//	NSLog(@"width = %f, height = %f", width, height);

	float posX=0,posY=0;
	float leg_width = 100,leg_height = 175;
	switch(self->legend_location) {
		case 0:
			posX = legend_padd_side;
			posY = legend_padd_top;
			break;
		case 1:
			posX = width - leg_width - legend_padd_side;
			posY = legend_padd_top;
			break;
		case 2:
			posX = width - leg_width - legend_padd_side;
			posY = height - leg_height - legend_padd_top;
			break;
		case 3:
			posX = legend_padd_side;
			posY = height - leg_height - legend_padd_top;
			break;
		default:
			[NSException raise: @"Invalid GLDataCenter.legend_location value"
				format: @"GLDataCenter.legend_location = %d", self->legend_location];
			break;
	}
	glTranslatef(posX, posY, 0.0);
	glPushMatrix();
	//	glTranslatef(s/4, 0.0, 0.0);
		glBegin(GL_POLYGON);
			glColor3f(red,green,blue);
			glVertex2f(0,0); 
			glVertex2f(leg_width,0); // The top right corner  
			glVertex2f(leg_width,leg_height); // The bottom right corner  
			glVertex2f(0,leg_height); // The bottom left corner
		glEnd( );
		glFlush( );
	glPopMatrix();

	

	int b = 20;
	glTranslatef(.3*leg_width, leg_height-b, 0.0);
	glBegin(GL_LINES);
	//for (i=1;i<currentMax+1;i++) {
	
	int i;
	for (i=1;i<leg_height-2*b;i++) {
		[colorMap glMap: i * currentMax / (leg_height - 2*b)];
		//glColor3f(1.0,1.0,1.0);
		glVertex2f(-7,-i);
		glVertex2f(0,-i);
	}
	//NSLog(@"i = %d, scaled = %f", i, i * currentMax / (leg_height - 2*b));
	glEnd();
	glColor3f(1.0,1.0,1.0);

	glBegin(GL_LINES);
	//for (i=0;i<currentMax+1;i+=(int)MAX(4,currentMax/5)) {
	//for (i=0;i<leg_height-2*b+1;i+=(int)(MAX(4,currentMax/5) * (leg_height - 2*b) / currentMax )) {
	for (i=0;i<leg_height-2*b+1;i+=(int)(MAX(4, (leg_height - 2*b)/5))) {
		glVertex2f(-9,-i);
		glVertex2f(2,-i);
	}
	glEnd();

	float xscale = 1.0;
//	for (i=0;i<currentMax+1;i+=(int)MAX(4,currentMax/5)) {
	//for (i=0;i<leg_height-2*b+1;i+=(int) ( MAX(4,currentMax/5) * (leg_height - 2*b) / currentMax ) ) {
	for (i=0;i<leg_height-2*b+1;i+=(int)(MAX(4, (leg_height - 2*b)/5))) {
		//NSLog(@"drawing a string *** i = %d, currentMax = %f",i,currentMax);
		drawString3D(4.0/xscale,-i,0,GLUT_BITMAP_HELVETICA_12,[dataSet getLabel: i * currentMax / (leg_height - 2*b)],1.0);
	}

	glPopMatrix();

	glDisable(GL_BLEND);
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	return self;
}
-(NSArray *)attributeKeys {
	//isVisible comes from the DrawableObject
	return [NSArray arrayWithObjects: @"isVisible",@"drawLegend",@"legend_location",@"legend_padd_side",@"legend_padd_top",@"scale",@"red",@"green",@"blue",nil];
}
-(NSDictionary *)tweaksettings {
	return [NSDictionary dictionaryWithObjectsAndKeys:
		@"min=0 max=1 step=1",@"isVisible",
		@"min=0 max=1 step=1",@"drawLegend",
		@"min=0 max=3 step=1",@"legend_location",
		@"min=0 step=1",@"legend_padd_side",
		@"min=0 step=1",@"legend_padd_top",
		@"min=0 max=1000 step=.001",@"scale",
		@"min=0.0 max=1.0 step=0.001",@"red",
		@"min=0.0 max=1.0 step=0.001",@"green",
		@"min=0.0 max=1.0 step=0.001",@"blue",
		nil];
}
-(Node*)selectedNode {
	return self->selectedNode;
}
-setSelectedNode:(Node*)_selectedNode {
	self->selectedNode = _selectedNode;
	return self;
}
-glDraw {
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_NEAREST);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    [self drawFloor];
    [[self->racks allValues] makeObjectsPerformSelector:@selector(glDraw)]; // draw the racks
	if(self->drawLegend)
		[self glDrawLegend];

    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError, error number: %x", err);
    return self;
}
-(NSEnumerator*) getEnumerator {
    NSEnumerator *enumerator = [self->racks objectEnumerator];
    return enumerator;
}
-description {
	return @"GLDataCenter";
}
@end
