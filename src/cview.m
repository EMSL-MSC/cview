/*

This file is port of the CVIEW graphics system, which is goverened by the following License

Copyright © 2008,2009, Battelle Memorial Institute
All rights reserved.

1.	Battelle Memorial Institute (hereinafter Battelle) hereby grants permission
	to any person or entity lawfully obtaining a copy of this software and
	associated documentation files (hereinafter “the Software”) to redistribute
	and use the Software in source and binary forms, with or without
	modification.  Such person or entity may use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and may permit
	others to do so, subject to the following conditions:

	•	Redistributions of source code must retain the above copyright
		notice, this list of conditions and the following disclaimers. 
	•	Redistributions in binary form must reproduce the above copyright
		notice, this list of conditions and the following disclaimer in the
		documentation and/or other materials provided with the distribution.
	•	Other than as used herein, neither the name Battelle Memorial
		Institute or Battelle may be used in any form whatsoever without the
		express written consent of Battelle.  
	•	Redistributions of the software in any form, and publications based
		on work performed using the software should include the following
		citation as a reference:

			(A portion of) The research was performed using EMSL, a
			national scientific user facility sponsored by the
			Department of Energy's Office of Biological and
			Environmental Research and located at Pacific Northwest
			National Laboratory.

2.	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE OR CONTRIBUTORS BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
	THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

3.	The Software was produced by Battelle under Contract No. DE-AC05-76RL01830
	with the Department of Energy.  The U.S. Government is granted for itself
	and others acting on its behalf a nonexclusive, paid-up, irrevocable
	worldwide license in this data to reproduce, prepare derivative works,
	distribute copies to the public, perform publicly and display publicly, and
	to permit others to do so.  The specific term of the license can be
	identified by inquiry made to Battelle or DOE.  Neither the United States
	nor the United States Department of Energy, nor any of their employees,
	makes any warranty, express or implied, or assumes any legal liability or
	responsibility for the accuracy, completeness or usefulness of any data,
	apparatus, product or process disclosed, or represents that its use would
	not infringe privately owned rights.  

*/
#import <Foundation/Foundation.h>
#import "LoadClasses.h"
#import "ObjectTracker.h"
#import "Wand.h"
#import "WebDataSet.h"
#import "debug.h"
#import "PList.h"
#import "cview.h"
#import "CViewScreenDelegate.h"
//#define CLS_DUMP NSClassFromString(@"GSCBufferString")

/**@file cview.m
	@ingroup cviewapp
*/
/// Print usage information to stdout 
void usage() {
	printf("\nUsage: cview [OPTIONS] \n\
DESCRIPTION\n\
    cview will display 3d graphs from a given dataset specified in the .cview file\n\
    cview is very flexible and can be configured to display any number of graphs in\n\
    any number of \"screens\" (a window inside a window).\n\
    most of the configuration is stored in the .cview file rather than\n\
    passed on the command line.\n\
\n\
HOTKEYS\n\
    MOVEMENT\n\
       w/a/s/d           Strafe Up/Down/Left/Right\n\
       PageUp/Down       Pitch Up/Down\n\
       Up/Down Arrow     Move Forward/Backward\n\
       Left/Right Arrow  Turn Left/Right\n\
       Left Click-Drag   Strafe In the direction you are moving the mouse\n\
       Right Click-Drag  Tilt the camera angle in the direction you are moving the mouse\n\
       Mouse Wheel-Drag  Move the mouse while holding down the mouse wheel to adjust the zoom\n\
    AUXILARY\n");
#if HAVE_ANTTWEAKBAR
	printf("\
       t  Brings up the AntTweakBar display which allows you to adjust certain things about\n\
          camera angle and position as well as position of scene objects\n");
#endif
	printf("\
       ~  Saves Eye attributes (camera angle and position) as well as the position of scene\n\
          objects to the current *.cview file (this is very useful)\n\
       f  Toggle fullscreen\n\
       p  Print current eye coordinates\n\
       z  Dump Screen to file\n\
       q  Quits\n\
\n\
OPTIONS\n\
    -c FILE.cview\n\
       Start cview with a cview file (usually ends with .cview, but doesn't have to) cview\n\
       cannot be started without this file, and if '-c' is not specified, cview tries to load\n\
       cviews/default.cview.  Your .cview file will specify how many viewports to have in the\n\
       window, what scene objects to load into each viewport, the position of each scene\n\
       object and many other options.  For more information see cviews/help.cview.\n\
    -dataUpdateInterval NUM\n\
       Where NUM is the number of seconds to wait before updating the dataset.  Defaults to\n\
       30.0 seconds if this option is not given.\n\
    -dumpclasses t\n\
       Startup a ObjectTracker thread if t > 0, the number how often in seconds to dump the\n\
       class counts: file is cview.classes.  For debugging cview only.\n\
    -ScreenDelegate DELEGATE\n\
       Start cview with the screen delegate DELEGATE. DELEGATE must be a subclass of\n\
       DefaultScreenDelegate.  The delegate's job is to handle key and mouse presses and\n\
       decide what to do with them. This probably shouldn't be changed by the standard user\n\
       and defaults to ");
#if HAVE_GENDERS
	printf("DataCenterCViewScreenDelegate");
#else
	printf("CViewScreenDelegate");
#endif
	printf(".\n\
    -h\n\
    -help\n\
    -?\n\
       Print this help message and exit.\n\
	\n\n");
	exit(0);
}
int main(int argc,char *argv[], char *env[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ENABLEDEBUGALLOC;
#ifdef CLS_DUMP
	GSDebugAllocationActiveRecordingObjects(CLS_DUMP);
#endif

	float updateInterval;
	int dumpclasses;
	
	NSString *config = nil;
	NSString *err;

	[LoadClasses loadAllClasses];
#ifndef __APPLE__
	//needed for NSLog
	[NSProcessInfo initializeWithArguments: argv count: argc environment: env ];
#endif
	//@try {
		/** @objcdef 
			- dataUpdateInterval - time in seconds that the URL reload code will delay between reads
			- dumpclasses - startup a ObjectTracker thread if >0, the number how often in seconds to dump the class counts: file is cview.classes
			- c The PList formatted config file to load 
		*/
		NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
#if defined ON_MINGW_WIN32
		#include <windows.h>
		if([args stringForKey: @"c"] == nil) {
			if(MessageBox(NULL, "CVIEW Requires a \".cview\" file to run.  After you click OK you will be prompted to select one.  If you would like to know how to make your own .cview files take a look at the README.txt, or you can look at the example .cview files inside of the \"cviews\" folder in the installation directory.", "CVIEW Needs .cview file", MB_OKCANCEL) == IDCANCEL)
				exit(0);
			char szFile[2000];
			OPENFILENAME ofn ;
			// open a file name
			ZeroMemory( &ofn , sizeof( ofn));
			ofn.lStructSize = sizeof ( ofn );
			ofn.hwndOwner = NULL  ;
			ofn.lpstrFile = szFile ;
			ofn.lpstrFile[0] = '\0';
			ofn.nMaxFile = sizeof( szFile );
			ofn.lpstrFilter = ".cview property list files\0*.cview\0All\0*.*\0";
			ofn.nFilterIndex =1;
			ofn.lpstrFileTitle = NULL ;
			ofn.nMaxFileTitle = 0 ;
			ofn.lpstrInitialDir=NULL ;
			ofn.Flags = OFN_PATHMUSTEXIST|OFN_FILEMUSTEXIST;
			if(GetOpenFileName( &ofn ) == 0)
				exit(0);
			config = [NSString stringWithCString: szFile];
			NSLog(@"File Chooser result = %@", config);
		}
#endif
#if HAVE_GENDERS
		[args registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
			@"cviews/default.cview", @"c",
			@"30.0",@"dataUpdateInterval",
			@"0",@"dumpclasses",
			@"DataCenterCViewScreenDelegate",@"ScreenDelegate", // use DataCenter since we have genders
			nil]];
#else
		[args registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
			@"cviews/default.cview", @"c",
			@"30.0",@"dataUpdateInterval",
			@"0",@"dumpclasses",
			@"CViewScreenDelegate",@"ScreenDelegate",
			nil]];
