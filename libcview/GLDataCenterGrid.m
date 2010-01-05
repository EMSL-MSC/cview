#import <Foundation/Foundation.h>
#import <gl.h>
#import <glut.h>
#import "cview.h"
#import "DataSet.h"
#import "GLDataCenterGrid.h"
#import "DataCenter/IsleOffsets.h"
#import "DataCenterLoader.h"
#import "DictionaryExtra.h"
void drawString3D(float x,float y,float z,void *font,NSString *string,float offset);
extern GLuint g_textureID;
@implementation  GLDataCenterGrid
// TODO: update this draw function
-init {
    [super init];
    self->csvFilePath = nil;
    self->jobIds = nil;
    self->jobIdIndex = 0;
    [self doInit];
    [Node setNodeArray: NULL];
    [Rack setRackArray: NULL];
    [Rack setGLTName: nil];
    [Node setGLTName: nil];
    return self;
}
-(NSString*) get_csvFilePath {
    return self->csvFilePath;
}
-doInit {
    self->isles = [[DrawableArray alloc] init];
    self->floorArray1 = [IsleOffsets getDataCenterFloorPart1];
    self->floorArray2 = [IsleOffsets getDataCenterFloorPart2];
    self->floorArray3 = [IsleOffsets getDataCenterFloorPart3];
    if(self->csvFilePath != nil) {
        DataCenterLoader *dcl = [[DataCenterLoader alloc] init];
        [dcl LoadGLDataCenterGrid: self];
        [dcl autorelease];
    }
    return self;
}
-(Node*)findNodeObjectByName:(NSString*) _name {
    //NSLog(@"name = %@", _name);
    if(self->isles == nil)
        return nil;
    NSEnumerator *enumerator = [self->isles getEnumerator];
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
-(DrawableArray*)getNodesRunningAJobID:(float) jobid {
    int i;
    float *dl;
    DrawableArray *nodeArray = [[DrawableArray alloc] init];
    for(i=0;i<[jobIds width];++i) {
        dl = [jobIds dataRow: i];
//        dl[0] should be all we care about here...
        if(jobid == dl[0]) {
            Node *node =  [self findNodeObjectByName: [jobIds columnTick: i]];
            if(node != nil)
                [nodeArray addDrawableObject: node];
            //NSLog(@"columtick: %@", [jobIds columnTick: i]);
        }

    }
    //[nodeArray autorelease];
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
-fadeEverythingExceptJobID:(float) jobid {
    if(self->isles == nil)
        return self;
    NSEnumerator *enumerator = [self->isles getEnumerator];
    if(enumerator == nil)
        return self;
    id element;
    //loop through all isles, tell them to ---fade--- MUHAHAHA!
    while((element = [enumerator nextObject]) != nil)
        [element startFading];
    
    //now, tell the nodes with our passed jobid to UNFADE
    DrawableArray *arr = [self getNodesRunningAJobID: jobid];
    NSLog(@"Number of nodes in this job: %d", [arr count]);
    if(arr == nil)
        return self;
    [arr retain];
    enumerator = [arr getEnumerator];//segfaults
    if(enumerator == nil) {
        [arr autorelease];
        return self;
    }
    while((element = [enumerator nextObject]) != nil)
        [element startUnFading];
    [arr autorelease];
    return self;
}
-initWithPList: (id)list {
    NSLog(@"initWithPList: %@", [self class]);
    [super initWithPList: list];

    self->csvFilePath = [[list objectForKey: @"csvFilePath"
            missing: @"data/Chinook Serial numbers.csv"] retain];
    NSLog(@"csvFilePath = %@", self->csvFilePath);
    DataSet *ds;
	Class c;
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
-(void)dealloc {
    [csvFilePath release];
    [super dealloc];
}
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
-addIsle: (Isle*) isle {
    // Add the passed rack to our rackArray
    self->isles = [self->isles addDrawableObject: isle];
    return self;
}
-draw {
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_NEAREST);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    //[self drawOriginAxis];
    [self drawFloor];
    //[self drawGrid];
    [self->isles draw];
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError, error number: %x", err);
    return self;
}
-drawFloor {
    //TODO: add stuff here to draw floor tiles
    if(self->floorArray1 == NULL || self->floorArray2 == NULL || self->floorArray3 == NULL)
        return self;
    // No textures for now...
    glDisable(GL_TEXTURE_2D);
    glColor3f(0.5,0.5,0.5);
    // Draw the rack itself, consisting of 6 sides
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glInterleavedArrays(GL_T2F_V3F, 0, self->floorArray1->verts);
    glDrawArrays(GL_POLYGON, 0, self->floorArray1->vertCount);

    glInterleavedArrays(GL_T2F_V3F, 0, self->floorArray2->verts);
    glDrawArrays(GL_POLYGON, 0, self->floorArray2->vertCount);

    glInterleavedArrays(GL_T2F_V3F, 0, self->floorArray3->verts);
    glDrawArrays(GL_POLYGON, 0, self->floorArray3->vertCount);

    //glCullFace(GL_FRONT);

    return self;
}
    
-glDraw {
    [self draw];
    return self;

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
    return self;
}
-(NSEnumerator*) getEnumerator {
    NSEnumerator *enumerator = [self->isles getEnumerator];
    return enumerator;
}

@end
