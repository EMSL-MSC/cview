#import "Node.h"
#import <Foundation/NSString.h>
#import <gl.h>
#import "IsleOffsets.h"
#import "../../libcview-data/WebDataSet.h"
int anum;
@implementation Node
static VertArray *nodeArray;
static DataSet *dataSet;
+(void)setNodeArray:(VertArray*)_nodeArray {
    nodeArray = _nodeArray;
}
+(void)setDataSet:(DataSet*)_dataSet {
    dataSet = [_dataSet retain];
}
-init {
    self->gotit = 0;
    [super init];
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
    if([dataSet isKindOfClass:[WebDataSet class]]) {
        int i;
        for(i=0;i < [dataSet width];++i){
            if([nodeName compare: [[dataSet columnTick: i] uppercaseString]] == NSOrderedSame) {
                //NSLog(@"FOUND IT: nodeName = <%@> ds columnTick = <%@> at place %d", nodeName, [[ds columnTick: i] uppercaseString]);
                return [dataSet dataRow: i][0];  
            }
        }
        //NSLog(@"NOTHING FOUND!!!! nodeName = <%@> ds columnTick = <%@> at place %d", nodeName, [[ds columnTick: i] uppercaseString]);
        return -1;
    }else
        NSLog(@"NOT OF TYPE WebDataSet!!!!");
    
    return -1;
}
extern VertArray* createBox(float w, float h, float d);
-draw {
    if(nodeArray == NULL) {
        nodeArray = createBox([self getWidth],[self getHeight],[self getDepth]);
        NSLog(@"width = %f height = %f depth = %f", [self getWidth],[self getHeight],[self getDepth]);
    }
    glPushMatrix();
    glTranslatef(0,STANDARD_NODE_HEIGHT*[[self getLocation] gety],0);
    if(anum == 0){
        glColor3f(1,1,1);
        anum = 1;
    }else{
        glColor3f(1,0,0);
        anum = 0;
    }
    if(gotit == 0) {
        [self setTemperature: [self getData: [self getName]]];
        if(self->temperature != -1)
            self->temperature /=  100.0;
        gotit = 1;
    }
    // No valid data found from the dataSet    
    if(temperature == -1)
        glColor3f(1,1,1);// color the node white
    else
        glColor3f(temperature, 1-temperature, 0);
    glInterleavedArrays(GL_T2F_V3F, 0, nodeArray->verts);
    glDrawArrays(GL_QUADS, 0, nodeArray->vertCount);
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
