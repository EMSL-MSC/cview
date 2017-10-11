/*

This file is part of the CVIEW graphics system, which is goverened by the following License

Copyright © 2016, Battelle Memorial Institute
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
#import "DataSet.h"
#import "PList.h"
#define GDS_DEFAULT_FROM @"-2h"
#define GDS_DEFAULT_UNTIL @"-1min"
#define GDS_DEFAULT_SORT 0
#define GDS_DEFAULT_SORT_S S(GDS_DEFAULT_SORT)
enum GDownloadStage { G_IDLE=0,G_START,G_DATA,G_ERR };
/**
Extension of the data class to retrieve the data from a graphite metrics server, implements the Updatable protocol so that it can be told to reload the data from the source

The initWithPList method will start its own update thread based off the application default updateThreadInterval

@enddot
@author Evan Felix
@ingroup cviewdata
*/
@interface GraphiteDataSet: DataSet <PList> {
	NSURLConnection *webConn;
	NSMutableData *incomingData;
	NSString *query;
	NSString *from,*until;
	NSArray *Xticks;
	NSURL *graphiteURL;
	NSURL *baseURL;
	int sort;
	long start_time,end_time,step_time;
	enum GDownloadStage stage;
	NSTimer *timer;
}
/** Initialize given the graphite URL, with a name and query */
- initWithUrl: (NSURL *)graphite named: (NSString *)thename andQuery: (NSString *)thequery;
/** Set a new query for this Dataset */
- (void)setQuery: (NSString *)newquery;
/** Returns the current query */
- (NSString *)getQuery;
/** returns the stored row label from the loaded data */
- (NSString *)rowTick: (int)row;
/** returns the stored column label from the loaded data */
- (NSString *)columnTick: (int)col;
- (void)fireTimer:(NSTimer*)aTimer;
- (void)setFrom: (NSString*)_from;
- (NSString *)getFrom;
- (void)setUntil: (NSString*)_until;
- (NSString *)getUntil;
- (void)setBaseURL: (NSURL*)_url;
- (NSURL *)getBaseURL;
- (void)setSort:(int) _sort;
- (int)getSort;
/** internal function */
- (NSDictionary *)processLines: (NSArray *)lines;
@end
