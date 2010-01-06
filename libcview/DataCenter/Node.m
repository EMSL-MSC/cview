#import "Node.h"
#import <Foundation/NSString.h>
#import <gl.h>
#import <glut.h>
#import "IsleOffsets.h"
#import "../../libcview-data/WebDataSet.h"
@implementation Node
static VertArray *nodeArray;
static WebDataSet *dataSet;
static GLText *gltName;
+(void)setNodeArray:(VertArray*)_nodeArray {
    nodeArray = _nodeArray;
}
+(void)setWebDataSet:(WebDataSet*)_dataSet {
    dataSet = [_dataSet retain];
}
+setGLTName:(GLText*) _gltName {
    gltName = _gltName;
    return self;
}
-init {
    [super init];
    self->drawname = YES;
    self->fading = NO;
    self->unfading = NO;
    self->fadetime = 2.5;    // in seconds
    self->fadestart = 0;
    self->fadeval = 1;  // default to full opacity
    return self;
 }
-initWithName:(NSString*)_name {
    [self init];
    [self setName: _name];
        return self;
}
-(void)dealloc {
    if(dataSet != nil)
        [dataSet release];
    return [super dealloc];
}
-startFading {
    fading = YES;
    unfading = NO;
    return self;
}
-startUnFading {
    //NSLog(@"called UNFADING, node: %@", [self getName]);
    unfading = YES;
    fading = NO;
    return self;
}
-(float)getData: (NSString*)nodeName {
    // First find the nodename in the xticks array
    //DataSet *ds = [myDCG getDataSet];
    float *row = [dataSet dataRowByString: nodeName];
    if(row != NULL) {
        //NSLog(@"row[0] = %f", row[0]);
        return row[0];
    }else {
        //NSLog(@"[Node getData] called [dataSet dataRowByString] and got a zero pointer!");
        return -1;
    }
}
extern VertArray* createBox(float w, float h, float d);
-draw {

    double thetime = [[NSDate date] timeIntervalSince1970]; // get current time in seconds
    if(fading == YES || unfading == YES) { // check to see if we should fade/unfade
        double scale = 0.0; // must be between 0 and 1, inclusive
        if(wasfading == NO) {
            fadestart = thetime;    //we just started fading
            wasfading = YES;
            if( (fading == YES && fadeval == scale) ||
                (unfading == YES && fadeval == 1.0) )
                thetime = fadetime + fadestart + 1.0; // push it over the top
        }
        if(thetime - fadestart > fadetime) {    // time to stop fading
            if(fading == YES)
                fadeval = scale;
            else if(unfading == YES)
                fadeval = 1.0;
            fading = NO;
            unfading = NO;
            wasfading = NO;
            //NSLog(@"ENDED FADING!!!!");
        }else{  // we're still fading baby!!!
            fadeval = (1/fadetime)*(thetime-fadestart); // calculate the fade
            if(fading == YES) 
                fadeval = 1-fadeval;    // fading out, not in
            fadeval = scale+(1-scale)*fadeval;
        }
        glutPostRedisplay();    // Tell glut to draw again - we're still fading
    //NSLog(@"fadeval = %f",fadeval);
    }
    if(fadeval != 0) {  // only draw this node if we're not completely faded out.
        if(nodeArray == NULL) {
            nodeArray = createBox([self getWidth],[self getHeight],[self getDepth]);
            NSLog(@"width = %f height = %f depth = %f", [self getWidth],[self getHeight],[self getDepth]);
        }
        glPushMatrix();
        glTranslatef(0,STANDARD_NODE_HEIGHT*([[self getLocation] gety]+1),0);
        [self setTemperature: [self getData: [self getName]]];
        if(self->temperature != -1)
            self->temperature /=  100.0;

        glEnable(GL_BLEND);
        if(temperature == -1)// No valid data found from the dataSet    
            glColor4f(1,1,1,fadeval);// color the node white
        else
            glColor4f(temperature, 1-temperature, 0, fadeval);
        glInterleavedArrays(GL_T2F_V3F, 0, nodeArray->verts);
        glDrawArrays(GL_QUADS, 0, nodeArray->vertCount);    // Draw the node
        glTranslatef(STANDARD_NODE_DEPTH,0,0);
        if(drawname == YES) {
            if(gltName == nil) {
                gltName = [[GLText alloc] initWithString: [self getName] andFont: @"LinLibertine_Re.ttf"];
                [gltName setScale: .06];
                [gltName setRotationOnX: 0 Y: 0 Z: 180];
                [gltName setColorRed: 0 Green: 0 Blue: 0];
            }
            [gltName setString: [[self getName] lowercaseString]];
            if([[self getLocation] gety] % 2 == 0)  // every other node, change name locations
                glTranslatef(-20,0,-0.5*STANDARD_NODE_DEPTH-1);
            else
                glTranslatef(-30,0,-0.5*STANDARD_NODE_DEPTH-1);
                
            [gltName glDraw];   // Draw the node name
        }
        glPopMatrix();
    }
    return self;
}
-(NSMutableArray*)pickDrawX: (int) x andY: (int) y {
    NSMutableArray *ret = nil;


    //TODO: do the pick
    if(YES) { //if picked
        ret = [[NSMutableArray alloc] init];
        [ret addObject: self];
    }
    return ret;
        
}
-setTemperature: (float) _temperature {
    self->temperature = _temperature;
    return self;
}
-(float)getTemperature {
    return self->temperature;
}
@end
