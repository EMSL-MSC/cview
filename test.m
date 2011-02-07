/*
 *
 */
#import <Foundation/Foundation.h>
#import "MYClass.h"

int main(int argc, char *argv[], char *env[]) {

	Class c;
	c = NSClassFromString(@"MYClass");


	if ( c == nil )
		NSLog(@" c was nil ! ");
	else
		NSLog(@" c = %@ ", c);

	return 0;
}
