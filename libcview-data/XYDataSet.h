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
#import "DataSet.h"
#import "PList.h"

/**
Extension of the data class to retrieve the data from a URL, 

The File Should consist of a delimeter separated set of lines with data in them.

There can be one header line at the top of the file. An optional line of white space can exist between the header and the actual data.

Two of the columns should be X and Y values for the location of the data point. The data column can be any of the other columns, selected by either the column number(0 based), or a header key.  Initializers for X,Y, and column select line

If no headerline is found or if the headers for X and Y are not found, X and Y will be taken from columns 0 and 1 respectively.

Column Scans are done case-insensitive

@verbatim
X Y Bandwidth Latency Iter

0 0 3869.08 0.22 0
0 1 2407.43 0.96 1
0 2 2729.94 0.95 2
0 3 2733.35 0.94 3
0 4 2741.82 0.96 4
0 5 2741.40 0.97 5
0 6 2739.89 0.96 6
0 7 2747.43 1.11 7
@endverbatim

@author Evan Felix
@ingroup cviewdata
*/
@interface XYDataSet: DataSet <PList> {
	NSURL *dataURL;
	NSData *rawData;
	long dataStart;
	id theCol,theX,theY;
	int colIndex,xIndex,yIndex;
	NSArray *headers;
	int columnCount;
	BOOL headersRead;
}
-initWithURL: (NSURL *)url columnNum: (int)col columnXNum: (int)x columnYNum: (int)y;
-initWithURL: (NSURL *)url columnName: (NSString *)col columnXName: (NSString *)x columnYName:(NSString*)y;
-initWithURL: (NSURL *)url columnNum: (int)col;
-initWithURL: (NSURL *)url columnName: (NSString *)col;
/**internal function*/
-initWithData;
-(float *)expandDataSetWidth: (int)w andHeight: (int)h;
-(float *)contractDataSetWidth: (int)w andHeight: (int)h;
@end
