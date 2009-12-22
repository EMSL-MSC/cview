#import "Node.h"
#import <Foundation/NSString.h>
#import <gl.h>
#import "IsleOffsets.h"
#import "../../libcview-data/WebDataSet.h"
int anum;
@implementation Node
-init {
    self->gotit = 0;
    [super init];
    return self;
 }
-(void)dealloc {
    if(self->ds != nil)
        [ds release];
    return [super dealloc];
}
-(float)getData: (NSString*)nodeName {
    // First find the nodename in the xticks array
    //DataSet *ds = [myDCG getDataSet];
    if([ds isKindOfClass:[WebDataSet class]]) {
        int i;
        for(i=0;i < [ds width];++i){
            if([nodeName compare: [[ds columnTick: i] uppercaseString]] == NSOrderedSame) {
                //NSLog(@"FOUND IT: nodeName = <%@> ds columnTick = <%@> at place %d", nodeName, [[ds columnTick: i] uppercaseString]);
                return [ds dataRow: i][0];  
            }
        }
        //NSLog(@"NOTHING FOUND!!!! nodeName = <%@> ds columnTick = <%@> at place %d", nodeName, [[ds columnTick: i] uppercaseString]);
        return -1;
    }else
        NSLog(@"NOT OF TYPE WebDataSet!!!!");
    
    return 0;
}
-draw {
    //printf("%s\n", [[self getName] UTF8String]);
    glPushMatrix();
    glTranslatef(0,-STANDARD_NODE_HEIGHT*[[self getLocation] gety],0);
    glBegin(GL_QUADS);
    if(anum == 0){
        glColor3f(1,1,1);
        anum = 1;
    }else{
        glColor3f(1,0,0);
        anum = 0;
    }
    if(gotit == 0) {
        [self setTemperature: [self getData: [self getName]] / 100.0];
        gotit = 1;
    }
        
    //if( myTemp != 0 );    
//    printf(@"myTemp = %f", temperature);
    if(temperature == -1)
        glColor3f(1,1,1);
    else
        glColor3f(temperature, 1-temperature, 0);
    glVertex3f( 0.5*[self getWidth],-0.5*[self getHeight],0);
    glVertex3f( 0.5*[self getWidth], 0.5*[self getHeight],0);
    glVertex3f(-0.5*[self getWidth], 0.5*[self getHeight],0);
    glVertex3f(-0.5*[self getWidth],-0.5*[self getHeight],0);
    glEnd();
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
-setDS: (DataSet*)_ds {
    self->ds = [_ds retain];
    return self;
}
@end
