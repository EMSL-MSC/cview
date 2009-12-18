#ifndef DATACENTERLOADER_H
#define DATACENTERLOADER_H
#import "GLDataCenterGrid.h"
#import "DataCenter/DrawableArray.h"
#import "DataCenter/Isle.h"
#import "DataCenter/Rack.h"
#import "DataCenter/Node.h"
#import <gl.h>

/**
    @author Brock Erwin
    This class is only an interim one needed due to the fact that
    we have to load two different files in order to initialize
    the data center
  */
@interface DataCenterLoader : NSObject {
// Holds an array of isles in the data center
//    DrawableArray *isles;
    GLDataCenterGrid *dcg;
}
-init;
// Loads a GLDataCenterGrid
-(GLDataCenterGrid*) LoadGLDataCenterGrid: (GLDataCenterGrid*) _dcg;
/** You must pass this message a file that is
    comma separated and the format looks like this:
"Rack","Device","Component Description","Part#","Serial Number","Start Date","Phase"
"R10C1","CU7n115","HP DL185 G5 CTO Chassis","444764-B21","USE815NFJ7",,"2B"
"R10C1","CU7n116","HP DL185 G5 CTO Chassis","444764-B21","USE815NFHQ",,"2B"
"R10C1","CU7n117","HP DL185 G5 CTO Chassis","444764-B21","USE815NB18",,"2B"
......and so on............
This example above was downloaded from the chinook wiki trac site at:
https://cvs.pnl.gov/chinook   (scroll to the bottom of the page)
FYI, only the first two fields really matter (at this point).  The rest I don't use
-Brock
*/
//-insertNode: (NSString*) node: andRack: (NSString*)rack;
-parseSerialNumbersFile: (NSString*) file;
@end
#endif // DATACENTERLOADER_H
