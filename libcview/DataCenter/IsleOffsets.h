#ifndef ISLEOFFSETS_H
#define ISLEOFFSETS_H
// Probably a bad way to do this, but that's my decision ;-D
// These are in centimeters
#define TILE_WIDTH              24
#define TILE_LENGTH             24
#define STANDARD_RACK_WIDTH     24
#define STANDARD_RACK_DEPTH     39.691
#define STANDARD_RACK_HEIGHT    78.89

#define STANDARD_NODE_WIDTH     20  // just guessing now..
#define STANDARD_NODE_HEIGHT    ((STANDARD_RACK_HEIGHT / 42)-5)

#define WIDE_RACK_WIDTH         1

#import "Point.h"
@interface IsleOffsets {
}
+(float)getIsleOffset: (int) isleNum;
+(VertArray*)getDataCenterFloorPart1;
+(VertArray*)getDataCenterFloorPart2;
+(VertArray*)getDataCenterFloorPart3;
@end
#endif
