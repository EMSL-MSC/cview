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
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "calcdataset.h"

int main(int argc, char *argv[]) {
	float const a[9]={1,2,3,1,2,3,1,2,3};
	float const b[9]={2,3,4,5,6,7,8,9,10};
	float c[9];
	float const neg_a[9]={-1,-2,-3,-1,-2,-3,-1,-2,-3};
	float const neg_b[9]={-2,-3,-4,-5,-6,-7,-8,-9,-10};
	const float *datasets[2]={a,b};
	const float *neg_datasets[2]={neg_a,neg_b};
	int i,testPassed;
	const long rows = 3;
	const long cols = 3;
	
	testPassed = 1;
	if (calc_data_set("$0:$1:+",cols,rows,c,2,datasets) == 0) {
		for (i=0;i<6;i++) {
			if (c[i] != a[i] + b[i]) {
				printf("ADD Test Failed. %.2f != %.2f + %.2f\n", c[i], a[i], b[i]);
				testPassed = 0;
			}
		}
		if (testPassed == 1) {
			printf("ADD Test Passed.\n");
		}
	} else {
		printf("ERROR Encountered while running ADD test.\n");
	}
	testPassed = 1;
	if (calc_data_set("$0:$1:-",cols,rows,c,2,datasets) == 0) {
		for (i=0;i<6;i++) {
			if (c[i] != a[i] - b[i]) {
				printf("SUBTRACT Test Failed. %.2f != %.2f - %.2f\n", c[i], a[i], b[i]);
				testPassed = 0;
			}
		}
		if (testPassed == 1) {
			printf("SUBTRACT Test Passed.\n");
		}
	} else {
		printf("ERROR Encountered while running SUBTRACT test.\n");
	}
	testPassed = 1;
	if (calc_data_set("$0:$1:*",cols,rows,c,2,datasets) == 0) {
		for (i=0;i<6;i++) {
			if (c[i] != a[i] * b[i]) {
				printf("MULTIPLY Test Failed. %.2f != %.2f * %.2f\n", c[i], a[i], b[i]);
				testPassed = 0;
			}
		}
		if (testPassed == 1) {
			printf("MULTIPLY Test Passed.\n");
		}
	} else {
		printf("ERROR Encountered while running MULTIPLY test.");
	}
	testPassed = 1;
	if (calc_data_set("$0:$1:/",cols,rows,c,2,datasets) == 0) {
		for (i=0;i<6;i++) {
			if (c[i] != a[i] / b[i]) {
				printf("DIV Test Failed. %.2f != %.2f / %.2f\n", c[i], a[i], b[i]);
				testPassed = 0;
			}
		}
		if (testPassed == 1) {
			printf("DIV Test Passed.\n");
		}
	} else {
		printf("ERROR Encountered while running DIV test.\n");
	}
	testPassed = 1;
	if (calc_data_set("$0:@0:-",cols,rows,c,2,datasets) == 0) {
		for (i=0;i<6;i++) {
			if (i % 3 == 0) {
				if (c[i] != 0) {
					printf("SHIFTVARIABLE Test Failed. %.2f != %.2f - %.2f\n", c[i], a[i], a[i]);
					testPassed = 0;
				}
			} else {
				if (c[i] != 1) {
					printf("SHIFTVARIABLE Test Failed. %.2f != %.2f - %.2f\n", c[i], a[i], a[i-1]);
					testPassed = 0;
				}
			}
		}
		if (testPassed == 1) {
			printf("SHIFTVARIABLE Test Passed.\n");
		}
	} else {
		printf("ERROR Encountered while running SHIFTVARIABLE test.\n");
	}
	testPassed = 1;
	if (calc_data_set("$0:&ABS",cols,rows,c,2,neg_datasets) == 0) {
		for (i=0;i<6;i++) {
			if (c[i] != fabs(neg_a[i])) {
				printf("ABS Test Failed. %f != fabs(%f)\n", c[i], neg_a[i]);
				testPassed = 0;
			}
		}
		if (testPassed == 1) {
			printf("ABS Test Passed.\n");
		}
	} else {
		printf("ERROR Encountered while running ABS test.\n");
	}
	testPassed = 1;
	if (calc_data_set("1:0:$0:$0:&ABS:+:&IFZ",cols,rows,c,2,neg_datasets) == 0) {
		for (i=0;i<6;i++) {
			if (c[i] != 1) {
				printf("IFZ Test Failed. %f != 1\n", c[i]);
				testPassed = 0;
			}
		}
		if (testPassed == 1) {
			printf("IFZ Test Passed.\n");
		}
	} else {
		printf("ERROR Encountered while running IFZ test.\n");
	}
	testPassed = 1;
	if (calc_data_set("1:0:$0:&DUP:-:&IFZ",cols,rows,c,2,datasets) == 0) {
		for (i=0;i<6;i++) {
			if (c[i] != 1) {
				printf("DUP Test Failed. %f != 1\n", c[i]);
				testPassed = 0;
			}
		}
		if (testPassed == 1) {
			printf("DUP Test Passed.\n");
		}
	} else {
		printf("ERROR Encountered while running the DUP test.\n");
	}
	testPassed = 1;
	if (calc_data_set("1:0:2:1:&SWAP:/:1:2:/:-:&IFZ",cols,rows,c,2,datasets) == 0) {
		for (i=0;i<6;i++) {
			if (c[i] != 1) {
				printf("SWAP Test Failed. %f != 1\n", c[i]);
				testPassed = 0;
			}
		}
		if (testPassed == 1) {
			printf("SWAP Test Passed.\n");
		}
	} else {
		printf("ERROR Encountered while running the SWAP test.\n");
	}
	return 0;
}

