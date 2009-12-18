#import "DataCenterLoader.h"
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSEnumerator.h> 
#import <Foundation/NSArray.h>
#import "DataCenter/IsleOffsets.h"
#include "Wand.h"
#import "DictionaryExtra.h"
#include <gl.h>
#include <glut.h>
#include <stdio.h>
#include <stdlib.h>   
struct BMPImage
{
    int   width;
    int   height;
    char *data;
}; 
typedef struct BMPImage BMPImage;
GLuint g_textureID = 0;
@implementation DataCenterLoader
-init {
    [super init];
    srand( time(NULL) );
    self->dcg = nil;
    return self;
}
/* Image type - contains height, width, and data */
struct anImage {
    unsigned long sizeX;
    unsigned long sizeY;
    char *data;
};
typedef struct anImage anImage;
int myImageLoad(const char *filename, anImage *image) {
    FILE *file;
    unsigned long size;                 // size of the image in bytes.
    unsigned long i;                    // standard counter.
    unsigned short int planes;          // number of planes in image (must be 1) 
    unsigned short int bpp;             // number of bits per pixel (must be 24)
    char temp;                          // temporary color storage for bgr-rgb conversion.
    // make sure the file is there.
    if ((file = fopen(filename, "rb"))==NULL)
    {
    	printf("File Not Found : %s\n",filename);
    	return 0;
    }
    // seek through the bmp header, up to the width/height:
    fseek(file, 18, SEEK_CUR);
    // read the width
    if ((i = fread(&image->sizeX, 4, 1, file)) != 1) {
    	printf("Error reading width from %s.\n", filename);
	    return 0;
    }
    printf("Width of %s: %lu\n", filename, image->sizeX); 
    // read the height 
    if ((i = fread(&image->sizeY, 4, 1, file)) != 1) {
	    printf("Error reading height from %s.\n", filename);
    	return 0;
    }
    printf("Height of %s: %lu\n", filename, image->sizeY);
    // calculate the size (assuming 24 bits or 3 bytes per pixel).
    size = image->sizeX * image->sizeY * 3;
    // read the planes
    if ((fread(&planes, 2, 1, file)) != 1) {
	printf("Error reading planes from %s.\n", filename);
	return 0;
    }
    if (planes != 1) {
	printf("Planes from %s is not 1: %u\n", filename, planes);
	return 0;
    }

    // read the bpp
    if ((i = fread(&bpp, 2, 1, file)) != 1) {
	printf("Error reading bpp from %s.\n", filename);
	return 0;
    }
    if (bpp != 24) {
	printf("Bpp from %s is not 24: %u\n", filename, bpp);
	return 0;
    }
	
    // seek past the rest of the bitmap header.
    fseek(file, 24, SEEK_CUR);

    // read the data. 
    image->data = (char *) malloc(size);
    if (image->data == NULL) {
	printf("Error allocating memory for color-corrected image data");
	return 0;	
    }

    if ((i = fread(image->data, size, 1, file)) != 1) {
	printf("Error reading image data from %s.\n", filename);
	return 0;
    }

    for (i=0;i<size;i+=3) { // reverse all of the colors. (bgr -> rgb)
	temp = image->data[i];
	image->data[i] = image->data[i+2];
	image->data[i+2] = temp;
    }
    
    // we're done.
    return 1;
}
void getBitmapImageData( char *pFileName, BMPImage *pImage )
{
    FILE *pFile = NULL;
    unsigned short nNumPlanes;
    unsigned short nNumBPP;
	int i;

    if( (pFile = fopen(pFileName, "rb") ) == NULL )
		printf("ERROR: getBitmapImageData - %s not found\n",pFileName);

    // Seek forward to width and height info
    fseek( pFile, 18, SEEK_CUR );

    if( (i = fread(&pImage->width, 4, 1, pFile) ) != 1 )
		printf("ERROR: getBitmapImageData - Couldn't read width from %s.\n", pFileName);

    if( (i = fread(&pImage->height, 4, 1, pFile) ) != 1 )
		printf("ERROR: getBitmapImageData - Couldn't read height from %s.\n", pFileName);

    if( (fread(&nNumPlanes, 2, 1, pFile) ) != 1 )
		printf("ERROR: getBitmapImageData - Couldn't read plane count from %s.\n", pFileName);
	
    if( nNumPlanes != 1 )
		printf( "ERROR: getBitmapImageData - Plane count from %s is not 1: %u\n", pFileName, nNumPlanes );
 glTexCoord2f(0.0,0.0);

    if( (i = fread(&nNumBPP, 2, 1, pFile)) != 1 )
		printf( "ERROR: getBitmapImageData - Couldn't read BPP from %s.\n", pFileName );
	
    if( nNumBPP != 24 )
		printf( "ERROR: getBitmapImageData - BPP from %s is not 24: %u\n", pFileName, nNumBPP );

    // Seek forward to image data
    fseek( pFile, 24, SEEK_CUR );

	// Calculate the image's total size in bytes. Note how we multiply the 
	// result of (width * height) by 3. This is becuase a 24 bit color BMP 
	// file will give you 3 bytes per pixel.
    int nTotalImagesize = (pImage->width * pImage->height) * 3;

    pImage->data = (char*) malloc( nTotalImagesize );
	
    if( (i = fread(pImage->data, nTotalImagesize, 1, pFile) ) != 1 )
		printf("ERROR: getBitmapImageData - Couldn't read image data from %s.\n", pFileName);

    //
	// Finally, rearrange BGR to RGB
	//
	
	char charTemp;
    for( i = 0; i < nTotalImagesize; i += 3 )
	{ 
		charTemp = pImage->data[i];
		pImage->data[i] = pImage->data[i+2];
		pImage->data[i+2] = charTemp;
    }
}
void loadTexture( void )	
{
	BMPImage textureImage;
	
    getBitmapImageData( "/home/berwin/cview/data/rack.bmp", &textureImage );
    NSLog(@"textureID = %u", g_textureID);
	glGenTextures( 1, &g_textureID );
	glBindTexture( GL_TEXTURE_2D, g_textureID );

//	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
//	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
 	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
     glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);


	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, textureImage.width, textureImage.height, 
	               0, GL_RGB, GL_UNSIGNED_BYTE, textureImage.data );
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError (init), error number: %d", err);
}


