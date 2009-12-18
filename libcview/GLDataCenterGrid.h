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
@interface GLDataCenterGrid: GLGrid <Drawable> {
    DrawableArray *isles;
@private
    VertArray *floorArray;
}
-init;
-drawData;
-draw;
-drawFloor;
-(NSEnumerator*)getEnumerator;
-addIsle: (Isle*) isle;
@end
