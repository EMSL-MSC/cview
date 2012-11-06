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
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <math.h>
#include <limits.h>
#include "calcdataset.h"

#define VARIABLE 	0
#define CONSTANT 	1
#define	ADD	 	2
#define	SUBTRACT 	3
#define MULTIPLY 	4
#define DIVIDE   	5
#define SHIFTVARIABLE	6
#define DUP 		7
#define SWAP 		8
#define ABS 		9
// IFZ SP2 IF SP0==0 ELSE SP1
#define IFZ 		10
// GT SP2 = 0 IF SP1 > SP2 ELSE 1
#define GT		11

struct operators {
	int num;
	int *operators;
	long int *arguments;
};

/*
 * Takes a string argument containing the RPN commands to be run and
 * produces an array of operators that will be run over each data
 * point in the input data.
 *
 * The language accepted for the RPN commands is:
 * s -> command | commands ':' command
 * command -> variable | operator | constant
 * variable -> '$' integer
 * operator -> '+' | '-' | '*' | '/'
 * constant -> integer
 *
 * Variable is simply a numeric reference to the dataset number from
 * which the current index should gathered.
 */

struct operators *setup_operators(const char *calc) {
	int operator_index;
	int max_oper_len = strlen(calc);
	struct operators *retval;
	char *tmpbuf;
	char *startptr;
	char *endptr;
	int operator;
	int argument;
	char *calc_modifiable;
	if ((retval = (struct operators *)malloc(sizeof(struct operators))) == NULL ) {
		fprintf(stderr, "Failed to allocate operators structure.\n");
		return NULL;
	}
	if ((retval->operators = (int *)malloc(sizeof(int)*max_oper_len)) == NULL ) {
		fprintf(stderr, "Failed to allocate space for operators.\n");
		return NULL;
	}
	if ((retval->arguments = (long int *)malloc(sizeof(long int)*max_oper_len)) == NULL ) {
		fprintf(stderr, "Failed to allocate space for operators.\n");
		return NULL;
	}
	calc_modifiable = strdup(calc);
	operator_index = 0;
	tmpbuf = strtok(calc_modifiable, ":");
	while(tmpbuf != NULL) {
		operator = -1;
		argument = -1;
		switch (tmpbuf[0]) {
			case '&':
#ifdef DEBUG_CALCDATASET
				printf("FUNCTION: %s\n", tmpbuf);
#endif
				if (strcmp(tmpbuf+1, "ABS") == 0) {
					operator = ABS;
				} else if (strcmp(tmpbuf+1, "DUP") == 0) {
					operator = DUP;
				} else if (strcmp(tmpbuf+1, "SWAP") == 0) {
					operator = SWAP;
				} else if (strcmp(tmpbuf+1, "IFZ") == 0) {
					operator = IFZ;
				} else if (strcmp(tmpbuf+1, "GT") == 0) {
					operator = GT;
				} else {
					fprintf(stderr, "ERROR: FUNCTION '%s': Not recognized.\n", tmpbuf+1);
					free(calc_modifiable);
					free(retval->arguments);
					free(retval->operators);
					free(retval);
					return NULL;
				}
				break;
			case '@':
#ifdef DEBUG_CALCDATASET
				printf("SHIFTVARIABLE: %s\n", tmpbuf);
#endif
				operator = SHIFTVARIABLE;
				startptr = tmpbuf + 1;
				endptr = tmpbuf + 1;
				argument = strtol(startptr,&endptr, 10);
				if ((!(*startptr != '\0' && *endptr == '\0')) || (errno == ERANGE && (argument == LONG_MAX || argument == LONG_MIN))) {
					if (!(*startptr != '\0' && *endptr == '\0')) {
						fprintf(stderr, "ERROR: invalid characters in integer for SHIFTVARIABLE: at %s\n", tmpbuf);
					} else {
						fprintf(stderr, "ERROR:  SHIFTVARIABLE: at %s: out of range.\n", tmpbuf);
					}	
					free(calc_modifiable);
					free(retval->arguments);
					free(retval->operators);
					free(retval);
					return NULL;
				}
				break;
			case '$':
#ifdef DEBUG_CALCDATASET
				printf("VARIABLE: %s\n", tmpbuf);
#endif
				operator = VARIABLE;
				startptr = tmpbuf+1;
				endptr = tmpbuf+1;
				argument = strtol(startptr,&endptr,10);
				if ((!(*startptr != '\0' && *endptr == '\0')) || (errno == ERANGE && (argument == LONG_MAX || argument == LONG_MIN))) {
					if (!(*startptr != '\0' && *endptr == '\0')) {
						fprintf(stderr, "ERROR: invalid characters in integer for VARIABLE: at %s\n", tmpbuf);
					} else {
						fprintf(stderr, "ERROR:  VARIABLE: at %s: out of range.\n", tmpbuf);
					}	
					free(calc_modifiable);
					free(retval->arguments);
					free(retval->operators);
					free(retval);
					return NULL;
				}
				break;
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
#ifdef DEBUG_CALCDATASET
				printf("NUMERIC: %s\n", tmpbuf);
#endif
				startptr = tmpbuf;
				endptr = tmpbuf;
				operator = CONSTANT;
				argument = strtol(startptr,&endptr,10);
				if ((!(*startptr != '\0' && *endptr == '\0')) || (errno == ERANGE && (argument == LONG_MAX || argument == LONG_MIN))) {
					if (!(*startptr != '\0' && *endptr == '\0')) {
						fprintf(stderr, "ERROR: invalid characters in integer for CONSTANT: at %s\n", tmpbuf);
					} else {
						fprintf(stderr, "ERROR:  CONSTANT: at %s: out of range.\n", tmpbuf);
					}	
					free(calc_modifiable);
					free(retval->arguments);
					free(retval->operators);
					free(retval);
					return NULL;
				}
				break;
			case '+':
#ifdef DEBUG_CALCDATASET
				printf("ADD\n");
#endif
				operator = ADD;
				break;
			case '-':
#ifdef DEBUG_CALCDATASET
				printf("SUB\n");
#endif
				operator = SUBTRACT;
				break;
			case '*':
#ifdef DEBUG_CALCDATASET
				printf("MULT\n");
#endif
				operator = MULTIPLY;
				break;
			case '/':
#ifdef DEBUG_CALCDATASET
				printf("DIV\n");
#endif
				operator = DIVIDE;
				break;
			default:
				fprintf(stderr, "ERROR: unexpected input in parse at %s\n", tmpbuf);
				free(calc_modifiable);
				free(retval->operators);
				free(retval->arguments);
				free(retval);
				return NULL;
		}
		if (operator_index > max_oper_len) {
			fprintf(stderr, "ERROR: Attempting to add more operators than characters in the original string.\n");
			free(calc_modifiable);
			free(retval->operators);
			free(retval->arguments);
			free(retval);
			return NULL;
		} 
		retval->operators[operator_index] = operator;
		retval->arguments[operator_index] = argument;
		operator_index++;
#ifdef DEBUG_CALCDATASET
		printf("END: %s\n", calc);
#endif
		tmpbuf = strtok((char *)NULL, ":");
	}
	retval->num = operator_index;
	free(calc_modifiable);
	return retval;
}