#endif
		// Print usage and exit if user passed -h, -?, or -help
		if([args stringForKey: @"h"] != nil ||
			[args stringForKey: @"?"] != nil ||
			[args stringForKey: @"help"] != nil)
			usage();
		if(config == nil)
			config = [args stringForKey: @"c"];
		updateInterval = [args floatForKey: @"dataUpdateInterval"];
		dumpclasses = [args integerForKey: @"dumpclasses"];

		if (dumpclasses > 0) 
			[[[ObjectTracker alloc] initWithFile: @"cview.classes" andInterval: dumpclasses] retain];

		MagickWandGenesis();

		NSData *file = [NSData dataWithContentsOfFile: config];
		NSPropertyListFormat fmt;
		id plist = [NSPropertyListSerialization propertyListFromData: file 
					mutabilityOption: NSPropertyListImmutable 
					format: &fmt
					errorDescription: &err
					];
		//NSLog(@"plist: %@ %d %@",plist,fmt,err);
		if (plist==nil) {
#if defined ON_MINGW_WIN32
			NSString *error = [NSString stringWithFormat:
				@"Error loading property list file \"%@\".  CVIEW will now exit.",
				config];
			MessageBox(NULL, [error UTF8String], "Error loading PList file", MB_OK);
#endif
			printf("Error loading PList: %s. Exiting\n",[config UTF8String]);
			exit(4);
		}
		Class c;
		/*  The following code has been added to allow the Screen Delegate type to be passed on the command line
		 *  if not specified on the command line, defaults to DataCenterCViewScreenDelegate if the genders library
		 *  is present
		 */
		c = NSClassFromString([args stringForKey: @"ScreenDelegate"]);
		if (c == nil) { // if nil then the class wasn't found
		    NSLog(@"\"%@\" is not a valid class known to cview: Exiting",[args stringForKey: @"ScreenDelegate"]);
		    usage();    // print usage and exit
		// Make sure that the passed screen delegate is properly subclassed
		}else if(![c isSubclassOfClass: [CViewScreenDelegate class]]) {
		    NSLog(@"\"%@\" is not a subclass of DefaultGLScreenDelegate: Exiting",[args stringForKey: @"ScreenDelegate"]);
		    usage();    // print usage and exit
		}
		GLScreen * g = [[GLScreen alloc] initWithPList:plist];
		CViewScreenDelegate *delegate = [[c alloc] initWithScreen: g];
		[delegate setOutputFile: config];
		[g setDelegate: delegate];

		NSLog(@"Setup done");

		plist = [g getPList];
		//NSLog([NSPropertyListSerialization stringFromPropertyList: plist]);

		DUMPALLOCLIST(YES);

		[g run];

		MagickWandTerminus();

		[g autorelease];
//	}
//	@catch (NSException *localException) {
//		NSLog(@"Critical Error: %@", localException);
//		return -1;
//	}

	[pool release];

	return 0;
}
