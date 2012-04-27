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
#import "WebDataSet.h"
#import "debug.h"
#import "cview.h"
#import "CViewAllScreenDelegate.h"
#import "LoadClasses.h"
#import <stdio.h>

/** 
	@author Evan Felix <e@pnl.gov>
	@ingroup cviewapp
*/

#define NEWLINE @"\n"

void usage(NSString *msg,int ecode) {
	if (ecode) {
		NSLog(@"%@\n",msg);
	}

	printf("\ncviewall use:\n\
cviewall -url <url> [optional defaults] [-c <file>]\n\
    or\n\
cviewall <PList file>\n\
\n\
    cview all is a program to load up a set of metrics into a cview graphical \n\
    view by showing all metrics from a given URL, or those specified in the defaults\n\
    a cview plist file can be output by pressing '~' to the file cviewall.cview\n\
    this filename can be changed with the -c flag\n\
\n\
    Defaults for cviewall all can be stored using the defaults program, and/or \n\
    on the command line in the form -<defaultname> <defaultval>.\n\
\n\
    Defaults that affect cviewall:\n\
       Name                Type         Default     Description\n\
       gridw               Int          1           How many Grids to lay down in the horizontal direction\n\
       metrics             String Array (all)       What metrics to show.\n\
       dataUpdateInterval  Float        30          How often in seconds to update the data from the given URL\n\
\n\
    in the second form, cviewall <PList file>, the PList file would be something like this:\n\
\n\
    {\n\
        url = \"http://nwperf.emsl.pnl.gov/jobs/6457162/\";\n\
        metrics = (\"cputotals.user\", \"meminfo.used\");\n\
    }\n\
	\n\n");
	exit(ecode);
}

/* Attempt to load arguments from a PList file */
void tryParseFile(const char *cFilePath, NSUserDefaults *args) {
	NSString *err;
	NSString *filePath = [NSString stringWithCString: cFilePath];
	NSURL *url = [NSURL URLWithString: filePath];
	NSMutableData *file = [NSData dataWithContentsOfURL: url];
	if (file == nil) {
		FILE *fp = fopen(cFilePath, "r");
		char byte;
		if(fp == NULL)
			return;
		/** We can't rely on NSData to load our file due to the fact
		   that NSData will seek to the end of the file to determine
		   how big it is.  This is a problem if the file turns out
		   to be a named pipe.
		   */
		file = [[NSMutableData alloc] init];
		while(fread(&byte, 1, 1, fp) > 0)
			[file appendBytes: &byte length: 1];
		fclose(fp);
	}

	NSPropertyListFormat fmt;
	id plist = [NSPropertyListSerialization propertyListFromData: file
				mutabilityOption: NSPropertyListImmutable
				format: &fmt
				errorDescription: &err
				];
	NSLog(@"plist: %@ %@ %d %@",filePath,plist,fmt,err);
	if(plist != nil) {
		id url = [plist objectForKey: @"url"];
		id metrics = [plist objectForKey: @"metrics"];
		[args registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
			url, @"url",
			metrics, @"metrics",
			nil]];
	} else {
		NSLog(@"Could not load the plist!");
	}
}

int main(int argc,char *argv[], char *env[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ENABLEDEBUGALLOC;
	NSString *configfile;
	int w;

	[LoadClasses loadAllClasses];
#ifndef __APPLE__
	//needed for NSLog
	[NSProcessInfo initializeWithArguments: argv count: argc environment: env ];
#endif

	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
	[args registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
			[NSArray arrayWithObjects: @"all",nil],@"metrics",
			@"1",@"gridw",
			@"30.0",@"dataUpdateInterval",
			@"cviewall.cview",@"c",
			nil]];

	// Attempt to load arguments from a PList file
	if(argc == 2)
		tryParseFile(argv[1], args);

	NSLog(@"url=%@",[args stringForKey: @"url"]);
	if ([[args stringForKey: @"url"] compare: @""] ==  NSOrderedSame) {
		usage(@"A Url for downloading a dataset is required",-1);
	}
	NSLog(@"metrics=%@",[args arrayForKey: @"metrics"]);
	w = [args integerForKey: @"gridw"];
	NSLog(@"gridw=%d",w);

	configfile = [args stringForKey: @"c"];

	GLScreen * g = [[GLScreen alloc] initName: @"Cview All" withWidth: 1200 andHeight: 600];
	CViewAllScreenDelegate *cvasd = [[CViewAllScreenDelegate alloc] initWithScreen:g];
	[cvasd setOutputFile: configfile];
	[cvasd setGridWidth: w];
	[g setDelegate: cvasd];

	Scene * scene1 = [[Scene alloc] init];

	NSURL *baseurl = [NSURL URLWithString: [args stringForKey: @"url"]];
	NSString *index = [NSString stringWithContentsOfURL: [NSURL URLWithString: @"index" relativeToURL: baseurl]];
	if (index == nil) 
		usage([NSString stringWithFormat: @"Index file not found at given URL:%@",baseurl],-2);
	[cvasd setURL: baseurl];

	NSScanner *scanner = [NSScanner scannerWithString: index];

	NSString *str;
	NSMutableDictionary *mf = [NSMutableDictionary dictionary];
	NSNumber *n;
	NSArray *arr = [args arrayForKey: @"metrics"];
	
	while ([scanner scanUpToString: NEWLINE intoString: &str] == YES) {
		//NSLog(@"string: %@",str);
		//[indexes addObject: str];
		n = [NSNumber numberWithBool: [arr containsObject: str] || [arr containsObject: @"all"]];
		[mf setObject: n forKey: str];		
	}
	
	[cvasd setMetricFlags: mf];
			//[[toggler objectAtIndex: 0] show];
	GLWorld *world = [[[g addWorld: @"TL" row: 0 col: 0 rowPercent: 50 colPercent:50] 
			setScene: scene1] 
		setEye: [[[Eye alloc] init] setX: 514.0 Y: 2585.0 Z: 1617.0 Hangle:-4.72 Vangle: -2.45]
	];
	[[cvasd setWorld: world] toggleTweakersVisibility];
	NSLog(@"Setup done");

	
	DUMPALLOCLIST(YES);	

	[g run];

	[scene1 autorelease];
	[g autorelease];
	[pool release];

	return 0;
}