void free_opers(struct operators *opers) {
	free(opers->operators);
	free(opers->arguments);
	free(opers);
}

/*
 * Take an input formula, parse it, apply the formula to
 * each point in the input datasets store the value in the
 * output dataset.
 * 
 * Requires that each formula operate on a single point in
 * the datasets. That is each formula must use only the point
 * at a single coordinate in all datasets and must leave no
 * items for future calculation.
 *
 */

int calc_data_set(const char *calc, const long col_count, const long row_count, float *output, const long datacount, float const * datas[]) {
	struct operators *operators;
	int i,j;
	float *stack;
	float tmpval;
	int stack_pointer = 0;
	int retval = 0;
	operators = setup_operators(calc);
#ifdef DEBUG_CALCDATASET
	printf("Finished setting up operators.\n");
#endif
	if (operators == NULL) {
		fprintf(stderr, "Failed to set up operators.\n");
		return 1;
	}
	if ((stack = (float *)malloc(operators->num * sizeof(float *)))==NULL) {
		fprintf(stderr, "Failed to set up stack.\n");
		return 1;
	}
	memset(stack, '\0', operators->num * sizeof(void *));
#ifdef DEBUG_CALCDATASET
	printf("We have %ld datasets.\n", datacount);
#endif
	for (i=0;i<col_count*row_count;i++) {
		for (j = 0; j < operators->num; j++) {
#ifdef DEBUG_CALCDATASET
			printf("Working on operator %d for index %d stack_pointer %d\n", operators->operators[j], i, stack_pointer);
#endif
			switch (operators->operators[j]) {
				case SHIFTVARIABLE:
					if (operators->arguments[j] != -1 && operators->arguments[j] > datacount - 1) {
						fprintf(stderr, "ERROR: datataset %ld does not exist.\n", operators->arguments[j]);
					}
					if ( i % col_count == 0 ) {
#ifdef DEBUG_CALCDATASET
						fprintf(stderr, "WARNING: Faking number for row -1 using %.2f.\n", datas[operators->arguments[j]][i]);
#endif
						stack[stack_pointer] = datas[operators->arguments[j]][i];
					} else {
#ifdef DEBUG_CALCDATASET
						printf("Putting variable %.4f on the stack at %d from dataset %ld:%d\n", datas[operators->arguments[j]][i-1], stack_pointer, operators->arguments[j], i-1);
#endif
						stack[stack_pointer] = datas[operators->arguments[j]][i-1];
					}
					stack_pointer++;
					break;
				case VARIABLE:
					if ( operators->arguments[j] != -1 && operators->arguments[j] > datacount-1 ) {
						fprintf(stderr, "ERROR: dataset %ld does not exist.\n", operators->arguments[j]);
						return 1;
					}
#ifdef DEBUG_CALCDATASET
					printf("Putting variable %.4f on the stack at %d from dataset %ld:%d\n", datas[operators->arguments[j]][i], stack_pointer, operators->arguments[j], i);
#endif
					stack[stack_pointer] = datas[operators->arguments[j]][i];
					stack_pointer++;
					break;
				case CONSTANT:
#ifdef DEBUG_CALCDATASET
					printf("Putting constant %.2f on the stack at %d\n", (float)operators->arguments[j],stack_pointer);
#endif
					stack[stack_pointer++] = (float)operators->arguments[j];
					break;	
				case ADD:
					if (stack_pointer >= 2) {
#ifdef DEBUG_CALCDATASET
						printf("Storing %.2f + %.2f at stack_pointer %d\n", stack[stack_pointer-2],stack[stack_pointer-1], stack_pointer-2);
#endif
						stack[stack_pointer-2] = stack[stack_pointer-2] + stack[stack_pointer-1];
						stack_pointer--;
					} else {
						fprintf(stderr, "ERROR: ADD called with less than 2 items on the stack.\n");
						retval = 2;
						goto cleanup;
					}
					break;
				case SUBTRACT:
					if (stack_pointer >= 2) {
#ifdef DEBUG_CALCDATASET
						printf("Storing %.2f - %.2f at stack_pointer %d\n", stack[stack_pointer-2],stack[stack_pointer-1], stack_pointer-2);
#endif
						stack[stack_pointer-2] = stack[stack_pointer-2] - stack[stack_pointer-1];
						stack_pointer--;
					} else {
						fprintf(stderr, "ERROR: SUBTRACT called with less than 2 items on the stack.\n");
						retval = 2;
						goto cleanup;
					}
					break;
				case MULTIPLY:
					if (stack_pointer >= 2) {
#ifdef DEBUG_CALCDATASET
						printf("Storing %.2f * %.2f at stack_pointer %d\n", stack[stack_pointer-2],stack[stack_pointer-1], stack_pointer-2);
#endif
						stack[stack_pointer-2] = stack[stack_pointer-2] * stack[stack_pointer-1];
						stack_pointer--;
					} else {
						fprintf(stderr, "ERROR: MULTIPLY called with less than 2 items on the stack.\n");
						retval = 2;
						goto cleanup;
					}
					break;
				case DIVIDE:
					if (stack_pointer >= 2) {
#ifdef DEBUG_CALCDATASET
						printf("Storing %.2f / %.2f at stack_pointer %d\n", stack[stack_pointer-2],stack[stack_pointer-1], stack_pointer-2);
#endif
						if (stack[stack_pointer-1] != 0) {
							stack[stack_pointer-2] = stack[stack_pointer-2] / stack[stack_pointer-1];
						} else {
#ifdef DEBUG_CALCDATASET
							printf("Cowardly refusing to divide by zero!\n");
#endif
							stack[stack_pointer-2] = 0;
						}
					} else {
						fprintf(stderr, "ERROR: DIVIDE called with less than 2 items on the stack.\n");
						retval = 2;
						goto cleanup;
					}
					stack_pointer--;
					break;
				case ABS:
					if ( stack_pointer >= 1 ) {
#ifdef DEBUG_CALCDATASET
						printf("Storing %.2f at stack_pointer %d\n", fabs(stack[stack_pointer-1]), stack_pointer-1);
#endif
						stack[stack_pointer-1] = fabs(stack[stack_pointer-1]);
					} else {
						fprintf(stderr, "ERROR: ABS called with no items on the stack.\n");
						retval = 2;
						goto cleanup;
					}
					break;
				case DUP:
					if ( stack_pointer >= 1 ) {
#ifdef DEBUG_CALCDATASET
						printf("Storing %.2f at stack_pointer %d\n", stack[stack_pointer-1], stack_pointer);
#endif
						stack[stack_pointer] = stack[stack_pointer-1];
						stack_pointer++;
					} else {
						fprintf(stderr, "ERROR: DUP Called with no items on the stack.\n");
						retval = 2;
						goto cleanup;
					}
					break;
				case SWAP:
					if ( stack_pointer >= 2 ) {
#ifdef DEBUG_CALCDATASET
						printf("Storing %.2f at stack_pointer %d and %.2f at stack_pointer %d\n", stack[stack_pointer-2], stack_pointer-1, stack[stack_pointer-1],stack_pointer-2);
#endif
						tmpval = stack[stack_pointer-2];
						stack[stack_pointer-2] = stack[stack_pointer-1];
						stack[stack_pointer-1] = tmpval;
					} else {
						fprintf(stderr, "ERROR: SWAP Called with less than 2 items on the stack.\n");
						retval = 2;
						goto cleanup;
					}
					break;
				case IFZ:
					if ( stack_pointer >= 3 ) {
						// IFZ SP3 IF SP1==0 ELSE SP2
						if ( stack[stack_pointer-1] == 0 ) {
#ifdef DEBUG_CALCDATASET
							printf("Storing %.2f at from stack_pointer %d at stack_pointer %d\n", stack[stack_pointer-3], stack_pointer-3, stack_pointer-3);
#endif
							//stack[stack_pointer-3] = stack[stack_pointer-3];
						} else {
#ifdef DEBUG_CALCDATASET
							printf("Storing %.2f at from stack_pointer %d at stack_pointer %d\n", stack[stack_pointer-2], stack_pointer-2, stack_pointer-3);
#endif
							stack[stack_pointer-3] = stack[stack_pointer-2];
						}
						stack_pointer -= 2;	
					} else {
						fprintf(stderr, "ERROR: IFZ Called with less than 3 items on the stack.\n");
						retval = 2;
						goto cleanup;
					}
					break;
				case GT:
					if (stack_pointer >= 2) {
						// GT SP2 = 0 IF SP1 > SP2 ELSE 1
						if ( stack[stack_pointer-1] > stack[stack_pointer-2] ) {
#ifdef DEBUG_CALCDATASET
							printf("Storing 0 at stack_pointer %d\n", stack_pointer-2);
#endif
							stack[stack_pointer-2] = 0;
						} else {
#ifdef DEBUG_CALCDATASET
							printf("Storing 1 at stack_pointer %d\n", stack_pointer-2);
#endif
							stack[stack_pointer-2] = 1;
						}
						stack_pointer--;
					} else {
						fprintf(stderr, "ERROR: GT Called with less than 2 items on the stack.\n");
						retval = 2;
						goto cleanup;
					}
					break;
				default:
					break;
			}
		}
		if (stack_pointer != 1) {
			fprintf(stderr, "ERROR: Unused items left on the stack.\n");
			return 1;
		}
		output[i] = stack[0];
		stack_pointer = 0;
	}
cleanup:
	free(stack);
	free_opers(operators);
	return retval;
}


