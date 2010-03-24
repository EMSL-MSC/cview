#include <string.h>
#import <Foundation/Foundation.h>
#import <gl.h>
#import <glut.h>
#import "cview.h"
#import "DataSet.h"
#import "GLDataCenter.h"
#import "DictionaryExtra.h"
#include <genders.h>
void drawString3D(float x,float y,float z,void *font,NSString *string,float offset);
extern GLuint g_textureID;
@implementation  GLDataCenter
-init {
    [super init];
    self->floor = nil;
    self->floorVertCount = 0;
//    self->csvFilePath = nil;
    self->gendersFilePath = nil;
    self->jobIds = nil;
    self->jobIdIndex = 0;
    [Rack setGLTName: nil];
    [Node setGLTName: nil];
    return self;
}
-doInit {
    self->racks = [[NSMutableDictionary alloc] init];
    [self initWithGenders]; // use the genders file to initialize the data center
    return self;
}
-(Node*)findNodeObjectByName:(NSString*) _name {
    //NSLog(@"name = %@", _name);
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
            //NSLog(@"columtick: %@", [jobIds columnTick: i]);
        }

    }
    [nodeArray autorelease];//auto or regular, not really sure which to use....
    return nodeArray;
}
-doStuff {
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
    float *row = [jobIds dataRowByString: [n name]];
    if(row != NULL)
        return row[0];
    //NSLog(@"row was NULL-node: %@", [[n getName] lowercaseString]);
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
    char **nodelist;
    char **attrlist;
    char **vallist;
    int count;
    int attrlen;
    int vallen;
    count = genders_nodelist_create(handle, &nodelist);
    if(count <= 0) {
        NSLog(@"There was an error getting the nodelist from genders.");
        return self;
    }
    attrlen = genders_attrlist_create(handle, &attrlist);
//    NSLog(@"genders returned an attrlen of %d",attrlen);
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
        self->floor = [[NSMutableData alloc] init];//dataWithBytes: NULL length: 0];
    self->floorVertCount = 0;
    for(i = 0; i < setcount; ++i) {
        genders_attrlist_clear(handle,attrlist); genders_vallist_clear(handle,vallist);
        genders_getattr(handle,attrlist,vallist,attrlen,nodelist[i]); // get the floor vertex attributes

        char zeroes[8];
        [floor appendBytes: zeroes length: 8];
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
            NSLog(@"%@ = %f",search,*val);
/*
            typedef struct
            {
                float x,y,z;
            }V3F;
*/
        }
        [floor appendBytes: (const void*) v length: sizeof(V3F)*3];
//        self->floor = [[NSData dataWithBytes: (const void*) v length: sizeof(V3F)*3];
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

        Vector *l = [[Vector alloc] init];
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"gridx"]) == -1) {
            NSLog(@"Expected a \"gridx\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack name]);
            return [self cleanUp];
        }
        [l setx: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"gridy"]) == -1) {
            NSLog(@"Expected a \"gridy\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack name]);
            return [self cleanUp];
        }
        [l sety: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"gridz"]) == -1) {
            NSLog(@"Expected a \"gridz\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack name]);
            return [self cleanUp];
        }
        [l setz: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
        [rack setLocation: l];


        racktype = [[NSString stringWithString: @"rack-"] stringByAppendingString: racktype];
        // racktype will now look something like: "rack-HP"
        genders_getattr(handle,attrlist,vallist,attrlen,[racktype UTF8String]);
        // this is ugly and cryptic (but that's my evil plan...)
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"width"]) == -1) {
            NSLog(@"Expected a \"width\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack name]);
            return [self cleanUp];
        }
        [rack setWidth: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"height"]) == -1) {
            NSLog(@"Expected a \"height\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack name]);
            return [self cleanUp];
        }
        [rack setHeight: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"depth"]) == -1) {
            NSLog(@"Expected a \"depth\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack name]);
            return [self cleanUp];
        }
        [rack setDepth: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]];
