#ifndef ISLEOFFSETS_H
#define ISLEOFFSETS_H
// Probably a bad way to do this, but that's my decision ;-D
// These are in centimeters
#define TILE_WIDTH              24
#define TILE_LENGTH             24
#define STANDARD_RACK_WIDTH     24
#define STANDARD_RACK_DEPTH     39.691
#define STANDARD_RACK_HEIGHT    78.89

#define WIDE_RACK_WIDTH         1

@interface IsleOffsets {
}
+(float)getIsleOffset: (int) isleNum;
@end
#endif
