//
//  OCNoteObj.h
//  Bridge
//
//  Created by Philip Regan on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * Core music data object
 */

#import <Cocoa/Cocoa.h>
#import "OCMusicObj.h"

@class OCResizeTabObj;

@interface OCNoteObj : OCMusicObj {
	
    // map to top, left, and width dimensions in graphics
	float startBeat;
	float pitch;
	float length;
	
    // used in moving objects in a group
	float oldStartBeat;
	float oldPitch;
	float oldLength;
    
    /* Resize Management */
    
    OCResizeTabObj *resizeTab;
    
    float lastWidth;
    float lastDelta;

}

#pragma mark -
#pragma mark Properties
#pragma mark -

@property (nonatomic) float startBeat;
@property (nonatomic) float pitch;
@property (nonatomic) float length;

@property (nonatomic) float oldStartBeat;
@property (nonatomic) float oldPitch;
@property (nonatomic) float oldLength;

@property (nonatomic, retain) OCResizeTabObj *resizeTab;

- (void) setOldData;
- (NSRect)dimensions;
- (void) resizeByDeltaX:(float)deltaX snap:(float)snapValue;

@end

