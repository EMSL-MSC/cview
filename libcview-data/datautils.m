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
#import "cview-data.h"
#import "config.h"

NSArray *getStringFields(NSString *str) {
	NSString *s;
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity: 10];
	NSScanner *scn = [NSScanner scannerWithString: str];
	while ([scn scanUpToCharactersFromSet: [NSCharacterSet whitespaceCharacterSet] intoString: &s] == YES) {
		[arr addObject: s];
	}
	return arr;
}

int findStringInArray(NSArray *arr,NSString *str) {
	NSString *s;
	int i,col = -1;
	if (arr)
		for (i=0;i<[arr count];i++) {
			s = [arr objectAtIndex: i];
			if ([s compare: str options: NSCaseInsensitiveSearch] == NSOrderedSame) 
				col = i;
		}
	return col;
}


#if defined ON_MINGW_WIN32
#include <windows.h>
#include <stdio.h>
#include <tchar.h>
#include <psapi.h>
NSString *getProcessPath() {
	DWORD ProcessesID = [[NSProcessInfo processInfo] processIdentifier];
	TCHAR szProcessName[2048] = TEXT("<unknown>");
	HANDLE hProcess = OpenProcess( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, ProcessesID);
	if (NULL != hProcess ) {
		GetModuleFileNameEx( hProcess, NULL, szProcessName, sizeof(szProcessName)/sizeof(TCHAR) );
		CloseHandle( hProcess );
		return [NSString stringWithUTF8String: szProcessName];
	} else
		return nil;
}
#endif

/**
 Find a resource, looking in:
 sourcetree
 pkgdatadir
 current directory(should handle passed in full path)
 --added by berwin on 2011-02-23--
 
 */
NSFileHandle *find_resource(NSString *filename) {
	NSString *file = find_resource_path(filename);
	if (file)
		return [NSFileHandle fileHandleForReadingAtPath: file];
	else
		return nil;
}

NSString *find_resource_path(NSString *filename) {
	static BOOL pathdumplog = NO;
	NSFileManager *mgr = [NSFileManager defaultManager];
	NSString *file=nil;
	
	NSString *exeDir = nil, *exeDataDir = nil;
#if defined ON_MINGW_WIN32
	NSString *p,*fullPath = getProcessPath();
	NSLog(@"EXECUTABLE PATH  = %@", fullPath);
	if (fullPath != nil) {
		p = [fullPath stringByDeletingLastPathComponent];
		exeDir =     [NSString stringWithFormat: @"%@", p];
		p = [p stringByDeletingLastPathComponent];
		exeDataDir = [NSString stringWithFormat: @"%@\\share\\cview\\", p];
	}
#endif

#if __APPLE__
    exeDir = @"../../data/";
#endif
    
	NSMutableArray *paths = [NSMutableArray arrayWithObjects: @"",PKG_DATA_DIR@"/",@"../data/",@"./data/",
							 exeDir,exeDataDir,nil];
#if CVIEW_TEST_BUILD
	[paths addObject: @"../tests/"];
	[paths addObject: @"./tests/"];
    [paths addObject: @"../../tests/"];
#endif
	
	if (! pathdumplog) {
		NSLog(@"Resource Search Path=%@",paths);
		pathdumplog=YES;
	}
	
	NSEnumerator *e = [paths objectEnumerator];
	id o;
	NSString *path;
	
	while ((o = [e nextObject])) {
		path = [NSString stringWithFormat: @"%@%@",(NSString *)o,filename];
		//NSLog(@"Checking Path: %@",path);
		if ( [mgr isReadableFileAtPath: path] ) {
			file = path;
		}
	}
	return file;
}
