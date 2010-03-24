#ifndef GLDATACENTER_H
#define GLDATACENTER_H
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

#import "DataSet.h"
#import "ColorMap.h"
#import "DrawableObject.h"
#import "GLText.h"
@interface GLDataCenter: DrawableObject <Drawable, Pickable> {
    NSMutableDictionary *racks;
@private
    WebDataSet *jobIds; // job id data set
    NSMutableData *floor; // Stores floor vertices
    int floorVertCount;
    NSString *gendersFilePath;
    int jobIdIndex;
    DataSet *dataSet;
}
-init;
-doInit;
-initWithGenders;
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
-addRack: (Rack*) Rack;
@end
#endif
