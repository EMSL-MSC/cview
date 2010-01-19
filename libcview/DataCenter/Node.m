#import "Node.h"
#import <Foundation/NSString.h>
#import <gl.h>
#import <glut.h>
#import "AisleOffsets.h"
#import "../../libcview-data/WebDataSet.h"
@implementation Node
//static VertArray *nodeArray;
static WebDataSet *dataSet;
static GLText *gltName;
+(void)setWebDataSet:(WebDataSet*)_dataSet {
    dataSet = [_dataSet retain];
}
+setGLTName:(GLText*) _gltName {
    gltName = _gltName;
    return self;
}
-init {
    [super init];
    self->drawname = NO;
    self->fading = NO;
    self->unfading = NO;
    self->selected = NO;
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
    }
    if(selected == YES || fadeval != 0) {  // only draw this node if we're not completely faded out or selected
        [super setupForDraw];
            [self setTemperature: [self getData: [self getName]]];
            if(self->temperature != -1)
                self->temperature /=  100.0;

            glEnable(GL_BLEND);
            if(selected == YES)
                glColor4f(.1,.1,.1,1);
            else if(temperature == -1)// No valid data found from the dataSet    
                glColor4f(1,1,1,fadeval);// color the node white
            else
                glColor4f(temperature, 1-temperature, 0, fadeval);
            [super draw];    // draw a box around the node

            if(drawname == YES) {
                glTranslatef(STANDARD_NODE_DEPTH,0,0);
                if(gltName == nil) {
                    gltName = [[GLText alloc] initWithString: [self getName] andFont: @"LinLibertine_Re.ttf"];
                    [gltName setScale: .06];
                    [gltName setRotationOnX: 0 Y: 0 Z: 180];
                    [gltName setColorRed: 0 Green: 0 Blue: 0];
                }
                [gltName setString: [[self getName] lowercaseString]];
                if(isodd == YES)  // every other node, change name locations
                    glTranslatef(-20,0,-0.5*STANDARD_NODE_DEPTH-1);
                else
                    glTranslatef(-30,0,-0.5*STANDARD_NODE_DEPTH-1);
                    
                [gltName glDraw];   // Draw the node name
            }
        [super cleanUpAfterDraw];
    }
    return self;
}
-glPickDraw {
    [super setupForDraw];
        [super glPickDraw];
    [super cleanUpAfterDraw];
    return self;
}
-setTemperature: (float) _temperature {
    self->temperature = _temperature;
    return self;
}
-(float)getTemperature {
    return self->temperature;
}
-setIsodd: (BOOL)_isodd {
    isodd = _isodd;
    return self;
}
-setSelected:(BOOL)_selected {
    self->selected = _selected; 
//    NSLog(@"selection is %d", _selected);
    glutPostRedisplay();
    return self;
}
@end
