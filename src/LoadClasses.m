/*

This file is port of the CVIEW graphics system, which is goverened by the following License

Copyright © 2008,2009, Battelle Memorial Institute
All rights reserved.

1.  Battelle Memorial Institute (hereinafter Battelle) hereby grants permission
    to any person or entity lawfully obtaining a copy of this software and
    associated documentation files (hereinafter “the Software”) to redistribute
    and use the Software in source and binary forms, with or without
    modification.  Such person or entity may use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and may permit
    others to do so, subject to the following conditions:

    •   Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimers. 
    •   Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
    •   Other than as used herein, neither the name Battelle Memorial
        Institute or Battelle may be used in any form whatsoever without the
        express written consent of Battelle.  
    •   Redistributions of the software in any form, and publications based
        on work performed using the software should include the following
        citation as a reference:

            (A portion of) The research was performed using EMSL, a
            national scientific user facility sponsored by the
            Department of Energy\'s Office of Biological and
            Environmental Research and located at Pacific Northwest
            National Laboratory.

2.  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE OR CONTRIBUTORS BE LIABLE FOR ANY
    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
    THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

3.  The Software was produced by Battelle under Contract No. DE-AC05-76RL01830
    with the Department of Energy.  The U.S. Government is granted for itself
    and others acting on its behalf a nonexclusive, paid-up, irrevocable
    worldwide license in this data to reproduce, prepare derivative works,
    distribute copies to the public, perform publicly and display publicly, and
    to permit others to do so.  The specific term of the license can be
    identified by inquiry made to Battelle or DOE.  Neither the United States
    nor the United States Department of Energy, nor any of their employees,
    makes any warranty, express or implied, or assumes any legal liability or
    responsibility for the accuracy, completeness or usefulness of any data,
    apparatus, product or process disclosed, or represents that its use would
    not infringe privately owned rights.  

*/
#import <Foundation/Foundation.h>
#import "LoadClasses.h"

#import "StreamDataSet.h"
#import "CalculatedDataSet.h"
#import "DataSet.h"
#import "cview-data.h"
#import "debug.h"
#import "WebDataSet.h"
#import "JobDataSet.h"
#import "DictionaryExtra.h"
#import "SinDataSet.h"
#import "calcdataset.h"
#import "ListComp.h"
#import "XYDataSet.h"
#import "PList.h"
#import "config.h"
#import "DataCenterCViewScreenDelegate.h"
#import "LoadClasses.h"
#import "CViewScreenDelegate.h"
#import "ObjectTracker.h"
#import "GLGrid.h"
#import "GLTooltip.h"
#import "cview.h"
#import "ColorMap.h"
#import "Pickable.h"
#import "GLWorld.h"
#import "GLImage.h"
#import "GLText.h"
#import "GLScreen.h"
#import "DrawableObject.h"
#import "GLBar.h"
#import "IdDatabase.h"
#import "DefaultGLScreenDelegate.h"
#import "GLDataCenter.h"
#import "Identifiable.h"
#import "DataCenter/Locatable.h"
#import "DataCenter/Node.h"
#import "DataCenter/Vector.h"
#import "DataCenter/Drawable.h"
#import "DataCenter/Rack.h"
#import "Wand.h"
#import "GLScreenDelegate.h"
#import "Eye.h"
#import "Scene.h"
extern int aninteger;
extern int nsarray_integer;
@implementation LoadClasses
+(void)loadAllClasses {
    /* How to regenerate this class:  run: ./regenerateLoadClasses.sh
     */

/* These two statements do not impact how cview runs.  Rather,
 * they are here to get the linker to pull in some extra functions
 * that otherwise get stripped out on mingw
 */
aninteger++;
nsarray_integer++;

[GLImage class];
[DrawableObject class];
[GLBar class];
[GLText class];
[ColorMap class];
[GLWorld class];
[Eye class];
[GLTooltip class];
[DefaultGLScreenDelegate class];
[GLGrid class];
#if HAVE_GENDERS
[Node class];
#endif
#if HAVE_GENDERS
[Locatable class];
#endif
#if HAVE_GENDERS
[Vector class];
#endif
#if HAVE_GENDERS
[Rack class];
#endif
[Identifiable class];
#if HAVE_GENDERS
[GLDataCenter class];
#endif
[AScreen class];
[GLScreen class];
[IdDatabase class];
[Scene class];
[NSDictionary class];
[NSArray class];
[CalculatedDataSet class];
//[StreamDataSet class];
[UpdateRunLoop class];
[WebDataSet class];
[SinDataSet class];
[JobDataSet class];
[DataSet class];
[XYDataSet class];
}
@end
