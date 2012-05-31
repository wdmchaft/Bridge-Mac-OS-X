//
//  OCChordObj.m
//  Bridge
//
//  Created by Philip Regan on 2011/11/26.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OCChordObj.h"

#import "MyDocument.h"
#import "OCMusicPieceObj.h"
#import "OCKeyObj.h"
#import "OCNoteObj.h"

@implementation OCChordObj

@synthesize myDocument;

@synthesize chordTypeSelection;
@synthesize chordModifierSelection;
@synthesize chordExtensionSeventhSelection;
@synthesize chordExtensionSeventhModifierSelection;

/*
 Takes the chord settings along with the root note to calculate all of the required
 pitches
 */

- (void)calculatePitches {
    // (this follows the same method as OCKeyObj but there is enough variation to 
	// not share code since more than just ints can be in the steps
	
	// We stick with Cocoa's classes because NSMutableArray is more convenient than
	// immutable C arrays.
	
    // get the core type of chord
    
    NSString *chordTypeStr = [self getChordTypeFromSelection:chordTypeSelection];
    // {"Type=# # #"}
		
	NSArray *chordTypeInfo = [chordTypeStr componentsSeparatedByString:@"="];
	// {{"Type"}, {"# # #"}}
	
	NSArray *stepValuesStr = [[chordTypeInfo objectAtIndex:1] componentsSeparatedByString:@" "];
    // {"#", "#", "#"}
	
	NSMutableArray *stepValues = [NSMutableArray arrayWithArray:stepValuesStr];
		
    // get the modifier
	OCChordModifier cMod = [self getChordModifierFromSelection:chordModifierSelection];
	
	// check step 2 to see if it is altered ('b3' vs '3') and replace accordingly

    if ( cMod == kFlagChordModifier_Suspended ) {
		NSString *stepTwo = [stepValues objectAtIndex:1];
		if ( [stepTwo length] > 1 ) {
			[stepValues replaceObjectAtIndex:1 withObject:kChordModifer_Suspended_Augmented];
		} else {
			[stepValues replaceObjectAtIndex:1 withObject:kChordModifer_Suspended];
		}
	}
	
		
	if ( cMod == kFlagChordModifier_Power ) {
		[stepValues removeObjectAtIndex:1];
	}
	
    
    // get the 7 extension
	
    int extSeven = [self getChordExtensionSeventhSelection:chordExtensionSeventhSelection];
	if ( extSeven == kFlagChordExtension_Seventh ) {
		// add major or minor depending on selection
		int eMod = [self getchordExtensionSeventhModifierSelection:chordExtensionSeventhModifierSelection];
		if ( eMod == kFlagChordExtensionModifier_Major ) {
			[stepValues addObject:kChordExtension_Seventh_Major];
		} else {
			[stepValues addObject:kChordExtension_Seventh_Minor];
		}
	}
		
    // now that we have all of the steps in an array, we iterate through them creating
	// notes as we go
	
	// capture the root
	OCNoteObj *root = [objects objectAtIndex:0];
	
	int stepsCount = [stepValues count];
	
	// we ignore the first step because it is the root and, therefore, immutable.
	for ( int thisStep = 1 ; thisStep < stepsCount ; thisStep++ ) {
		
		// the step value translates into a value of the count of steps up in 
		// pitches that are in key
		int pitchOffset = 0; 
		// the modifier translates into a value we that we add or substract from
		// the offset pitch regardless if the result is in key or not
		int pitchModifier = 0;
		
		// convert the step into char * for us to read and parse
		// At this point it is actually easier to start dealing with C chars than 
		// deal with Cocoa. And that's just crazy.
		
		int stp_len = [[stepValues objectAtIndex:thisStep] length];
		const char *stp = [[stepValues objectAtIndex:thisStep] cStringUsingEncoding:NSUTF8StringEncoding];
		/*
		 Xcode gives a warning: "Initializing 'char *' with an expression of type 
		 'const char *' discards qualifiers", but this is their error not mine. Not
		 sure why this is my problem.
		 */
		
		if ( stp != NULL ) {
			
			char *stp_num_buffer = malloc((sizeof(char) * stp_len) + 1);
			int stp_num_idx = 0;
			
			if ( stp_num_buffer != NULL ) {
				BOOL mod_flag = NO;
				for ( int s = 0 ; stp[s] != '\0' ; s++ ) {
					// check for a modifier and handle accordingly
					if ( s == 0 ) {
						if ( stp[s] == kNoteSharp ) {
							pitchModifier = 1;
							mod_flag = YES;
						} else if ( stp[s] == kNoteFlat ) {
							pitchModifier = -1;
							mod_flag = YES;
						} else {
							stp_num_buffer[s] = stp[s];
						}
					} else {
						// now we're just dealing with numbers, but we have to manage
						// the index otherwise we'll end up with invalid offsets
						if ( mod_flag ) {
							stp_num_buffer[s - 1] = stp[s];
						} else {
							stp_num_buffer[s] = stp[s];
						}
					}
					stp_num_idx++;
				}
				stp_num_buffer[stp_num_idx] = '\0'; // cap off the end
			}
			// get the offset
			pitchOffset = atoi(stp_num_buffer);
			
			// clean up
			free(stp_num_buffer);
		}
		
		// if everything went fine with the parsing, we make a note, else forget it
		// since we don't want odd objects. What should really happen is we throw
		// an error and ditch the chord completely
		
		if ( pitchOffset != 0 && pitchOffset != INT_MIN && pitchOffset != INT_MAX ) {
			
			int newPitch = root.pitch;
			
			// get the nth pitch that is in key from the root
			int inKeyCount = 0;
			
			do {
				newPitch++;
				if ( [myDocument.musicPiece.key isPitchInKey:newPitch] ) {
					inKeyCount++;
				}
			} while ( inKeyCount < ( pitchOffset - 1) );
			
			// apply the modifier
			newPitch += pitchModifier;
			
			// make the note object at the new pitch
			OCNoteObj *note = [myDocument createNoteAtStartBeat:root.startBeat pitch:newPitch length:root.length]; 
			
			// add it to the chord
			[self addObject:note];
		}
	}
}

/*
 Menu selection management
 */

- (NSString *)getChordTypeFromSelection:(int)selection {
    switch (selection) {
		case 0:
			return kChordType_Major;
			break;
		case 1:
			return kChordType_Minor;
			break;
		case 2:
			return kChordType_Augmented;
			break;
		case 3:
			return kChordType_Diminished;
			break;
        default:
			return kKeyMajor;
			break;
	}
}

/*
 Menu selection management
 */

- (OCChordModifier)getChordModifierFromSelection:(int)selection {
    switch (selection) {
		case 0:
			return kFlagChordModifer_None;
			break;
		case 1:
			return kFlagChordModifier_Suspended;
			break;
		case 2:
			return kFlagChordModifier_Power;
			break;
        default:
			return kFlagChordModifer_None;
			break;
	}
}

/*
 Menu selection management
 */

- (int)getChordExtensionSeventhSelection:(int)selection {
    switch (selection) {
		case 0:
			return kFLagChordExtension_NotSelected;
			break;
		case 1:
			return kFlagChordExtension_Seventh;
			break;
		default:
			return kFLagChordExtension_NotSelected;
			break;
	}
}

/*
 Menu selection management
 */

- (int)getchordExtensionSeventhModifierSelection:(int)selection {
	switch (selection) {
		case 0:
			return kFlagChordExtensionModifier_Major;
			break;
		case 1:
			return kFlagChordExtensionModifier_Minor;
			break;
		default:
			return kFlagChordExtensionModifier_Major;
			break;
	}
}

@end