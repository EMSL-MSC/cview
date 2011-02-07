/*
 *
 */
#import <Foundation/Foundation.h>
#import "MYClass.h"

int main(int argc, char *argv[], char *env[]) {

	Class c;
	c = NSClassFromString(@"MYClass");

	if ( c == nil )
		NSLog(@" NSClassFromString returned nil -- this is broken ! ");
	else
		NSLog(@" c = %@ ", c);

	return 0;
}
