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
#import "PList.h"

/**
This class provides a basic data store, with associated information.  It is organized as a 2 dimensional array of floating point values.  A set of row and column names is provided, along with some averaging and total functions.  The data may be stored pre-scaled so that it fits within a specific range for display.

@author Evan Felix
@ingroup cviewdata
*/
#define DS_DEFAULT_LIMIT 100.0
//I wish there was magic to stringify into
#define S(x) @ #x
#define DS_DEFAULT_LIMIT_S S(DS_DEFAULT_LIMIT)
#if defined(__APPLE__) || defined(_WIN32)
  #define DS_DEFAULT_LABEL_FORMAT @"%.0f %@"
#else
  #define DS_DEFAULT_LABEL_FORMAT @"%'.0f %@"
#endif
#define DS_DEFAULT_NAME @"NoName"
#define DS_DEFAULT_RATE_SUFFIX @"NoRate"
@interface DataSet: NSObject <PList> {
	NSString *name;
	NSMutableData *data; ///< float based 2d array, data is stored prescaled by the currentScale scale.  so a datapoint of 100.0 and a currentScale of .25 is stored as 25.0
	int width,height;
	int currentLimit; ///< the 'size' of the data in the z direction or how high the data should be...
	NSString *rateSuffix;
	float currentScale;
	float currentMax;
	float lockedMax;
	BOOL allowScaling,dataValid;
	NSString *textDescription;
	NSString *labelFormat;
	NSRecursiveLock *dataLock;
}
- initWithName: (NSString *)n Width: (int)w Height: (int)h;
- initWithWidth: (int)w Height: (int)h;
/** retrieve a specific data row */
- (float *)dataRow: (int)row;
/** get the entire dataset as a float array */
- (float *)data;
- (NSData *)dataObject;
/** move the data up in the data space, throwing away the extra, and zeroing the new space*/
- shiftData: (int)num;
- (int)width;
- (int)height;
- (NSString *)rowTick: (int)row;
- (NSString *)columnTick: (int)col;
/** Return meta information about a column of data. nil otherwise*/
- (NSDictionary *)columnMeta: (int)col;
/** return the maimum value of the data set */ 
- (float)getMax;
/** return the scaled verion of the max, or the true value */
- (float)getScaledMax;
/** recalculate stored maximum values */
- (float)resetMax;
- lockMax: (int)max;
/** create a textual label for the rate given, based off the current scale values */
- (NSString *)getLabel: (float)rate;
/** return the current label format for displaying data */
- (NSString *)getLabelFormat;
/** set a new label format for displaying data this should contain one %f and one %@ for formatting in that order*/
- setLabelFormat: (NSString *)fmt;
- autoScale: (int)limit;
/** Auto scale the data according to the current limit */
- autoScale;
/** replace the data in the dataset with a new one, scaling where necessary */
- autoScaleWithNewData: (NSData *)data;
- disableScaling;
-setDescription: (NSString *)description;
- (NSString *)getDescription;
- setRate:(NSString *)r;
-(NSString *)getRate;
- description;
/** lock the dataset such that the dataset sizes cannot change until unlocked. */
- lock;
/** unlock a previously locked dataset allowing possible size changes */
- unlock;
/** resize data by width */
- setWidth: (int)newWidth;
/** resize data by height */
- setHeight: (int)newHeight;
/** report data valid status */
- (BOOL)dataValid;
@end

