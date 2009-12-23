#ifndef NODE_H
#define NODE_H
#import "Locatable.h"
#import "Drawable.h"
#import "Point.h"
#import "../../libcview-data/WebDataSet.h"
/**
    @author Brock Erwin
	@ingroup cview3d
*/
@interface Node : Locatable <Drawable> {
    float temperature;
    int gotit;
}
+(void)setNodeArray:(VertArray*)_nodeArray;
+(void)setDataSet: (DataSet*)_dataSet;
-setTemperature: (float) temperature;
-(float)getTemperature;
@end
#endif // NODE_H
