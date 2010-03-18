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
static ColorMap *colorMap;
static double currentMax = 0.0;

+(void)setWebDataSet:(WebDataSet*)_dataSet {
    dataSet = [_dataSet retain];
}
+setGLTName:(GLText*) _gltName {
    gltName = _gltName;
    return self;
}
-cleanUp {
    // maybe add stuff here later

    [self autorelease];
    return self;
}
-init {
    [super init];
    self->drawname = YES;
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
    float *row = [dataSet dataRowByString: [nodeName uppercaseString]];
    if(row != NULL) {
        //NSLog(@"row[0] = %f", row[0]);
        return row[0];
    }else {
        //NSLog(@"[Node getData] called [dataSet dataRowByString] and got a zero pointer!");
        return -1;
    }
}
-draw {
//    NSLog(@"node=%@ width=%f height=%f depth=%f",[self name],[self width],[self height],[self depth]);
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
        }else{  // we're still fading
            fadeval = (1/fadetime)*(thetime-fadestart); // calculate the fade
            if(fading == YES) 
                fadeval = 1-fadeval;    // fading out, not in
            fadeval = scale+(1-scale)*fadeval;
        }
        glutPostRedisplay();    // Tell glut to draw again - we're still fading
    }
    if(selected == YES || fadeval != 0) {  // only draw this node if we're not completely faded out or selected
        [super setupForDraw];
            [self setTemperature: [self getData: [self name]]];
            if(self->temperature != -1)
                self->temperature /=  100.0;

            glEnable(GL_BLEND);


            float max = [dataSet getScaledMax];

            if (currentMax != max) {
//                NSLog(@"New Max: %.2f %.2f",max,currentMax);
                currentMax = max;
                [colorMap autorelease];
                colorMap = [ColorMap mapWithMax: currentMax];
                [colorMap retain];
            }

            if(selected == YES)
                glColor4f(.1,.1,.1,1);
            else if(temperature == -1) { // No valid data found from the dataSet    
                glColor4f(1,1,1,fadeval);// color the node white
        //        NSLog(@"bad data from %@", [self name]);
            }else
                glColor4f([colorMap r: temperature],[colorMap g: temperature], [colorMap b: temperature], fadeval);
            [super draw];    // draw a box around the node

            if(drawname == YES) {
                glTranslatef(STANDARD_NODE_DEPTH,0,0);
                if(gltName == nil) {
                    gltName = [[GLText alloc] initWithString: [self name] andFont: @"LinLibertine_Re.ttf"];
                    [gltName setScale: .06];
                    [gltName setRotationOnX: 0 Y: 0 Z: 180];
                    [gltName setColorRed: 0 Green: 0 Blue: 0];
                }
                [gltName setString: [[self name] lowercaseString]];
                if(isodd == YES)  // every other node, change name locations
                    glTranslatef(-20,0,-0.5*[self depth]-1);
                else
                    glTranslatef(-30,0,-0.5*[self depth]-1);
                    
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
