#ifndef NODE_H
#define NODE_H
#import "Locatable.h"
#import "Drawable.h"
/**
    @author Brock Erwin
	@ingroup cview3d
*/
@interface Node : Locatable <Drawable> {
    int temperature;
}
-setTemperature: (int) temperature;
-(int)getTemperature;
@end
#endif // NODE_H
