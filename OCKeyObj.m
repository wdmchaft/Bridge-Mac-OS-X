//
//  OCKeyObj.m
//  Bridge
//
//  Created by Philip Regan on 2011/11/26.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OCKeyObj.h"

#import "limits.h"

@implementation OCKeyObj

@synthesize keyTonic;
@synthesize keyType;

#pragma mark -
#pragma mark init
#pragma mark -

- (id)init {
    self = [super init];
    if (self) {
                
        for ( int p = 0 ; p < kOCMIDI_StandardNoteCount ; p++ ) {
            pitches[p] = NO;
        }
        
        keyTonic = kFlagKeyType_C;
        keyType = kFlagKeyMod_Major;
    }
    return self;
}

#pragma mark -
#pragma mark dealloc
#pragma mark -

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Pitch Creation
#pragma mark -

/*
 Takes the key settings to calculate all of the required pitches
 */

- (void)calculatePitches {
	
	// the tonic is the root pitch of the key; all calculations start here.
	
	int tonic = [self getKeyTonicFromSelection:keyTonic];
	
    // clear the old pitches
	
	for ( int p = 0 ; p < kOCMIDI_StandardNoteCount ; p++ ) {
        pitches[p] = NO;
    }
	
	// parse the key type string to get the step values that make the key
	
	NSString *keyTypeStr = [self getKeyTypeFromSelection:keyType];
	// "Type=# # # # # # #"
	NSArray *keyTypeInfo = [keyTypeStr componentsSeparatedByString:@"="];
	// {{"Type"}, {"# # # # # # #"}}
		
    // make the step values from the type's steps
	NSArray *stepValuesStr = [[keyTypeInfo objectAtIndex:1] componentsSeparatedByString:@" "];
	// {"#", "#", "#", "#", "#", "#", "#"}
	
	// convert the strings into int
	// {"#", "#", "#", "#", "#", "#", "#"} => {#, #, #, #, #, #, #}
	int stepValues[OCTAVE_COUNT];
	int stepValuesCount = 0;
	int stepValuesStrCount = [stepValuesStr count];
	
	for ( int i = 0 ; i < stepValuesStrCount ; i++ ) {
		NSString *stepValStr = [stepValuesStr objectAtIndex:i];
		int stepVal = [stepValStr intValue];
		stepValues[i] = stepVal;
		stepValuesCount++;
	}
	
	// step values for the key and the tonic are both in place, so now we can start
	// doing the math for all pitches in key.
	
	// iterate through the step values until we come to the top of the C1 octave

	int stepIndex = 0;
	int lastPitch = tonic;
	
	int pitchesBuffer[128]; // kOCMIDI_StandardNoteCount
	int pitchesBufferCount = 0;
	
	pitchesBuffer[0] = tonic;
	
	// start from the Tonic and go to the top of the C1 octave
	
	do {
		lastPitch = lastPitch + stepValues[stepIndex];
		pitchesBuffer[stepIndex] = lastPitch;
		pitchesBufferCount++;
		stepIndex++;
	} while ( stepIndex < stepValuesCount );
	
	//bring down those pitches that fall outside of the C1 octave
	
	for ( int i = pitchesBufferCount - 1 ; i >= 0 ; i-- ) {
		if ( pitchesBuffer[i] > OCTAVE_COUNT - 1 ) {
			int pitchVal = pitchesBuffer[i];
			pitchVal = pitchVal - OCTAVE_COUNT;
			pitchesBuffer[i] = pitchVal;
		}
	}
	
	// quick insertion sort since we are only sorting a handful of values
	
	for (int i = 0; i < pitchesBufferCount; i++) {
		int j, v = pitchesBuffer[i];
		for (j = i - 1; j >= 0; j--) {
			if (pitchesBuffer[j] <= v) {
				break;
			}
			pitchesBuffer[j + 1] = pitchesBuffer[j];
		}
		pitchesBuffer[j + 1] = v;
	}
	
	// push the C1 octave values to the pitches array
	
	for ( int i = pitchesBufferCount - 1 ; i >= 0 ; i-- ) {
		pitches[pitchesBuffer[i]] = YES;
	}
	
    // calculate the notes for the rest of the octaves
	
	for ( int p = OCTAVE_COUNT ; p < kOCMIDI_StandardNoteCount + OCTAVE_COUNT ; p += OCTAVE_COUNT ) {
		for ( int n = 0 ; n < pitchesBufferCount ; n++ ) {
			int pb = pitchesBuffer[n];
			pb += p;
			if (pb < kOCMIDI_StandardNoteCount) {
				pitches[pb] = YES;
			}
		}
	}
}

/*
 Menu selection management
 */

- (int) getKeyTonicFromSelection:(int)selection {
	
	/*	 
	 Luckily for us, the index matches the actual pitch value in the current design
	*/
	
	return selection;
	
}


/*
 Menu selection management
 */

- (NSString *) getKeyTypeFromSelection:(int)selection {
	
	switch (selection) {
		case 0:
			return kKeyMajor;
			break;
		case 1:
			return kKeyMinor;
			break;
		case 2:
			return kKeyMinorHarmonic;
			break;
		case 3:
			return kKeyMinorMelodic;
			break;
		case 4:
			return kKeyPentatonicMajor;
			break;
		case 5:
			return kKeyPentatonicMinor;
			break;
		default:
			return kKeyMajor;
			break;
	}
}


/*
 * Returns a boolean based on a passed being in the key
 */

- (BOOL)isPitchInKey:(int)pitch {
	return pitches[pitch];
}

@end
