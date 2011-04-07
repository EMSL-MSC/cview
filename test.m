/*
 *
 */
#import <Foundation/Foundation.h>
#include <stdio.h>


int main(int argc, char *argv[], char *env[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *url;
	if(argc == 2)
		url = [NSString stringWithCString: argv[1]];
	else
		url = @"http://xander.emsl.pnl.gov/cluster/emslfs/cpu_user.data";

	NSURL *dataURL = [[NSURL URLWithString: url] retain];
	Class handlerClass = [NSURLHandle URLHandleClassForURL: dataURL];
	NSURLHandle *X = [[handlerClass alloc] initWithURL: dataURL cached: YES];
	NSLog(@"before loadInForeground");
	NSData *Xt = [X loadInForeground];
	FILE* foo = fopen("foo", "w");
	fwrite([Xt bytes], [Xt length], 1, foo);
	fclose(foo);

	return 0;
}
