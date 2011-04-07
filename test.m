/*
 *
 */
#import <Foundation/Foundation.h>


int main(int argc, char *argv[], char *env[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSURL *dataURL = [[NSURL URLWithString: @"http://www.google.com"] retain];
	Class handlerClass = [NSURLHandle URLHandleClassForURL: dataURL];
	NSURLHandle *X = [[handlerClass alloc] initWithURL: dataURL cached: YES];
	NSData *Xt = [X loadInForeground];
	return 0;
}
