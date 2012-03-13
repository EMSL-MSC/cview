/*

This file is part of the CVIEW graphics system, which is goverened by the following License

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
#import "DataSet.h"
#import "UpdateThread.h"
#import "PList.h"

#define TICK_LEN 32
enum DownloadStage { IDLE=0,XTICK,YTICK,DATA,DESC,RATE,START,ERR };
/**
Extension of the data class to retrieve the data from a URL, implement the Updatable protocol so that it can be told to reload the data from the source

The initWithPList method will start its own update thread based off the application default updateThreadInterval

This class expects that for a given key there will be the following files rooted at the given URL:
 - <key>.data file with data, which should have the size == x*y*sizeof(float)
 - <key>.yticks file with row ticks, that should have size == y*32
 - xticks file with column ticks that should have size x*32

The tick files are 32 byte zero-byte padded strings and should always have a file size that is a multiple of 32. This example should be 40*32 , or 1280 bytes.
@dot
digraph tickfile {
	rankdir=LR;
	edge [fontsize=10];
	node [ shape=record fontsize=10 ];
	ticks [ label="Tick1|<here> Tick2|...|Tick40" ];
	onetick [label="32 bytes|{T|i|c|k|2|\\x00|\\x00|...|\\x00}"];
	ticks:here->onetick;
}

@enddot
@author Evan Felix
@ingroup cviewdata
*/
@interface WebDataSet: DataSet <PList> {
	NSURL *dataURL,*XticksURL,*YticksURL,*rateURL,*descURL;
	NSURLConnection *webConn;
	NSMutableData *incomingData;
	NSString *dataKey;
	NSMutableData *Xticks;
	NSMutableData *Yticks;
	BOOL allowRescale;
	NSURL *baseURL;
	NSMutableDictionary *indexByString;
	enum DownloadStage stage;
	NSTimer *timer;
}
-initWithUrlBase: (NSURL *)base andKey: (NSString *)key;
/** returns the stored row label from the loaded data */
-(NSString *)rowTick: (int)row;
/** returns the stored column label from the loaded data */
-(NSString *)columnTick: (int)col;
/** return the current Data Key */
-(NSString *)getDataKey;
/** get row of data based on xTick string **/
-(float*)dataRowByString:(NSString*)xTick;
-initializeIndexByStringDictionary;
-(void)fireTimer:(NSTimer*)aTimer;
@end
