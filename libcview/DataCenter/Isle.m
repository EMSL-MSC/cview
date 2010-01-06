#import "Isle.h"
#import <Foundation/Foundation.h>
#import <gl.h>
#import <glut.h>
#import <math.h>
#import "IsleOffsets.h"

@implementation Isle
-init {
    [super init];
    self->rackArray = [[DrawableArray alloc] init];
    self->isleArray = NULL;
    self->face = 0;
    
    return self;
}
-(Node*)findNodeObjectByName:(NSString*) _name {
    if(self->rackArray == nil)
        return nil;
    NSEnumerator *enumerator = [self->rackArray getEnumerator];
    if(enumerator == nil)
        return nil;
    id element;
    Node *node;
    while((element = [enumerator nextObject]) != nil) {
        //NSLog(@"ONE ITERATION OF THE ISLE LOOP**********");
        node = [element findNodeObjectByName: _name];
        if(node != nil)
            return node;
    }
    return nil; 
}
-setface: (int) _face {
    self->face = _face;
    return self;
}
-(int)getFace {
    return face;
}
-startFading {
    if(self->rackArray == nil)
        return self;
    NSEnumerator *enumerator = [self->rackArray getEnumerator];
    if(enumerator == nil)
        return self;
    id element;
    while((element = [enumerator nextObject]) != nil)
        [element startFading];
    return self;
}
extern VertArray* createBox(float w, float h, float d);
-draw {
    int scale = 3.5*TILE_WIDTH; // Spacing between isles
    float thenum = -[self getWidth]+STANDARD_RACK_WIDTH;
    thenum -= STANDARD_RACK_WIDTH*[IsleOffsets getIsleOffset: [[self getLocation] getx]];
    int additionalstuff = 0;
    if([[self getLocation] getx] > 6)
        additionalstuff = 20*TILE_WIDTH;
    glPushMatrix();
    // Move this isle one way or the other depending on which way it's facing...
    glTranslatef(thenum,0,scale*([[self getLocation] getx]-1)+0.5*STANDARD_RACK_DEPTH
                    +additionalstuff);
    if(isleArray == NULL)
        isleArray = createBox([self getWidth], [self getHeight], [self getDepth]);

    NSLog(@"width %f, height %f, depth %f", [self getWidth], [self getHeight], [self getDepth]);

// Draw the isle as a box surrounding each rack, consisting of 6 sides
   // glInterleavedArrays(GL_T2F_V3F, 0, isleArray->verts);
   // glDrawArrays(GL_QUADS, 0, isleArray->vertCount);

    //[self->rackArray draw];
    
    glPopMatrix();
    return self;
}
-(NSMutableArray*)pickDrawX: (int)x andY: (int)y {
    if(isleArray == NULL)
        isleArray = createBox([self getWidth], [self getHeight], [self getDepth]);

    int scale = 3.5*TILE_WIDTH; // Spacing between isles
    float thenum = -[self getWidth]+STANDARD_RACK_WIDTH;
    thenum -= STANDARD_RACK_WIDTH*[IsleOffsets getIsleOffset: [[self getLocation] getx]];
    int additionalstuff = 0;
    if([[self getLocation] getx] > 6)
        additionalstuff = 20*TILE_WIDTH;
    glPushMatrix();
    // Move this isle one way or the other depending on which way it's facing...
    glTranslatef(thenum,0,scale*([[self getLocation] getx]-1)+0.5*STANDARD_RACK_DEPTH
                    +additionalstuff);
    
    // Draw the isle as a box surrounding each rack, consisting of 6 sides
    glInterleavedArrays(GL_T2F_V3F, 0, isleArray->verts);
    glDrawArrays(GL_QUADS, 0, isleArray->vertCount);
    NSMutableArray *ret = nil; 
    glPopMatrix();
    return ret;
    // right now we're testing so let's just draw the box regular rendering to check if it's what we think.
                /*
    GLuint buff[64] = {0};
 	GLint hits, view[4];
 	int _id;
 	glSelectBuffer(64, buff);
 	glGetIntegerv(GL_VIEWPORT, view);
 	glRenderMode(GL_SELECT);
 	glInitNames();
 	glPushName(0);
 	glMatrixMode(GL_PROJECTION);
 	glPushMatrix();
 		glLoadIdentity();
 
 //			restrict the draw to an area around the cursor
 		gluPickMatrix(x, y, 1.0, 1.0, view);
 		gluPerspective(60, (float)view[2]/(float)view[3], 0.0001, 1000.0);
 
 //			Draw the objects onto the screen
 		glMatrixMode(GL_MODELVIEW);
 		
 			draw only the names in the stack, and fill the array
 	//		Do you remeber? We do pushMatrix in PROJECTION mode
 		glMatrixMode(GL_PROJECTION);
 	glPopMatrix();
 
// 		get number of objects drawed in that area
 //		and return to render mode
 	hits = glRenderMode(GL_RENDER);
 
 	glMatrixMode(GL_MODELVIEW);
    return self;
    */
}
-addRack: (Rack*) rack {
    self->rackArray = [self->rackArray addDrawablePickableObject: rack];
    return self;
}
-(NSEnumerator*) getEnumerator {
    NSEnumerator *enumerator = [self->rackArray getEnumerator];
    return enumerator;
}
-(int)getWidth {
    NSEnumerator *enumerator = [self->rackArray getEnumerator];
    if(enumerator == nil)
        NSLog(@"[Isle getWidth]: enumerator was nil!");
    id element;
    int _width = 0;
    while((element = [enumerator nextObject]) != nil)
        _width += [element getWidth];
    return _width;
}
@end
