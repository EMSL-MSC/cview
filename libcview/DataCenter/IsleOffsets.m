#import "IsleOffsets.h"
#import <Foundation/Foundation.h>
@implementation IsleOffsets
// Created this little function using the data center map....
// I establised a baseline, and then counted how many tiles each
// isle was away from the baseline.  Pretty simple, only problem is
// that it's hardcoded in here.....(maybe we don't care)
+(float)getIsleOffset: (int) isle {
    if(isle < 0) {
        NSLog(@"Someone passed a negetive isle number!!! VERY BAD.");
        return 0;
    }else if(isle == 1) {
        return 2.5;
    }else if(isle == 2) {
        return -0.2;
    }else if(isle == 3) {
        return 1;
    }else if(isle == 4) {
        return 0;
    }else if(isle == 5) {
        return 1;
    }else if(isle == 6) {
        return 3.8;
    }else if(isle <= 13) {
        return 11;
    }else if(isle <= 16) {
        return 10;
    }else{
        NSLog(@"Someone passed an isle greater than 16!!! Uh-oh.");
        return 0;
    }
}
+(void*)getDataCenterFloor() { 
    /* Te
}
@end
