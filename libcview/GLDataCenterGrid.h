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
#import "DataCenter/Isle.h"
#import "DataCenter/Point.h"
#import "IdArray.h"
@interface GLDataCenterGrid: GLGrid <Drawable, Pickable> {
    DrawableArray *isles;
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
-(DrawableArray*)getNodesRunningAJobID:(float) jobid;
/// Makes all nodes fade except for nodes with the passed jobid
-fadeEverythingExceptJobID:(float) jobid;
-doStuff;
-draw;
/**
    @author Brock Erwin
    called when picking objects in the scene (does not render)
    @return An array of objects that were picked
 */
-glPickDraw:(IdArray*)ids;
/**
    @returns objects that correspond to a particular unique id.
    @param pickDrawIds are the ids which which we originally caled glPickDraw with
           this is used so we don't compare hits with objects we didn't even test
    @param glHits contain the unique ids that got hit and were returned from glRenderMode()
 */
-(NSMutableArray*) getPickedObjects: (IdArray*)pickDrawIds hits: (IdArray*)glHits;
/// Draws the floor tiles
-drawFloor;
-(NSEnumerator*)getEnumerator;
-addIsle: (Isle*) isle;
@end
#endif
