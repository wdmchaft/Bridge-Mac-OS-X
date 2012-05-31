//
//  OCPlayController.h
//  Bridge
//
//  Created by Philip Regan on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 
 The Play Controller is a dedicated controller that manages the data needed to 
 play notes. It links directly to the window controller and the document to get
 the data it needs to know what to play, when to play it, and how long it should
 play. It acts as a conduit from the user's settings and music data to a NotePlayer.
 Music playing handled directly handled by the NotePlayer class.
 
 This is based on a germinal NSOperation and NSOperationQueue model taken from the 
 NSOperation example by Apple.
 
 */

#import <Cocoa/Cocoa.h>

@class OCWindowController;
@class MyDocument;
@class OCNotePlayer;
@class OCConstantsLib;

@interface OCPlayController : NSObject {
	OCWindowController *windowController;
	MyDocument *myDocument;
	NSOperationQueue *queue;
	
	int startPosition;
	int cursorPosition;
	int stopPosition;
	
}

@property (nonatomic, retain) OCWindowController *windowController;
@property (nonatomic, retain) MyDocument *myDocument;

@property (readwrite) int startPosition;
@property (readwrite) int cursorPosition;
@property (readwrite) int stopPosition;

- (void)playNotes;
- (void)stopNotes;

- (NSMutableArray *)notes;

@end
