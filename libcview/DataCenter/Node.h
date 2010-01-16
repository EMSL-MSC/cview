#ifndef NODE_H
#define NODE_H
#import "Locatable.h"
#import "Drawable.h"
#import "Pickable.h"
#import "Point.h"
#import "../../libcview-data/WebDataSet.h"
#import "../GLText.h"
/**
    @author Brock Erwin
	@ingroup cview3d
*/
@interface Node : Locatable <Drawable, Pickable> {
    float temperature;
    BOOL isodd;
    BOOL drawname;
    BOOL fading;
    BOOL unfading;
    BOOL wasfading;
    BOOL selected;
    double fadetime;
    double fadestart;
    double fadeval;
}
+(void)setWebDataSet: (WebDataSet*)_dataSet;
+setGLTName:(GLText*) _gltName;
-draw;
/// called when picking objects in the scene (does not render)
-glPickDraw;
-startFading;   // Used to make this node transparent over time
-startUnFading; // opposite of above
-setTemperature: (float) temperature;
-(float)getTemperature;
-setIsodd: (BOOL)_isodd;
-setSelected:(BOOL)_selected;
@end
#endif // NODE_H
