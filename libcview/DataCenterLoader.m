#import "DataCenterLoader.h"
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSEnumerator.h> 
#import <Foundation/NSArray.h>
#import "DataCenter/IsleOffsets.h"
#include "Wand.h"
#import "DictionaryExtra.h"
#include <gl.h>
#include <glut.h>
#include <stdio.h>
#include <stdlib.h>   
@implementation DataCenterLoader
-init {
    [super init];
    srand( time(NULL) );
    self->dcg = nil;
    return self;
}
-(NSMutableArray*)parseIt: (NSString*) file {
    NSMutableArray *arr = [NSMutableArray array];
    NSRange range;
    int x = 0;
    range.location = 0;
    int quote = 0;
    while(x < [file length]) {
        while(quote == 1 ||
              ([file characterAtIndex:x] != ',' &&
               [file characterAtIndex:x] != '\n')) {
            if([file characterAtIndex:x] == '"') {
                if(quote == 0)  
                    quote = 1;
                else
                    quote = 0;
            }
            ++x;
        }
        range.length = x - range.location;
        [arr addObject: [file substringWithRange: range]];        
        range.location = x + 1;
        ++x;
    }
    return arr;
}
//  isleName will be like "C1" or "C5"....i know it makes no sense,
//  but this format was already predetermined in the Chinook Serial Numbers file...
//  I believe 'C' is actually short for column...
-(Rack*)findRack: (NSString*) rackName andIsle: isle {
    //NSLog(@"findRack: %@ andIsle: %@", rackName, isle);
    if(isle == nil)
        return nil; // Uh, oh, should never get here!
    // First check to see if we have created a Isle object yet for this isle
    NSEnumerator *enumerator = [isle getEnumerator];
    //NSLog(@"enumerator = %@", enumerator);
    if(enumerator == nil)
        return nil;
    id element;
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"element = %@", element);
        // Compare isle names
        if(NSOrderedSame == [rackName compare: [element getName]]) {
            //NSLog(@"They're the same!!!!");
            return element; // Found it, return it!
        }
    }
    return nil;
}
//  isleName will be like "R1" or "R5" or something like that...
-(Isle*)findIsle: (NSString*) isleName {
    // First check to see if we have created a Isle object yet for this isle
    //NSLog(@"findIsle: %@", isleName);
    NSEnumerator *enumerator = [self->dcg getEnumerator];
    //NSLog(@"enumerator: %@", enumerator);
    if(enumerator == nil)
        return nil;
    id element;
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"element = %@", element);
        //NSLog(@" isleName = %@", isleName);
        //NSLog(@" [element getName] = %@", [element getName]);//isleName);
        // Compare isle names
        if(NSOrderedSame == [isleName compare: [element getName]]) {
           //NSLog(@"Got here!");
           return element; // Found it, return it!
        }
    }
    return nil;
}
-insertNode: (NSString*) node andRack: (NSString*)rack {
    //NSLog(@"[insertNode: %@ andRack: %@]", node, rack);
    NSRange range = [rack rangeOfCharacterFromSet:
        [NSCharacterSet characterSetWithCharactersInString:@"C"] ];
    if(range.location == NSNotFound) {
        NSLog(@"Could not insert \"%@\" into \"%@\"! Ignoring this one.", node, rack);
        return self;
    }
    //NSLog(@"range = %d", range.location);
    NSString *isleComponent = [rack substringToIndex: range.location];
    if(isleComponent == nil)
        NSLog(@"It was nil!");
    range.length = [rack length] - range.location;
    //NSLog(@"length = %d", range.length);
    //NSLog(@"rack length = %d", [rack length]);
    NSString *rackComponent = [rack substringWithRange: range];
    //NSLog(@"isleComponent = \"%@\", rackComponent = \"%@\" node = \"%@\"", isleComponent, rackComponent, node);
    
    Vector *l;
    Isle *isleObj;
    Rack *rackObj;
    Node *nodeObj;
    // Find the Isle object if it exists, if not, create it!
    if(!(isleObj = [self findIsle: isleComponent])) {
        //NSLog(@"Creating Isle: %@ because isleObj = %@", isleComponent, isleObj);
        isleObj = [[Isle alloc] init];
        [isleObj setName: [isleComponent retain]];
        [isleComponent substringFromIndex: 1];
        ////////////////////////////////////////////////////////////
        // set the x-location to whatever isle number this is...
        ////////////////////////////////////////////////////////
        int scale = 3.5*TILE_WIDTH; // Spacing between isles
        //float thenum = -[self getWidth]+STANDARD_RACK_WIDTH;

        int isle_x = [[isleComponent substringFromIndex: 1] intValue];

        int additionalstuff = 0;
        if(isle_x > 6)
            additionalstuff = 20*TILE_WIDTH;
        //NSLog(@"x: %f", -STANDARD_RACK_WIDTH*[IsleOffsets getIsleOffset: isle_x]);
        l = [[[[[Vector alloc] init]
                        setx: -STANDARD_RACK_WIDTH*[IsleOffsets getIsleOffset: isle_x]]
                        sety: 0]
                        setz: scale*(isle_x-1)+0.5*STANDARD_RACK_DEPTH+additionalstuff];
        [isleObj setLocation: l];
        // Check for even row number
        if([[isleComponent substringFromIndex: 1] intValue] % 2 == 0)
            [isleObj setRotation: [[[[[Vector alloc] init] setx: 0] sety: 180] setz: 0]];  
        [[[isleObj setHeight: STANDARD_RACK_HEIGHT]
                    setDepth: STANDARD_RACK_DEPTH]
                    setWidth: 0]; // zero for now, gets calculated as racks are added
   //     NSLog(@"x: %f", [l x]);
        [self->dcg addIsle: isleObj];   // Add the object to our GLDataCenter object
    }
    // Find the Rack object if it exists, if not, create it!
    if(!(rackObj = [self findRack: rackComponent andIsle:isleObj])) {
        //NSLog(@"Creating Rack: %@ because rackObj = %@", rackComponent, rackObj);
        rackObj = [[Rack alloc] initWithName: [rackComponent retain]];
        int rack_x = [[rackComponent substringFromIndex: 1] intValue]-1;
        [[[rackObj setHeight: STANDARD_RACK_HEIGHT]
                    setDepth: STANDARD_RACK_DEPTH]
                    setWidth: STANDARD_RACK_WIDTH];
        l = [[[[[Vector alloc] init]
                 setx: [rackObj getWidth] * rack_x + .5*STANDARD_RACK_WIDTH]
                 sety: 0]//[rackObj getHeight]*-0.5+STANDARD_NODE_HEIGHT*-0.5]
                 setz: 0];
        [rackObj setLocation: l];
        // Set the height and width of EVERY rack
        // TODO: change this to be variable...
        // got rack dimensions from: http://h18000.www1.hp.com/products/quickspecs/12402_div/12402_div.html#Technical%20Specifications
        // dimensions in cm
        //NSLog(@"%f == ", STANDARD_RACK_WIDTH);

        //[rackObj setFace: [isleObj getFace]];
        //i[rackObj setRotation
        
        [isleObj addRack: rackObj]; // Add the rack object to the isle object
        // Add the width of this rack to the width of the isle
        //NSLog(@"isle width: %f", [isleObj getWidth]);
        //NSLog(@"rack width: %f", [rackObj getWidth]);
        [isleObj setWidth: ([isleObj getWidth] + [rackObj getWidth])];
    }
    // Well, we shouldn't have to test to see if the node has been created
    // because there should only be one occurance of each node in the Chinook
    // Serial Numbers file........(we think)
    //NSLog(@"Creating Node: %@", node);
    nodeObj = [[Node alloc] initWithName: [node retain]];
    [nodeObj setTemperature: 0];
    [[[nodeObj setWidth: STANDARD_NODE_WIDTH]
               setHeight: STANDARD_NODE_HEIGHT]
               setDepth: STANDARD_NODE_DEPTH];
    int y = [rackObj nodeCount];
    if(y > 9)
        ++y;    // Account for the standard gap in most every rack
    if(y % 2 != 0)
        [nodeObj setIsodd: YES];    // make every other node odd...
    l = [[[[[Vector alloc] init]
                 setx: 0]
                 sety: (y+1)*STANDARD_NODE_HEIGHT - .5*STANDARD_RACK_HEIGHT]
                 setz: 0];
    [nodeObj setLocation: l];
    [rackObj addNode: nodeObj]; // Add the node object to the rack object
    //NSLog(@"Debug.");
    return self;
} // insertNode: andRack
-(GLDataCenterGrid*) LoadGLDataCenterGrid: (GLDataCenterGrid*) _dcg {
    //NSLog(@"[DataCenterLoader init]");
    if(_dcg == nil) {
        NSLog(@"LoadGLDataCenterGrid was passed a nil parameter!");
        return nil;
    }
    self->dcg = _dcg;
    // reads file into memory as an NSString
    NSString *fileString = [NSString stringWithContentsOfFile: [self->dcg get_csvFilePath]];
    if(fileString == nil) {
        NSLog(@"Could not open \"%@\"! Please look in [DataCenterLoader LoadGLDataCenterGrid]",[self->dcg get_csvFilePath]);
        return nil;
    }
    NSArray *arr = [self parseIt: fileString];
    NSEnumerator *enumerator = [arr objectEnumerator];
    id element;
    int x = 0;
    NSString* rack = nil;
    NSString* node = nil;
    NSRange range;  // Used to remove those darn quotes from a csv file
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"element == %@, x == %d", element, x);
        element = [element uppercaseString];
        if([element length] >= 3) {
            range.location = 1;
            range.length = [element length] - 2;
            // This substring crap removes quotes from the beginning and end of the string
            // if there are any...    g
            if([element characterAtIndex: 0] == '"' &&
               [element characterAtIndex: [element length] - 1] == '"')
                element = [element substringWithRange: range]; 
        }
        if(x++ == 0)
            rack = element;
        else if(x == 2) {
            node = element;
        }else if(x == 7) {
            x = 0;
            //NSLog(@"x == 7");
            // Make sure we don't include the "labels" in the csv file
            // in our data set, just throw that crap away!
            //NSLog(@"rack: %@ node: %@", rack, node);
            if(!([rack compare: @"RACK"] == NSOrderedSame &&
                 [node compare: @"DEVICE"] == NSOrderedSame)) {
                    [self insertNode: node andRack: rack];
            }
        }
    }
    // Loop throught the isles and make sure they are all aligned
    // i.e. shift them over...
    enumerator = [self->dcg getEnumerator];
    if(enumerator == nil)
        return nil;
    Vector *l;
    Vector *l2;
    NSEnumerator *enumerator2;
    id element2;
    while((element = [enumerator nextObject]) != nil) {
        l = [element location];
        [l setx: [l x] - 0.5*[element getWidth]+STANDARD_RACK_WIDTH];
        enumerator2 = [element getEnumerator];
        while((element2 = [enumerator2 nextObject]) != nil) {
            l2 = [element2 location];
            [l2 setx: [l2 x] - .5*[element getWidth]];
        }
     //   NSLog(@"[l x] == %f",  [element getWidth]);
    }
    
    return self->dcg;
}

@end
