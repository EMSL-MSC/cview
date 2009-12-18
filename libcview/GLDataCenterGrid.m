#import <Foundation/Foundation.h>
#import <gl.h>
#import <glut.h>
#import "cview.h"
#import "DataSet.h"
#import "GLDataCenterGrid.h"

extern GLuint g_textureID;
@implementation  GLDataCenterGrid
// TODO: update this draw function
-init {
    [super init];
    self->isles = [[DrawableArray alloc] init];
    return self;
}
/*
-drawData {
	int i,j;
	float *dl;
	float *verts;
	verts = [dataRow mutableBytes];

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glPushMatrix();	
	glScalef(xscale,yscale,zscale);

	glVertexPointer(3, GL_FLOAT, 0, verts);
	glColorPointer(3, GL_FLOAT, 0, [colorRow mutableBytes]);

	for (i=0;i<[dataSet width];i++) {
		dl=[dataSet dataRow: i];


		[colorMap doMapWithData: dl thatHasLength: [dataSet height] toColors: [colorRow mutableBytes]];
		//is there a gooder way? FIXME
		for (j=0;j<[dataSet height];j++) {
			verts[j*3+1] = dl[j];
			verts[j*3+0] = (float)i;
		}	
		glDrawArrays(GL_POINTS,0,[dataSet height]);
	}

	glPopMatrix();
	return self;
}*/
-drawOriginAxis {
    glPushMatrix();
    //glLoadIdentity();
    glBegin(GL_LINES);
    //glLineWidth(5.0); // this generates a GL_INVALID_OPERATION, comment out
    glColor3f(1.0,0,0);
    glVertex3f(-10000,0,0);
    glVertex3f(10000,0,0);
    glVertex3f(0,-100000,0);
    glVertex3f(0,10000,0);
    glVertex3f(0,0,-10000);
    glVertex3f(0,0,10000);
    
    glEnd();
    glPopMatrix();
    return self;
}
-addIsle: (Isle*) isle {
    //NSLog(@"In addIsle:");
    // Add the passed rack to our rackArray
    self->isles = [self->isles addDrawableObject: isle];
    return self;
}

typedef struct
{
    float tu, tv;
    float x, y, z;
} Vertex;

Vertex g_quadVertices[] =
{
    { 0.0f,0.0f, -1.0f,-1.0f, 0.0f },
    { 1.0f,0.0f,  1.0f,-1.0f, 0.0f },
    { 1.0f,1.0f,  1.0f, 1.0f, 0.0f },
    { 0.0f,1.0f, -1.0f, 1.0f, 0.0f }
};

//FIXME
extern void loadTexture( void );
 
-draw {
    if(!g_textureID)
        loadTexture();
    //NSLog(@"[GLDataCenterGrid draw]");
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);		// Clear The Screen And The Depth Buffer
	//glLoadIdentity();						// Reset The View

    //drawString3D(100,10,100,GLUT_BITMAP_HELVETICA_12,@"Yo, yo, I am a coool looking string and my name is BROOOOOOOOOOOOOOOOOOOOOCK", 0);

//    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

    glEnable(GL_TEXTURE_2D);
    glBindTexture( GL_TEXTURE_2D, g_textureID );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
 	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    //glInterleavedArrays( GL_T2F_V3F, 0, g_quadVertices );
    //glDrawArrays( GL_QUADS, 0, 4 );
/*
    glBegin(GL_QUADS);    glColor3f(1.0,1.0,1.0);    glTexCoord2f(0.0,0.0);    glVertex3f(0, 0, 0);   
    //glColor3f(0,1,0);    glTexCoord2f(0.0,1.0);    glVertex3f(500, 0, 0);    //glColor3f(0,0,1);
    glTexCoord2f(1.0,1.0);    glVertex3f(500, 0, 1000);    //glColor3f(.5,.5,.2);    glTexCoord2f(1.0,0.0);
    glVertex3f(0, 0, 1000);    glEnd();
*/
    [self drawOriginAxis];
    [self->isles draw];
    GLenum err = glGetError();
    if(err != GL_NO_ERROR) {
        NSLog(@"There was a glError, error number: %d", err);
        printf("error in hex: %x\n", err);
    }

    return self;
}
-drawFloor {
    //TODO: add stuff here to draw floor tiles
    return self;
}
-glDraw {
    float max = [dataSet getScaledMax];
	
	if (currentMax != max) {
		NSLog(@"New Max: %.2f %.2f",max,currentMax);
		currentMax = max;
		[colorMap autorelease];
		colorMap = [ColorMap mapWithMax: currentMax];
		[colorMap retain];
	}

	glScalef(1.0,1.0,1.0); 
	
    [self draw];
    [self drawFloor];
	//[self drawPlane];
	//[self drawData];
	[self drawAxis];
	//[self drawTitles];
    return self;
}
-(NSEnumerator*) getEnumerator {
    NSEnumerator *enumerator = [self->isles getEnumerator];
    return enumerator;
}

@end
