/*
 *
 */
#import <Foundation/Foundation.h>

@interface MYClass : NSObject {
	int an_integer;
}
@end
@implementation MYClass
@end

int main(int argc, char *argv[], char *env[]) {

	Class c;
	c = NSClassFromString(@"MYClass");


	if ( c == nil )
		NSLog(@" c was nil ! ");
	else
		NSLog(@" c = %@ ", c);

	return 0;
}
