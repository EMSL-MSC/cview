#import "Node.h"
#import <Foundation/NSString.h>
#import <gl.h>
#import "IsleOffsets.h"
#import "../../libcview-data/WebDataSet.h"
@implementation Node
static VertArray *nodeArray;
static WebDataSet *dataSet;
+(void)setNodeArray:(VertArray*)_nodeArray {
    nodeArray = _nodeArray;
}
+(void)setWebDataSet:(WebDataSet*)_dataSet {
    dataSet = [_dataSet retain];
}
-init {
    [super init];
    self->gltName = nil;
    self->drawname = YES;
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
    if(nodeArray == NULL) {
        nodeArray = createBox([self getWidth],[self getHeight],[self getDepth]);
        NSLog(@"width = %f height = %f depth = %f", [self getWidth],[self getHeight],[self getDepth]);
    }
    glPushMatrix();
    glTranslatef(0,STANDARD_NODE_HEIGHT*[[self getLocation] gety],0);
    [self setTemperature: [self getData: [self getName]]];
    if(self->temperature != -1)
        self->temperature /=  100.0;
    // No valid data found from the dataSet    
    if(temperature == -1)
        glColor3f(1,1,1);// color the node white
    else
        glColor3f(temperature, 1-temperature, 0);
    glInterleavedArrays(GL_T2F_V3F, 0, nodeArray->verts);
    glDrawArrays(GL_QUADS, 0, nodeArray->vertCount);    // Draw the node
    glTranslatef(STANDARD_NODE_DEPTH,0,0);
    if(drawname == YES) {
        if(self->gltName == nil) {
            self->gltName = [[GLText alloc] initWithString: [self getName] andFont: @"LinLibertine_Re.ttf"];
            //self->gltName = [[GLText alloc] initWithString: [self getName] andFont: @"LinLibertine_Re.ttf"];
            [self->gltName setScale: .1];
            //[self->gltName setRotationOnX: 90 Y: 180 Z: 0];
        }
        [gltName glDraw];   // Draw the node name
    }
    glPopMatrix();
    return self;
}
-setTemperature: (float) _temperature {
    self->temperature = _temperature;
    return self;
}
-(float)getTemperature {
    return self->temperature;
}
@end
