//
//  OCNotePlayer.m
//  Bridge
//
//  Created by Philip Regan on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OCNotePlayer.h"

#import "OCPlayController.h"
#import "OCNoteObj.h"
#import "OCConstants.h"

@implementation OCNotePlayer

-(OCNotePlayer *) initWithPlayController:(OCPlayController *)playController {
	
	self = [super init];
    if (self) {
		
		parentPlayController = playController;
		[parentPlayController retain];
		
		notes = [parentPlayController.windowController notes];
		[notes retain];
		
	}
	return self;
}

- (void)dealloc {
    [parentPlayController release];
	[notes release];
    [super dealloc];
}



-(void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	/* 
	 This code is pulled almost verbatim from Apple's PlaySoftMIDI example project 
	 and continues to around line 105-110 
	 */
	
    AUGraph graph;
    AudioUnit synthUnit;
    OSStatus result;
    
    UInt8 midiChannelInUse = 0; //we're using midi channel 1...
    
    //create the nodes of the graph
    AUNode synthNode;
    AUNode limiterNode;
    AUNode outNode;
    
    AudioComponentDescription cd;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = 0;
    cd.componentFlagsMask = 0;
    
    require_noerr (result = NewAUGraph (&graph), home);
    
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_DLSSynth;
    
    require_noerr (result = AUGraphAddNode(graph, &cd, &synthNode), home);
    
    cd.componentType = kAudioUnitType_Effect;
    cd.componentSubType = kAudioUnitSubType_PeakLimiter;  
    
    require_noerr (result = AUGraphAddNode (graph, &cd, &limiterNode), home);
    
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_DefaultOutput;  
    require_noerr (result = AUGraphAddNode (graph, &cd, &outNode), home);
    
    require_noerr (result = AUGraphOpen (graph), home);
    
    require_noerr (result = AUGraphConnectNodeInput (graph, synthNode, 0, limiterNode, 0), home);
    require_noerr (result = AUGraphConnectNodeInput (graph, limiterNode, 0, outNode, 0), home);
    
    // ok we're good to go - get the Synth Unit...
    require_noerr (result = AUGraphNodeInfo(graph, synthNode, 0, &synthUnit), home);
    
    // ok we're set up to go - initialize and start the graph
    require_noerr (result = AUGraphInitialize (graph), home);
    //set our bank
    require_noerr (result = MusicDeviceMIDIEvent(synthUnit, 
                                                 kMidiMessage_ControlChange << 4 | midiChannelInUse, 
                                                 kMidiMessage_BankMSBControl, 0,
                                                 0/*sample offset*/), home);
    
    require_noerr (result = MusicDeviceMIDIEvent(synthUnit, 
                                                 kMidiMessage_ProgramChange << 4 | midiChannelInUse, 
                                                 0/*prog change num*/, 0,
                                                 0/*sample offset*/), home);
    
    require_noerr (result = AUGraphStart (graph), home);

    
	if ( ![self isCancelled] ) {
		
		UInt32 noteOnCommand = 	kMidiMessage_NoteOn << 4 | midiChannelInUse;
		
		/* This code is back to original project code */
		
		do {
			
			/*
			 The basic process is thus:
			 
			 We iterate across the beats with the start, stop, and cursor positions

			 We iterate *up* through the notes (in case the user deletes any of 
			 them). If the state of the note matches the cursor, then we act upon 
			 the note
			 
			 We cast to int safely because note properties are *always* whole numbers
			 
			 To ensure logical playing, we stop notes first, and then play them.
			 Stopping the operation itself handles the complete stopping of all
			 notes for us.
			 */
			
			int noteCount = [notes count] - 1;
			for ( int n = noteCount ; n >= 0 ; n-- ) {
				OCNoteObj *note = [notes objectAtIndex:n];
				if ( (int)note.startBeat + (int)note.length == parentPlayController.cursorPosition ) {
					require_noerr (result = MusicDeviceMIDIEvent(synthUnit, noteOnCommand, (UInt32)note.pitch, 0, 0), home);
				}
			}

			for ( int n = noteCount ; n >= 0 ; n-- ) {
				OCNoteObj *note = [notes objectAtIndex:n];
				if ( (int)note.startBeat == parentPlayController.cursorPosition ) {
					require_noerr (result = MusicDeviceMIDIEvent(synthUnit, noteOnCommand, (UInt32)note.pitch, 120, 0), home);
				}
			}
			
			// move the cursor forward and loop back if needed
			parentPlayController.cursorPosition++;
			if ( parentPlayController.cursorPosition > parentPlayController.stopPosition ) {
				parentPlayController.cursorPosition = parentPlayController.startPosition;
			}
			
			// delay the required amount per the tempo and the basic beat amount
			[self delay];
			
			// lather, rinse, repeat until the user presses the stop button
			
		} while ( ![self isCancelled] );
		
		// ok we're done now
			
	}
	
	[pool release];
	
home:
	if (graph) {
		AUGraphStop (graph); // stop playback
		DisposeAUGraph (graph);
	}

}

/* 
 sleep for the calculatated interval for 120 bpm on the quarter note
 */

-(void)delay {
	// bpm and time sig basic beat should be pulled from the document since those 
	// are user settings
	int microseconds = 1000000;
	int secondsPerMinute = 60;
	int bpm = 120;
	int timeSigBasicBeat = kNoteLength_04; // 1/4 note
	usleep ( microseconds * secondsPerMinute / bpm / timeSigBasicBeat );
}

@end