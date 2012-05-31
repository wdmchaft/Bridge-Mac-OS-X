//
//  OCPlayController.m
//  Bridge
//
//  Created by Philip Regan on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OCPlayController.h"
#import "OCWindowController.h"
#import "MyDocument.h"
#import "OCNotePlayer.h"
#import "OCConstantsLib.h"
#import "OCConstants.h"

@implementation OCPlayController

@synthesize windowController;
@synthesize myDocument;
@synthesize startPosition;
@synthesize cursorPosition;
@synthesize stopPosition;

- (id)init {
    self = [super init];
    if (self) {
		queue = [[NSOperationQueue alloc] init];		
    }
    return self;
}

- (void)dealloc {
	[windowController release];
	[myDocument release];
    [queue release];
    [super dealloc];
}

/*
 Kicks off the process of collecting data and managing the NSOperation needed to 
 play music.
 */

- (void)playNotes {
	
	startPosition = 0;
	cursorPosition = startPosition;
	
	// get the default size of the editor area
	NSNumber *timeSigBasicBeatMIDILength = [[OCConstantsLib sharedLib].kOCData_TimeSignatureBeatMIDILengths objectAtIndex:windowController.timeSignatureBasicBeatIndex];
	int timeSigBasicBeatMIDILengthValue = [timeSigBasicBeatMIDILength intValue];
	float stopBuffer = timeSigBasicBeatMIDILengthValue * myDocument.timeSignatureBeatsPerMeasure * kOCModel_DefaultNumberOfMeasures;
	stopPosition = (int)stopBuffer;
	
	[queue cancelAllOperations];
		
	OCNotePlayer *notePlayer = [[OCNotePlayer alloc] initWithPlayController:self];
	[queue addOperation:notePlayer];
	[notePlayer release];
	
}

/*
 Stops all music playing for the player, regardless of state.
 */

- (void)stopNotes {
	[queue cancelAllOperations];
	cursorPosition = startPosition;
}

/*
 Data accessor for the NotePlayer
 */
- (NSMutableArray *)notes {
	return [windowController notes];
}

@end
