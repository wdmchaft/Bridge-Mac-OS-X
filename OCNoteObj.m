//
//  OCNoteObj.m
//  Bridge
//
//  Created by Philip Regan on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * Core music data object
 */

#import "OCNoteObj.h"
#import "OCResizeTabObj.h"
#import "OCConstants.h"

@implementation OCNoteObj

#pragma mark -
#pragma mark Properties
#pragma mark -

@synthesize startBeat;
@synthesize pitch;
@synthesize length;

@synthesize oldStartBeat;
@synthesize oldPitch;
@synthesize oldLength;

@synthesize resizeTab;

#pragma mark -
#pragma mark Init
#pragma mark -

- (id) init
{
    self = [super init];
    if (self) {
        // add defaults of some kind so we don't get truly bad values
        startBeat = 0.0f;
        pitch = 0.0f;
        length = 0.0f;
        oldStartBeat = 0.0f;
        oldPitch = 0.0f;
        oldLength = 0.0f;
    }
    return self;
}

/*
 Used when moving objects to ensure grouped objects stay at a correct relative
 distance from each other and the pointer
 */

- (void) setOldData {
    oldStartBeat = startBeat;
    oldPitch = pitch;
    oldLength = length;
	lastDelta = 0.0;
}

- (NSRect) dimensions {
    NSRect dim = NSMakeRect(startBeat, pitch, length, 1.0f);
    return dim;
}

- (void) resizeByDeltaX:(float)deltaX snap:(float)snapValue {
    
    // the delta is from the mousedown to mousedrag, which makes this from the original
    // length at the time of mousedown to now
	
    length = floorf( ( oldLength + deltaX ) / snapValue ) * snapValue ;
	
	if ( length < snapValue ) {
		length = snapValue;
	}

}

@end
