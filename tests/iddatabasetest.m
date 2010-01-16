#import "cview.h"
#import "IdDatabase.h"

int main(int argc,char *argv[], char *env[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#ifndef __APPLE__
	//needed for NSLog
	[NSProcessInfo initializeWithArguments: argv count: argc environment: env ];
#endif


    NSMutableArray *arr = [[NSMutableArray alloc] init];
    // add some random strings
    [arr addObject: @"joey"];
    [arr addObject: @"brock"];
    [arr addObject: @"evan"];
    [arr addObject: @"stinky"];
    [arr addObject: @"ranson"];
    [arr addObject: @"jay"];

    NSMutableArray *numbers = [[NSMutableArray alloc] init];

    NSEnumerator *enumerator = [arr objectEnumerator];
    id element;
    while((element = [enumerator nextObject]) != nil) {
        // make ids for the string objects
        [numbers addObject: [NSNumber numberWithInt: [IdDatabase reserveUniqueId: element]]];
    }

    enumerator = [numbers objectEnumerator];
    while((element = [enumerator nextObject]) != nil) {
        printf("unique id: %d - string name: %s\n",
            [element intValue],
            [[IdDatabase objectForId: [element intValue]] UTF8String]
            );
    }
    
    printf("removing id 3 (stinky) -- he's too stinky!\n");
NSLog(@"database count: %u", [IdDatabase count]);

    [IdDatabase print];
    [IdDatabase releaseUniqueId: 3];
    [IdDatabase print];


    // print it again
    enumerator = [numbers objectEnumerator];
    while((element = [enumerator nextObject]) != nil) {
        printf("unique id: %d - string name: %s\n",
            [element intValue],
            [[IdDatabase objectForId: [element intValue]] UTF8String]
            );
    }
 
NSLog(@"database count: %u", [IdDatabase count]);

	[pool release];
	return 0;
}