/*        if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"color"]) == -1) {
            NSLog(@"Expected a \"color\" attribute in the genders file for rack=%@ but found none! Cannot continue loading the GLDataCenter!",[rack name]);
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
//        printf("node: %s ",nodelist[i]);
        // Try to get the nodetype attribute list
        genders_attrlist_clear(handle,attrlist); genders_vallist_clear(handle,vallist);
        if(genders_getattr(handle,attrlist,vallist,attrlen,nodelist[i]) != -1) {
            // Instantiate the node
            node = [[Node alloc] initWithName: [[NSString stringWithUTF8String: nodelist[i]] retain]];
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
//            NSLog(@"node=%@ width=%f height=%f depth=%f",[node name],[node width],[node height],[node depth]);
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
                }//else NSLog(@"Found the rack!");
                int y = [actualRack nodeCount];
                // the reason we do this is because we want the node names to be displayed differently
                // for even nodes (left aligned), odd nodes (right aligned) or something like that
                if(y % 2 != 0) [node setIsodd: YES];    // make every other node odd...
                Vector *l = [[Vector alloc] init];
                if((indexOf = [self indexOfAttr:attrlist andLen:attrlen withAttr:@"vposition"]) == -1) {
                    NSLog(@"Expected a \"vposition\" attribute in the genders file for node=%s but found none! Cannot continue loading the GLDataCenter!",nodelist[i]);
                    return [self cleanUp];
                }
                [[[l setx: 0] sety: [[NSString stringWithUTF8String: vallist[indexOf]] floatValue]] setz: 0];
                [node setLocation: l];
                [actualRack addNode: node]; // Add the node object to the rack object
    /*****************************************************/
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
		[ds initWithPList: [list objectForKey: @"dataSet"]];
        self->dataSet = ds;
	}
    self->gendersFilePath = [[list objectForKey: @"gendersFilePath" missing: @"data/genders"] retain];
    NSLog(@"gendersFilePath = %@", self->gendersFilePath);
	c = NSClassFromString([list objectForKey: @"dataSetClass"]);
	if (c && [c conformsToProtocol: @protocol(PList)] && [c isSubclassOfClass: [DataSet class]]) {
		ds=[c alloc];
		[ds initWithPList: [list objectForKey: @"jobIDDataSet"]];
        jobIds = [ds retain];
	}
    [self doInit];
    [Node setWebDataSet: (WebDataSet*)self->dataSet];
    return self;
}
-getPList {
	NSLog(@"getPList: %@",self);
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [super getPList]];
	[dict setObject: [dataSet getPList] forKey: @"dataSet"];
	[dict setObject: [jobIds getPList] forKey: @"jobIDDataSet"];
	[dict setObject: [dataSet class] forKey: @"dataSetClass"];
	return dict;
}
-(void)dealloc {
    [self->gendersFilePath autorelease];
    [self->floor autorelease];
    [super dealloc];
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
 //       NSLog(@"about to add a rack...(%@)",[rack name]);
        [self->racks setObject: rack forKey: [rack name]];
 //       NSLog(@"Done.");
    }
    return self;
}
-drawFloor {
    // No textures for now...
    glDisable(GL_TEXTURE_2D);
    glColor3f(0.5,0.5,0.5);  // grey
    // Draw the rack itself, consisting of 6 sides


    V3F v[3];
    v[0].x = 0; v[0].y = 0; v[0].z = 0;
    v[1].x = 0; v[1].y = 0; v[1].z = 1000;
    v[2].x = -300; v[2].y = 0; v[2].z = 1000;

//    glInterleavedArrays(GL_V3F, 0, &v);
//    glDrawArrays(GL_TRIANGLES, 0, 3);


//    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);

//    glInterleavedArrays(GL_T2F_V3F, 0, [self->floor bytes]);
    glInterleavedArrays(GL_V3F, 0, [self->floor mutableBytes]);
    glDrawArrays(GL_TRIANGLES, 0, self->floorVertCount);
    NSLog(@"floorVertCount = %d", floorVertCount);
    
    V3F t[1000];
    memcpy(t,[self->floor mutableBytes],sizeof(V3F)*floorVertCount);
    int y;
    for(y=0;y<floorVertCount;++y) {
        NSLog(@"t[%d].x = %f t[%d].y = %f t[%d].z = %f",y,t[y].x,y,t[y].y,y,t[y].z);
    }
    NSLog(@"floorVertCount = %d", floorVertCount);

    //glCullFace(GL_FRONT);

    return self;
}
-draw {
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_NEAREST);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    [self drawOriginAxis];
    [self drawFloor];
    //[self drawGrid];
//    [[self->racks allValues] makeObjectsPerformSelector:@selector(draw)]; // draw the racks
    //NSLog(@"count: %d", [aisles count]);

    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError, error number: %x", err);
    return self;
}
-glPickDraw {
    [[self->racks allValues] makeObjectsPerformSelector:@selector(glPickDraw)];
    return self;
}
-glDraw {
    [self draw];
    return self;
/*
    float max = [dataSet getScaledMax];
	
	if (currentMax != max) {
		NSLog(@"New Max: %.2f %.2f",max,currentMax);
		currentMax = max;
		[colorMap autorelease];
		colorMap = [ColorMap mapWithMax: currentMax];
		[colorMap retain];
	}
	glScalef(1.0,1.0,1.0); 
    [self draw];
    //[self drawFloor];
	//[self drawPlane];
	//[self drawData];
	[self drawAxis];
	//[self drawTitles];
    return self;*/
}
-(NSEnumerator*) getEnumerator {
    NSEnumerator *enumerator = [self->racks objectEnumerator];
    return enumerator;
}

@end
