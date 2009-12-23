#ifndef NODE_H
#define NODE_H
#import "Locatable.h"
#import "Drawable.h"
#import "Point.h"
#import "../../libcview-data/WebDataSet.h"
#import "../GLText.h"
/**
    @author Brock Erwin
	@ingroup cview3d
*/
@interface Node : Locatable <Drawable> {
    float temperature;
    GLText *gltName;
    BOOL drawname;
}
+(void)setNodeArray:(VertArray*)_nodeArray;
+(void)setWebDataSet: (WebDataSet*)_dataSet;
-setTemperature: (float) temperature;
-(float)getTemperature;
@end
#endif // NODE_H
