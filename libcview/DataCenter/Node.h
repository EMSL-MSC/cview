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
    BOOL drawname;
    BOOL fading;
    BOOL unfading;
    BOOL wasfading;
    float fadetime;
    float fadestart;
    double fadeval;
}
+(void)setNodeArray:(VertArray*)_nodeArray;
+(void)setWebDataSet: (WebDataSet*)_dataSet;
+setGLTName:(GLText*) _gltName;
-startFading;   // Used to make this node transparent over time
-startUnFading; // opposite of above
-setTemperature: (float) temperature;
-(float)getTemperature;
@end
#endif // NODE_H
