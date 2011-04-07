/*
 *
 */
#import <Foundation/Foundation.h>
#include <stdio.h>


int main(int argc, char *argv[], char *env[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSURL *dataURL = [[NSURL URLWithString: @"http://www.google.com"] retain];
	Class handlerClass = [NSURLHandle URLHandleClassForURL: dataURL];
	NSURLHandle *X = [[handlerClass alloc] initWithURL: dataURL cached: YES];
	NSData *Xt = [X loadInForeground];
	fwrite([Xt bytes], [Xt length], 1, stdout);
	return 0;
}
