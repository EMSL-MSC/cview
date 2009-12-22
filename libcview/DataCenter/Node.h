#ifndef NODE_H
#define NODE_H
#import "Locatable.h"
#import "Drawable.h"
#import "../../libcview-data/WebDataSet.h"
/**
    @author Brock Erwin
	@ingroup cview3d
*/
@interface Node : Locatable <Drawable> {
    float temperature;
    DataSet *ds;    // Really bad way to do this...
    int gotit;
}
-setTemperature: (float) temperature;
-(float)getTemperature;
-setDS: (DataSet*)_ds;
@end
#endif // NODE_H
