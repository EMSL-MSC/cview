/*
 *
 */
#import <Foundation/Foundation.h>
#import "MYClass.h"

int main(int argc, char *argv[], char *env[]) {

	Class c;
	c = NSClassFromString(@"MYClass");

	Class foo;
	// UNCOMMENT the following line, and you will see the bug dissappear...
	//foo = [MYClass class];

	if ( c == nil )
		NSLog(@" NSClassFromString returned nil -- this is broken ! ");
	else
		NSLog(@" c = %@ ", c);

	return 0;
}