-(unsigned int)loadImage: (NSString *)filename {
    // Load Texture
    anImage *image1;
    
    // allocate space for texture
    image1 = (anImage *) malloc(sizeof(anImage));
    if (image1 == NULL) {
	    printf("Error allocating space for image");
	    exit(0);
    }

    if (!myImageLoad([filename UTF8String], image1)) {
	    exit(1);
    }
    unsigned int texture;
    glGenTextures(1, &texture);
    NSLog(@"texture == %u", texture);
    glBindTexture(GL_TEXTURE_2D, texture);   // 2d texture (x and y size)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); // scale linearly when image bigger than texture
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); // scale linearly when image smalled than texture
    glTexImage2D(GL_TEXTURE_2D, 0, 3, image1->sizeX, image1->sizeY, 0, GL_RGBA, GL_UNSIGNED_BYTE, image1->data);

    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError (init), error number: %d", err);


    return texture;
/*
	MagickWand *wand = NewMagickWand();
	///@todo optionaly pull from a resource instead of the full filename
	MagickBooleanType ssrand( time(NULL) );
    r = (float)rand() / (float)RAND_MAX;
    g = 1.0-r;
    b = 0.0;
tatus = MagickReadImage (wand, [filename UTF8String]);
    NSMutableData *image;
    int tw,th;
	if ( status == MagickFalse )
	{
		NSLog(@"Error reading image: %@",filename);
		image = nil;
        return 0;
	}
	else {
		tw = MagickGetImageWidth( wand );
		th = MagickGetImageHeight( wand );
		image = [[NSMutableData dataWithCapacity: tw*th*4] retain]; //FIXME only deal with RGBA images
		MagickGetImagePixels(wand, 0,0, tw, th, "RGBA", CharPixel, [image mutableBytes]);
	}
	wand = DestroyMagickWand(wand);
    //unsigned int texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tw, th, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, [image mutableBytes]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);	// Linear Filtering
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);	// Linear Filtering

     glShadeModel(GL_SMOOTH);						// Enable Smooth Shading
	glClearColor(0.0f, 0.0f, 0.0f, 0.5f);					// Black Background
	glClearDepth(1.0f);							// Depth Buffer Setup
	glEnable(GL_DEPTH_TEST);						// Enables Depth Testing
	glDepthFunc(GL_LEQUAL);							// The Type Of Depth Testing To Do
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);			// Really Nice Perspective Calculations
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"There was a glError (init), error number: %d", err);

    return texture;*/
}

