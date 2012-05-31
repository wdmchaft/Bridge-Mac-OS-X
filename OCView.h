//
//  OCView.h
//  OCDocumentFramework
//
//  Created by Philip Regan on 2/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * This is the core Piano Roll interface where most editing takes place.
 * This class is designed to intercept user actions and push needed data to the 
 * WindowController which is responsible for the actual music data.
 * This class primarily handles mouse events and drawing, and should not actually
 * manipulate data.
 */

#import <Cocoa/Cocoa.h>

#import "OCConstants.h"


@class OCWindowController;
@class OCConstantsLib;
@class OCMusicLib;

@class OCNoteObj;
@class OCGroupObj;
@class OCChordObj;
@class OCSequenceObj;
@class OCResizeTabObj;

@interface OCView : NSView {

	IBOutlet OCWindowController *windowController;
    
    float zoomX;
    float zoomY;
	
	NSRect editorArea;
	
	int timeSignatureBasicBeat;
	int timeSignatureBeatsPerMeasure;
	
	int snapToValue;
	
	float snapToUnit;
	float measureUnit;
	float keyRollUnit;
	    
    NSPoint mouseDownPoint;
    NSPoint lastDragPoint;
    
    enum OCMouseMode mouseMode;
    int lastDeltaX;
	
	float dragBoundX;
	float dragBoundY;
	float dragBoundW;
	float dragBoundH;
		
}

#pragma mark -
#pragma mark Properties
#pragma mark -

@property (nonatomic, retain) IBOutlet OCWindowController *windowController;

@property (readwrite) float zoomX;
@property (readwrite) float zoomY;

@property (nonatomic) NSRect editorArea;

@property (nonatomic) int timeSignatureBasicBeat;
@property (nonatomic) int timeSignatureBeatsPerMeasure;

@property (nonatomic) int snapToValue;

@property (readwrite) NSPoint mouseDownPoint;
@property (readwrite) NSPoint lastDragPoint;

#pragma mark -
#pragma mark Drawing Calculations
#pragma mark -

- (void) calculateValuesForDrawing;
- (NSRect) calculateRectFromNote:(OCNoteObj *)note;
- (NSRect) calculateRectFromGroup:(OCGroupObj *)group;
- (NSRect) calculateRectFromChord:(OCChordObj *)chord;
- (NSRect) calculateRectFromSequence:(OCSequenceObj *)sequence;

#pragma mark Resize Tab Calculations

- (NSRect) calculateResizeTabRectFromRect:(NSRect)rect;

@end
