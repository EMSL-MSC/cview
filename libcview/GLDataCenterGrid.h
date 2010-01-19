#ifndef GLDATACENTERGRID_H
#define GLDATACENTERGRID_H
/**
	Draw a 3 dimensional view of the data center showing each rack
    in it's corresponding location

	@author Brock Erwin
	@ingroup cview3d
*/
#import "GLGrid.h"
#import "DataCenter/Drawable.h"
#import "Foundation/NSEnumerator.h"
#import "DataCenter/Aisle.h"
#import "DataCenter/Point.h"
#import "IdArray.h"
@interface GLDataCenterGrid: GLGrid <Drawable, Pickable> {
    NSMutableArray *aisles;
@private
    WebDataSet *jobIds;
    VertArray *floorArray1;
    VertArray *floorArray2;
    VertArray *floorArray3;
    NSString *csvFilePath;
    int jobIdIndex;
}
-(NSString*) get_csvFilePath;
-init;
-doInit;
-(float)getJobIdFromNode:(Node*)n;
-(NSArray*)getNodesRunningAJobID:(float) jobid;
/// Makes all nodes fade except for nodes with the passed jobid
-fadeEverythingExceptJobID:(float) jobid;
-doStuff;
-draw;
/**
    @author Brock Erwin
    called when picking objects in the scene (does not render)
    @return An array of objects that were picked
 */
-glPickDraw;
/// Draws the floor tiles
-drawFloor;
-(NSEnumerator*)getEnumerator;
-addAisle: (Aisle*) aisle;
@end
#endif