-(GLDataCenterGrid*) LoadGLDataCenterGrid: (GLDataCenterGrid*) _dcg {
    //  FIXME: This is probably bad, need to fix so that we can
    //  search for this file in case the user runs the program from
    //  a different directory........(we'll fix later)
    //NSLog(@"[DataCenterLoader init]");
    if(_dcg == nil) {
        NSLog(@"LoadGLDataCenterGrid was passed a nil parameter!");
        return nil;
    }
    self->dcg = _dcg;
    [self parseSerialNumbersFile: @"../data/Chinook Serial numbers.csv"];
    /* Load some images for textures */
    // Rack front image
   // [Rack setTexture: [self loadImage: @"../data/rack.bmp"]];
//       loadTexture(); 
    return self->dcg;
}
//  isleName will be like "C1" or "C5"....i know it makes no sense,
//  but this format was already predetermined in the Chinook Serial Numbers file...
//  I believe 'C' is actually short for column...
-(Rack*)findRack: (NSString*) rackName andIsle: isle {
    //NSLog(@"findRack: %@ andIsle: %@", rackName, isle);
    if(isle == nil)
        return nil; // Uh, oh, should never get here!
    // First check to see if we have created a Isle object yet for this isle
    NSEnumerator *enumerator = [isle getEnumerator];
    //NSLog(@"enumerator = %@", enumerator);
    if(enumerator == nil)
        return nil;
    id element;
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"element = %@", element);
        // Compare isle names
        if(NSOrderedSame == [rackName compare: [element getName]]) {
            //NSLog(@"They're the same!!!!");
            return element; // Found it, return it!
        }
    }
    return nil;

}
//  isleName will be like "R1" or "R5" or something like that...
-(Isle*)findIsle: (NSString*) isleName {
    // First check to see if we have created a Isle object yet for this isle
    //NSLog(@"findIsle: %@", isleName);
    NSEnumerator *enumerator = [self->dcg getEnumerator];
    //NSLog(@"enumerator: %@", enumerator);
    if(enumerator == nil)
        return nil;
    id element;
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"element = %@", element);
        //NSLog(@" isleName = %@", isleName);
        //NSLog(@" [element getName] = %@", [element getName]);//isleName);
        // Compare isle names
        if(NSOrderedSame == [isleName compare: [element getName]]) {
           //NSLog(@"Got here!");
           return element; // Found it, return it!
        }
    }
    return nil;
}
-insertNode: (NSString*) node andRack: (NSString*)rack {
    //NSLog(@"[insertNode: %@ andRack: %@]", node, rack);
    NSRange range = [rack rangeOfCharacterFromSet:
        [NSCharacterSet characterSetWithCharactersInString:@"C"] ];
    if(range.location == NSNotFound) {
        NSLog(@"Could not insert \"%@\" into \"%@\"! Ignoring this one.", node, rack);
        return self;
    }
    //NSLog(@"range = %d", range.location);
    NSString *isleComponent = [rack substringToIndex: range.location];
    if(isleComponent == nil)
        NSLog(@"It was nil!");
    range.length = [rack length] - range.location;
    //NSLog(@"length = %d", range.length);
    //NSLog(@"rack length = %d", [rack length]);
    NSString *rackComponent = [rack substringWithRange: range];
    //NSLog(@"isleComponent = \"%@\", rackComponent = \"%@\" node = \"%@\"", isleComponent, rackComponent, node);
    
    Location *l;
    Isle *isleObj;
    Rack *rackObj;
    Node *nodeObj;
    // Find the Isle object if it exists, if not, create it!
    //NSLog(@"Debug.");
    if(!(isleObj = [self findIsle: isleComponent])) {
        //NSLog(@"Creating Isle: %@ because isleObj = %@", isleComponent, isleObj);
        isleObj = [[Isle alloc] init];
        [isleObj setName: [isleComponent retain]];
        [isleComponent substringFromIndex: 1];
        // set the x-location to whatever isle number this is...
        l = [[[[Location alloc] init] setx: [[isleComponent substringFromIndex: 1] intValue]] sety: 0];
        // Check for even row number
        if([[isleComponent substringFromIndex: 1] intValue] % 2 == 0)
            [isleObj setface: 180];   // Face the opposite direction for even isles
        [isleObj setLocation: l];
        [self->dcg addIsle: isleObj];   // Add the object to our GLDataCenter object
    }
    // Find the Rack object if it exists, if not, create it!
    if(!(rackObj = [self findRack: rackComponent andIsle:isleObj])) { 
        //NSLog(@"Creating Rack: %@ because rackObj = %@", rackComponent, rackObj);
        rackObj = [[Rack alloc] init];
        [rackObj setName: [rackComponent retain]];
        l = [[[[Location alloc] init] setx: [[rackComponent substringFromIndex: 1] intValue]-1] sety: 0];
        [rackObj setLocation: l];
        // Set the height and width of EVERY rack
        // TODO: change this to be variable...
        // got rack dimensions from: http://h18000.www1.hp.com/products/quickspecs/12402_div/12402_div.html#Technical%20Specifications
        // dimensions in cm
        //NSLog(@"%f == ", STANDARD_RACK_WIDTH);
        [[[rackObj setHeight: STANDARD_RACK_HEIGHT]
                    setDepth: STANDARD_RACK_DEPTH]
                    setWidth: STANDARD_RACK_WIDTH];
       [isleObj addRack: rackObj]; // Add the rack object to the isle object
    }
    // Well, we shouldn't have to test to see if the node has been created
    // because there should only be one occurance of each node in the Chinook
    // Serial Numbers file........(we think)
    //NSLog(@"Creating Node: %@", node);
    nodeObj = [[Node alloc] init];
    [nodeObj setName: [node retain]];
    [nodeObj setTemperature: 0];
    [rackObj addNode: nodeObj]; // Add the node object to the rack object
    //NSLog(@"Debug.");
    return self;
} // insertNode: andRack
-(NSMutableArray*)parseIt: (NSString*) file {
    NSMutableArray *arr = [NSMutableArray array];
    NSRange range;
    int x = 0;
    range.location = 0;
    int quote = 0;
    while(x < [file length]) {
        while(quote == 1 ||
              ([file characterAtIndex:x] != ',' &&
               [file characterAtIndex:x] != '\n')) {
            if([file characterAtIndex:x] == '"') {
                if(quote == 0)  
                    quote = 1;
                else
                    quote = 0;
            }
            ++x;
        }
        range.length = x - range.location;
        [arr addObject: [file substringWithRange: range]];        
        range.location = x + 1;
        ++x;
    }
    return arr;
}
-parseSerialNumbersFile: (NSString*) filePath {
    // reads file into memory as an NSString
    NSString *fileString = [NSString stringWithContentsOfFile:filePath];
    if(fileString == nil) {
        NSLog(@"Could not open \"%@\"! Please look in [DataCenterLoader parseSerialNumbers]",filePath);
        return self;
    }
    NSArray *arr = [self parseIt: fileString];
    NSEnumerator *enumerator = [arr objectEnumerator];
    id element;
    int x = 0;
    NSString* rack = nil;
    NSString* node = nil;
    NSRange range;  // Used to remove those darn quotes from a csv file
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"element == %@, x == %d", element, x);
        element = [element uppercaseString];
        if([element length] >= 3) {
            range.location = 1;
            range.length = [element length] - 2;
            // This substring crap removes quotes from the beginning and end of the string
            // if there are any...    g
            if([element characterAtIndex: 0] == '"' &&
               [element characterAtIndex: [element length] - 1] == '"')
                element = [element substringWithRange: range]; 
        }
        if(x++ == 0)
            rack = element;
        else if(x == 2) {
            node = element;
        }else if(x == 7) {
            x = 0;
            //NSLog(@"x == 7");
            // Make sure we don't include the "labels" in the csv file
            // in our data set, just throw that crap away!
            //NSLog(@"rack: %@ node: %@", rack, node);
            if(!([rack compare: @"RACK"] == NSOrderedSame &&
                 [node compare: @"DEVICE"] == NSOrderedSame)) {
                    [self insertNode: node andRack: rack];
            }
        }
    }
    return self;
}
@end
