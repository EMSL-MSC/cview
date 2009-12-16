#import <Foundation/Foundation.h>
#import "WebDataSet.h"
#import "debug.h"
#import "cview.h"
#import "CViewScreenDelegate.h"

#import "DataCenterLoader.h"

/** 
	@author  Brock Erwin <brock.erwin@pnl.gov>
    @note    reused some code from Evan Felix <e@pnl.gov>
	@ingroup cviewapp
*/


@interface NSMutableArray (Toggler)
-doToggle: (NSNotification *)notification;
@end

@implementation NSMutableArray (Toggler) 
-doToggle: (NSNotification *)notification {
	int index=0;
	//NSLog(@"Toggle: %@",notification);
	if ([[notification name] compare: @"keyPress"]==NSOrderedSame) 
		if ([[[notification userInfo] objectForKey: @"key"] unsignedCharValue] == 't') {
					NSEnumerator *list;
					DrawableObject *obj;
					list = [self objectEnumerator];
					while ( (obj = [list nextObject]) )
						if ([obj visible]) {
							index = [self indexOfObject: obj];
							[obj hide];
						}
					obj = [self objectAtIndex: (index+1)%[self count]];
					//NSLog(@"%@",obj);
					[obj show];
		}
	return self;
}
@end

#define NEWLINE @"\n"

void usage(NSString *msg,int ecode) {
	if (ecode) {
		NSLog(@"%@\n",msg);
	}

	printf("\ncviewall use:\n\
cviewall -url <url> [optional defaults]\n\
\n\
    cview all is a program to load up a set of metrics into a cview graphical \n\
    view by showing all metrics from a given URL, or those specified in the defaults\n\
\n\
    Defaults for cviewall all can be stored using the defaults program, and/or \n\
    on the command line in the form -<defaultname> <defaultval>.\n\
\n\
    Defaults that affect cviewall:\n\
       Name                Type         Default     Description\n\
       gridw               Int          1           How many Grids to lay down in the horizontal direction\n\
       metrics             String Array (all)       What metrics to show.\n\
       dataUpdateInterval  Float        30          How often in seconds to update the data from the given URL\n\
       gridToMultiGrid     Bool         0           Use MultiGrid Objects that can display differently\n\
	\n\n");

    exit(ecode);
}


int main(int argc,char *argv[], char *env[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ENABLEDEBUGALLOC;
    //DataCenterLoader *dcl =  [[DataCenterLoader alloc] init];
    //return 0; // Skip everything else right now, let's debug some stuff


    int w;
	//	NSArray *oclasses = [NSArray arrayWithObjects: [GLGrid class],[GLGridSurface class],[GLRibbonGrid class],[GLPointGrid class],nil];
	float updateInterval;

	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
#ifndef __APPLE__
	//needed for NSLog
	[NSProcessInfo initializeWithArguments: argv count: argc environment: env ];
#endif
	
	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    /*
	[args registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
			[NSArray arrayWithObjects: @"all",nil],@"metrics",
			@"1",@"gridw",
			@"30.0",@"dataUpdateInterval",
			nil]];
            */
	[args registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
			[NSArray arrayWithObjects: @"cputotals.user",nil],@"metrics",
			@"1",@"gridw",
			@"30.0",@"dataUpdateInterval",
			nil]];


	NSLog(@"url=%@",[args stringForKey: @"url"]);
	if ([[args stringForKey: @"url"] compare: @""] ==  NSOrderedSame) {
		usage(@"A Url for downloading a dataset is required",-1);
	}
	NSLog(@"metrics=%@",[args arrayForKey: @"metrics"]);
	w = [args integerForKey: @"gridw"];
	NSLog(@"gridw=%d",w);
	updateInterval = [args floatForKey: @"dataUpdateInterval"];
	

	GLScreen * g = [[GLScreen alloc] initName: @"Chinook NWperf" withWidth: 1200 andHeight: 600];
	CViewScreenDelegate *cvsd = [[CViewScreenDelegate alloc] initWithScreen:g];
	[g setDelegate: cvsd];

	Scene * scene1 = [[Scene alloc] init];

	NSURL *baseurl = [NSURL URLWithString: [args stringForKey: @"url"]];
	NSString *index = [NSString stringWithContentsOfURL: [NSURL URLWithString: @"index" relativeToURL: baseurl]];
	if (index == nil) 
		usage([NSString stringWithFormat: @"Index file not found at given URL:%@",baseurl],-2);

	NSScanner *scanner = [NSScanner scannerWithString: index];
	NSMutableSet *indexes = [NSMutableSet setWithCapacity: 10];

	NSString *str;
	DrawableObject *o;
	int posy=0,posx=0,x=0;
    /*  Here is where we loop through and add all objects to the scene
     *
     */
	while ([scanner scanUpToString: NEWLINE intoString: &str] == YES) {
		//NSLog(@"string: %@",str);
		[indexes addObject: str];		

		NSArray *arr = [args arrayForKey: @"metrics"];
		if ([arr containsObject: str] || [arr containsObject: @"all"] ) {
		    NSLog(@"string: %@ is going to be included in the project!!!!!",str);
            WebDataSet *d = [[WebDataSet alloc] initWithUrlBase: baseurl andKey: str];
            // A little testing of my own, pretty much just useless code :-D
/*
            int uuu;
            for(uuu=0; uuu<1000; ++uuu) {
                NSLog(@"<bae>xTick(%d) == %@", uuu, [d columnTick: uuu]);
            }
            */
            UpdateThread *t = [[UpdateThread alloc] initWithUpdatable: d];
            if ([str isEqual: @"mem"])
                [d lockMax: 12.0];
            if ([str isEqual: @"flop"])
                [d lockMax: 100.0];
            
            [d autoScale: 100];	
            [t startUpdateThread: updateInterval];
            o=[[[[[GLDataCenterGrid alloc] initWithDataSet: d] setXTicks: 50] setYTicks: 32] show];
            // Call the Load
            o=[[[DataCenterLoader alloc] init] LoadGLDataCenterGrid: o]; 
            o=[[MultiGrid alloc] initWithGrid: (GLGrid *)o];
            NSLog(@"<bae>---%@",o);
            [scene1 addObject: o atX: posx Y: 0 Z: -posy];
            
            x++;
            if (x >= w) {
                x=0;
                posy += [d height]+80;
                posx = 0;
            }
            else {
                posx += [d width]+120;
            }

            [d autorelease];
            /// This would be bad. how to fix... [t autorelease];
            [o autorelease];
		}

	}
		//[[toggler objectAtIndex: 0] show];
		[[[g addWorld: @"TL" row: 0 col: 0 rowPercent: 50 colPercent:50] 
			setScene: scene1] 
		//setEye: [[[Eye alloc] init] setX: 40.0 Y: 2127.0 Z: 3662.0 Hangle:-4.72 Vangle: -2.24]
		setEye: [[[Eye alloc] init] setX: 169.5 Y: 3333.9 Z: 982.6 Hangle:-6.27 Vangle: -3.115]
	];
	NSLog(@"Setup done");
	
	DUMPALLOCLIST(YES);


	//NSString *err;

	//NSDictionary *plist = [g getPList];
	//NSLog([NSPropertyListSerialization stringFromPropertyList: plist]);

	//NSData *nsd = [NSPropertyListSerialization dataFromPropertyList: (NSDictionary *)plist
	//				format: NSPropertyListXMLFormat_v1_0 errorDescription: &err];
	//[nsd writeToFile: @"archive.plist" atomically: YES];
	

	[g run];


	[scene1 autorelease];
	[g autorelease];
	[pool release];

	return 0;
}
