//
//  OCKeyObj.h
//  Bridge
//
//  Created by Philip Regan on 2011/11/26.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 This tracks the key the music piece is being composed in and manages all sthe pitches 
 that are considered in the given key.
 */

#import <Foundation/Foundation.h>

#import "OCConstants.h"
#import "OCMusicLib.h"

@interface OCKeyObj : NSObject {
    
    BOOL pitches[128]; // kOCMIDI_StandardNoteCount, but Xcode won't compile with that variable
	    
    int keyTonic;
    int keyType;
    
}

@property (readwrite) int keyTonic;
@property (readwrite) int keyType;

#pragma mark -
#pragma mark Pitch Creation
#pragma mark -

/*
 * Calculate all of the pitches in a given key
 */

- (void)calculatePitches;

/*
 * translates the index of the selection in the pulldown menu into a pitch value
 */

- (int) getKeyTonicFromSelection:(int)selection;

/*
 * translates the index of the selection in the pulldown menu into a string that
 * contains the step sequence of the key
 */

- (NSString *) getKeyTypeFromSelection:(int)selection;

/*
 * Desginated accessor to the pitches within the key
 */
- (BOOL)isPitchInKey:(int)pitch;


@end
