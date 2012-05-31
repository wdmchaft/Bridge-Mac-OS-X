//
//  OCNotePlayer.h
//  Bridge
//
//  Created by Philip Regan on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 The NotePlayer class is where the rubber meets the road in terms of turning
 music data into something audible to the user. It is based on the NSOperation class
 so that the task of playing can be spun off into a thread and (mostly) not interfere
 with user interaction elsewhere in the application.
 
 It is written in Objective-C++, a variant of Objective-C that allows the seamless
 merging of C++ code, because all of the audio frameworks are written in C++.
 
 The class is inited with a PlayController that acts as a conduit for user settings
 such as time signature and tempo, but more importantly, the NotePlayer is fed the
 array of OCNoteObj that is the "material" data of the application.
 */

#import <Cocoa/Cocoa.h>

#include <CoreServices/CoreServices.h>
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h> //for AUGraph
#include <unistd.h> // used for usleep...

// some MIDI constants:
enum {
	kMidiMessage_ControlChange 		= 0xB,
	kMidiMessage_ProgramChange 		= 0xC,
	kMidiMessage_BankMSBControl 	= 0,
	kMidiMessage_BankLSBControl		= 32,
	kMidiMessage_NoteOn 			= 0x9
};


@class OCPlayController;
@class OCNoteObj;

@interface OCNotePlayer : NSOperation {
	
	OCPlayController *parentPlayController;
	NSMutableArray *notes;
	
}

-(OCNotePlayer *) initWithPlayController:(OCPlayController *)playController;

-(void)delay;

@end
