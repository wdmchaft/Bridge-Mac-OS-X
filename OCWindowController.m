//
//  OCWindowController.m
//  OCDocumentFramework
//
//  Created by Philip Regan on 2/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * Primary interface between the MyDocument (model) and the editors (views).
 * This manages any higher-level editing of objects, and pushes changes to the 
 * MyDocument class.
 * Currently only the OCView (piano roll interface) is allowed user changes
 */

#import "OCWindowController.h"

#import "OCConstants.h"
#import "OCConstantsLib.h"

#import "OCView.h"
#import "OCScrollView.h"

#import "OCRulerView.h"
#import "OCKeyRollView.h"

#import "MyDocument.h"

#import "OCMusicObj.h"
#import "OCNoteObj.h"
#import "OCGroupObj.h"
#import "OCChordObj.h"
#import "OCSequenceObj.h"
#import "OCResizeTabObj.h"
#import "OCMusicPieceObj.h"
#import "OCKeyObj.h"

#import "OCSelectKeyWindowController.h"
#import "OCSelectChordWindowController.h"

#import "OCPlayController.h"

@implementation OCWindowController

@synthesize selectKeySheet;
@synthesize selectChordSheet;

@synthesize linkedView;
@synthesize EditModeSelector;
@synthesize defaultLengthSelector;
@synthesize myDocument;

@synthesize timeSignatureBasicBeatIndex;

@synthesize zoomXIndex;
@synthesize zoomYIndex;

@synthesize editorMode;

- (id) init
{
	self = [super init];
	if (self != nil) {
		// properties cannot by initialized here; go to windowDidLoad
	}
	return self;
}

- (void) dealloc
{
	[linkedView release];
	linkedView = nil;
	
	[rulerView release];
	rulerView = nil;
	
	[myDocument release];
	myDocument = nil;
	
	[selection release];
	selection = nil;
	
	[super dealloc];
}

- (void)windowDidLoad {
	
	/* 
	 This sets up the bindings, notifications, and defaults before reading from the document. 
	 The updateViews method populates from the documents.
	 */
	
	selection = [[NSMutableArray array] retain];
	
	// set up time signature values and controls
	
	timeSignatureBasicBeatIndex = myDocument.timeSignatureBasicBeatIndex; // possibly redundant
	timeSignatureBeatsPerMeasure = myDocument.timeSignatureBeatsPerMeasure; // possibly redundant
	
	[timeSignatureBeatsPerMeasureStepper setMinValue:(double)1];
	[timeSignatureBeatsPerMeasureStepper setMaxValue:(double)32];
	[timeSignatureBeatsPerMeasureStepper setIncrement:(double)1];
	[timeSignatureBeatsPerMeasureStepper setIntValue:4];
	
	[timeSignatureBeatsPerMeasureField setStringValue:[timeSignatureBeatsPerMeasureStepper stringValue]];
	
	[timeSignatureBasicBeatStepper setMinValue:(double)1];
	[timeSignatureBasicBeatStepper setMaxValue:(double)[[OCConstantsLib sharedLib].kOCData_TimeSignatureBeatLengths count] - 2]; // 2 to ignore 1/64th notes.
	[timeSignatureBasicBeatStepper setIncrement:(double)1];
	[timeSignatureBasicBeatStepper setIntValue:2]; // index for 1/4 note
	
	NSNumber *timeSigBasicBeatLength = [[OCConstantsLib sharedLib].kOCData_TimeSignatureBeatLengths objectAtIndex:myDocument.timeSignatureBasicBeatIndex];
	[timeSignatureBasicBeatField setStringValue:[timeSigBasicBeatLength stringValue]];
	
	/* set up the music player */
	
	playController = [[OCPlayController alloc] init];
	playController.windowController = self;
	playController.myDocument = myDocument;
	
	// set up new note defaults
	
	defaultLength = kOCView_DefaultNoteLength;
	snapToValue = kOCView_DefaultNoteLength;
	
	// set up the scroll views
	
	scrollView = (OCScrollView *)[linkedView enclosingScrollView];
	masterEditorArea = myDocument.editorArea;
	
	// set up the zoom values
	
	zoomXIndex = [OCConstantsLib sharedLib].kOCView_zoomIndex_100;
	zoomYIndex = [OCConstantsLib sharedLib].kOCView_zoomIndex_100;
	
	// set up the layout of the views
	
	float scrollbarHeight = 15.0;
	[keyRollView setFrame:NSMakeRect([keyRollView frame].origin.x, 
									 [scrollView frame].origin.y, 
									 [keyRollView frame].size.width, 
									 [[scrollView contentView] frame].size.height + scrollbarHeight)];
	[keyRollView setBounds:NSMakeRect([keyRollView bounds].origin.x, 
									  [[scrollView contentView] bounds].origin.y - scrollbarHeight,
									  [keyRollView bounds].size.width, 
									  [[scrollView contentView] bounds].size.height + scrollbarHeight)];
	scrollView.keyRollView = keyRollView;
	
	[rulerView setFrame:NSMakeRect([rulerView frame].origin.x, 
								   [rulerView frame].origin.y, 
								   masterEditorArea.size.width, 
								   [rulerView frame].size.height)];
	[rulerView setBounds:NSMakeRect([rulerView bounds].origin.x - 20.0, 
									[rulerView bounds].origin.y, 
									[rulerView bounds].size.width, 
									[rulerView bounds].size.height)];
	scrollView.rulerView = rulerView;
	
	lastScrollViewHeight = [scrollView frame].size.height;
	originalScrollViewHeight = [scrollView frame].size.height;
	
	// set up the notification bindings for the views
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[[scrollView contentView] setPostsBoundsChangedNotifications:YES];
	
    [center addObserver: rulerView
			   selector: @selector(boundsDidChangeNotification:)
				   name: NSViewBoundsDidChangeNotification
				 object: [scrollView contentView]];
	
	[center addObserver: self
			   selector: @selector(boundsDidChangeNotification:)
				   name: NSViewBoundsDidChangeNotification
				 object: [scrollView contentView]];
	
	[center addObserver: keyRollView
			   selector: @selector(boundsDidChangeNotification:)
				   name: NSViewBoundsDidChangeNotification
				 object: [scrollView contentView]];
	 
	[[scrollView contentView] setPostsFrameChangedNotifications:YES];
	
	[center addObserver: rulerView
			   selector: @selector(boundsDidChangeNotification:)
				   name: NSViewFrameDidChangeNotification
				 object: [scrollView contentView]];
	
	[center addObserver: self
			   selector: @selector(boundsDidChangeNotification:)
				   name: NSViewFrameDidChangeNotification
				 object: [scrollView contentView]];
		
    [self updateViews];

    // auto scroll to the middle of the editor so we start within a reasonable range 
    // of pitches
    // auto scroll has to come AFTER the updateViews call, otherwise it won't work
    // TODO: Commented out due to wonky drawing errors; will revisit if there is time
    /*
    float defaultProportionToMiddleC = 2.5;
    NSPoint midPoint = NSMakePoint( NSMinX( masterEditorArea ), NSMaxY( masterEditorArea ) / defaultProportionToMiddleC );
    [[scrollView contentView] scrollToPoint:midPoint];
    [scrollView reflectScrolledClipView:[scrollView contentView]];
    
    [linkedView setNeedsDisplay:YES];
    [rulerView setNeedsDisplay:	YES];
    [keyRollView setNeedsDisplay:YES];
    */
}
	
- (void) boundsDidChangeNotification: (NSNotification *) notification
{
	
	[linkedView setFrame:zoomedMasterEditorArea];
	
}

#pragma mark -
#pragma mark Zoom Management
#pragma mark -

- (NSRect) refactorRectToCurrentZoom:(NSRect)aRect {
    
    float zoomX = [[OCConstantsLib sharedLib] getZoomFactorAtIndex:zoomXIndex];
    float zoomY = [[OCConstantsLib sharedLib] getZoomFactorAtIndex:zoomYIndex];
    
    float origX = aRect.origin.x;
    float origY = aRect.origin.y;
    float origW = aRect.size.width;
    float origH = aRect.size.height;
    
    float newX = origX * zoomX;
    float newY = origY * zoomY;
    float newW = origW * zoomX; 
    float newH = origH * zoomY;
    
    if ( origX == 0.0 ) { newX = 0; }
    if ( origY == 0.0 ) { newY = 0; }
    
    NSRect refactoredRect = NSMakeRect(newX, newY, newW, newH);
    
    return refactoredRect;
}

- (NSRect) defactorRectAtCurrentZoom:(NSRect)aRect {
    
    float zoomX = [[OCConstantsLib sharedLib] getZoomDefactorAtIndex:zoomXIndex];
    float zoomY = [[OCConstantsLib sharedLib] getZoomDefactorAtIndex:zoomYIndex];
    
    float origX = aRect.origin.x;
    float origY = aRect.origin.y;
    float origW = aRect.size.width;
    float origH = aRect.size.height;
    
    float newX = origX * zoomX;
    float newY = origY * zoomY;
    float newW = origW * zoomX; 
    float newH = origH * zoomY;
    
    if ( origX == 0.0 ) { newX = 0; }
    if ( origY == 0.0 ) { newY = 0; }
    
    NSRect defactoredRect = NSMakeRect(newX, newY, newW, newH);
    
    return defactoredRect;
    
}

- (IBAction) increaseZoomX:(id)sender {
    zoomXIndex++;
    
    if (zoomXIndex >= [OCConstantsLib sharedLib].kOCView_ZoomXMaxIndex) { 
        zoomXIndex = [OCConstantsLib sharedLib].kOCView_ZoomXMaxIndex; 
        [increaseZoomXButton setEnabled:NO];
        [decreaseZoomXButton setEnabled:YES];
    } else {
        [increaseZoomXButton setEnabled:YES];
        [decreaseZoomXButton setEnabled:YES];
    }
    
    [self updateViews];
    
}

- (IBAction) decreaseZoomX:(id)sender {
    zoomXIndex--;
    
    if (zoomXIndex <= [OCConstantsLib sharedLib].kOCView_ZoomXMinIndex) { 
        zoomXIndex = [OCConstantsLib sharedLib].kOCView_ZoomXMinIndex;
        [increaseZoomXButton setEnabled:YES];
        [decreaseZoomXButton setEnabled:NO];
    } else {
        [increaseZoomXButton setEnabled:YES];
        [decreaseZoomXButton setEnabled:YES];
    }
    
    [self updateViews];
}

- (IBAction) increaseZoomY:(id)sender {
    zoomYIndex++;
    
    if (zoomYIndex >= [OCConstantsLib sharedLib].kOCView_ZoomYMaxIndex) { 
        zoomYIndex = [OCConstantsLib sharedLib].kOCView_ZoomYMaxIndex; 
        [increaseZoomYButton setEnabled:NO];
        [decreaseZoomYButton setEnabled:YES];
    } else {
        [increaseZoomYButton setEnabled:YES];
        [decreaseZoomYButton setEnabled:YES];
    }
    
    [self updateViews];
}

- (IBAction) decreaseZoomY:(id)sender {
    zoomYIndex--;
    
    if (zoomYIndex <= [OCConstantsLib sharedLib].kOCView_ZoomYMinIndex) { 
        zoomYIndex = [OCConstantsLib sharedLib].kOCView_ZoomYMinIndex; 
        [increaseZoomYButton setEnabled:YES];
        [decreaseZoomYButton setEnabled:NO];
    } else {
        [increaseZoomYButton setEnabled:YES];
        [decreaseZoomYButton setEnabled:YES];
    }
    
    [self updateViews];
}
	
#pragma mark -
#pragma mark Control Management
#pragma mark -
	
	
- (IBAction) updateNewNoteValue:(id)sender {
    
	int selectedSegment = [sender selectedSegment];
	switch (selectedSegment) {
		case 0:
			defaultLength = (float)kNoteLength_01;
			break;
		case 1:
			defaultLength = (float)kNoteLength_02;
			break;
		case 2:
			defaultLength = (float)kNoteLength_04;
			break;
		case 3:
			defaultLength = (float)kNoteLength_08;
			break;
		case 4:
			defaultLength = (float)kNoteLength_16;
			break;
		case 5:
			defaultLength = (float)kNoteLength_32;
			break;
		case 6:
			defaultLength = (float)kNoteLength_64;
			break;
		default:
			defaultLength = (float)kOCView_DefaultNoteLength;
			break;
			
	}

    [self updateViews];
}

- (IBAction) updateSnapToValue:(id)sender {
    
    int selectedSegment = [sender selectedSegment];
	switch (selectedSegment) {
		case 0:
			snapToValue = (float)kNoteLength_01;
			break;
		case 1:
			snapToValue = (float)kNoteLength_02;
			break;
		case 2:
			snapToValue = (float)kNoteLength_04;
			break;
		case 3:
			snapToValue = (float)kNoteLength_08;
			break;
		case 4:
			snapToValue = (float)kNoteLength_16;
			break;
		case 5:
			snapToValue = (float)kNoteLength_32;
			break;
		case 6:
			snapToValue = (float)kNoteLength_64;
			break;
		default:
			snapToValue = (float)kOCView_DefaultNoteLength;
			break;

	}
	
    [self updateViews];
}



- (IBAction) updateTimeSignatureBeatsPerMeasure:(id)sender {
    [myDocument setTimeSignatureBeatsPerMeasure:[sender intValue]];
    [timeSignatureBeatsPerMeasureField setStringValue:[timeSignatureBeatsPerMeasureStepper stringValue]];
    [self updateViews];
}

- (IBAction) updateTimeSignatureBasicBeat:(id)sender {
    [myDocument setTimeSignatureBasicBeatIndex:[sender intValue]];
    
    NSNumber *timeSigBasicBeatLength = [[OCConstantsLib sharedLib].kOCData_TimeSignatureBeatLengths objectAtIndex:[myDocument timeSignatureBasicBeatIndex]];
    [timeSignatureBasicBeatField setStringValue:[timeSigBasicBeatLength stringValue]];
    [self updateViews];
}

#pragma mark -
#pragma mark Menu Management
#pragma mark -

- (IBAction) groupSelection:(id)sender {
	if ( [selection count] > 1 ) {
		OCGroupObj *group = [myDocument createGroup];
		[group groupObjects:selection];
		[self selectNone:nil];
        [self addGroupToSelection:group];
	}
}

- (IBAction) ungroupSelection:(id)sender {
	if ( [selection count] > 0 ) {
		for ( OCMusicObj *musicObj in selection ) {
            // we use isKindOfClass since were are generically doing this all grouping
            // classes. Any special cases are handled in the class itself.
            // this might need to be changed, however.
			if ( [musicObj isKindOfClass:[OCGroupObj class]] ) {
				OCGroupObj *group = (OCGroupObj *)musicObj;
                NSMutableArray *remainingObjects = [[group ungroupObjects] retain];
				[self removeGroupFromSelection:group];
				[selection addObjectsFromArray:remainingObjects];
				[myDocument deleteFromDocumentGroup:group];
                [remainingObjects release];
			}
		}
        // for some reason the view doesn't update automatically like in groupSelection
        [self updateViews];
	}
}

- (IBAction)changeKey:(id)sender {
    
    // if we havenn't made a sheet before, make one now by loading the XIB file.
    if (selectKeySheet == nil)
	{
        NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
		NSNib *nib = [[NSNib alloc] initWithNibNamed:@"OCSelectKeyWindow" bundle:myBundle];
		
		BOOL success = [nib instantiateNibWithOwner:self topLevelObjects:nil];
        if (success != YES)
		{
			// should present error
			return;
		}
    }
    
    // show the sheet (by loading lazily) and report back later when it is closed
	[[NSApplication sharedApplication] beginSheet:selectKeySheet 
                                   modalForWindow:[self window] 
                                    modalDelegate:self 
                                   didEndSelector:@selector(selectKeySheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:NULL];
    
    // now that the sheet is in view, update the interface
    [selectKeyWindowController initInterface];
        
}

- (IBAction)makeChordsWithSelection:(id)sender {
    
    // if we havenn't made a sheet before, make one now by loading the XIB file.
    if (selectChordSheet == nil)
	{
        NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
		NSNib *nib = [[NSNib alloc] initWithNibNamed:@"OCSelectChordWindow" bundle:myBundle];
		
		BOOL success = [nib instantiateNibWithOwner:self topLevelObjects:nil];
        if (success != YES)
		{
			// should present error
			return;
		}
    }
    
    // show the sheet (by loading lazily) and report back later when it is closed
	[[NSApplication sharedApplication] beginSheet:selectChordSheet 
                                   modalForWindow:[self window] 
                                    modalDelegate:self 
                                   didEndSelector:@selector(selectChordSheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:NULL];
    
    // now that the sheet is in view, update the interface
    [selectChordWindowController initInterface];

    
}

- (IBAction)makeSequenceWithSelection:(id)sender {
    if ( [selection count] > 1 ) {
		OCSequenceObj *sequence = [myDocument createSequence];
		[sequence groupObjects:selection];
		[self selectNone:nil];
        [self addSequenceToSelection:sequence];
	}
    [self updateViews];
}

#pragma mark -
#pragma mark Window Management
#pragma mark -

#pragma mark Select Key Window

// all of the commands are passed from the OCSelectKeyViewController

- (IBAction)setKeyTonic:(id)sender {
    // store the selected key tonic
    selectedKeyTonic = [(NSPopUpButton *)sender indexOfSelectedItem];
}

- (IBAction)setKeyType:(id)sender {
    // store the selected key type
    selectedKeyType = [(NSPopUpButton *)sender indexOfSelectedItem];
}

- (IBAction)keyOkButton:(id)sender {
    // close the window returning "OK"
    [[NSApplication sharedApplication] endSheet:selectKeySheet returnCode:NSOKButton];
    [NSApp endSheet:selectKeySheet];
}

- (IBAction)keyCancelButton:(id)sender {
    // close the window returning "Cancel"
    [[NSApplication sharedApplication] endSheet:selectKeySheet returnCode:NSCancelButton];
    [NSApp endSheet:selectKeySheet];
}

// called when the window has been closed

- (void)selectKeySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{	
	// They want to change the key, so change it, else do nothing
	if (returnCode == NSOKButton)
	{
		myDocument.musicPiece.key.keyTonic = selectedKeyTonic;
        myDocument.musicPiece.key.keyType = selectedKeyType;
        [myDocument.musicPiece.key calculatePitches];
        [self updateViews];
	}
	
	// close the sheet

	[sheet orderOut:self];
    
}

#pragma mark Select Chord Window

- (IBAction)setChordType:(id)sender {
	selectedChordType = [(NSPopUpButton *)sender indexOfSelectedItem];
}

- (IBAction)selectExtensionSeventh:(id)sender {
	if ( [(NSButton *)sender state] == NSOnState ) {
		selectedSeventhExtension = 1;
	} else {
		selectedSeventhExtension = 0;
	}
}

- (IBAction)selectExtensionSeventhModifier:(id)sender {
	selectedSeventhExtensionModifier = [(NSPopUpButton *)sender indexOfSelectedItem];
}

- (IBAction)selectChordModifier:(id)sender {
	selectedChordModifer = [(NSPopUpButton *)sender indexOfSelectedItem];
}

- (IBAction)chordOkButton:(id)sender {
	// close the window returning "OK"
    [[NSApplication sharedApplication] endSheet:selectChordSheet returnCode:NSOKButton];
    [NSApp endSheet:selectChordSheet];
}
	
- (IBAction)chordCancelButton:(id)sender {
	// close the window returning "Cancel"
    [[NSApplication sharedApplication] endSheet:selectChordSheet returnCode:NSCancelButton];
    [NSApp endSheet:selectChordSheet];
}

- (void)selectChordSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo {
	
	// close the sheet
	
	[sheet orderOut:self];
	
	// They want to create chords, else do nothing if they clicked cancel
	if (returnCode == NSOKButton)
	{
		[self createChordsWithSelection:nil];
		[self updateViews];

	}
	


}


		
#pragma mark -
#pragma mark Color Management
#pragma mark -
		
- (NSColor *)defaultColor {
    return [[self document] defaultColor];
}
		
#pragma mark -
#pragma mark State Management
#pragma mark -
		
- (void) updateViews {
    
    // Editing Area
    
    zoomedMasterEditorArea = [self refactorRectToCurrentZoom:myDocument.editorArea];
    
    linkedView.editorArea = zoomedMasterEditorArea;
    keyRollView.editorArea = zoomedMasterEditorArea;
    rulerView.editorArea = zoomedMasterEditorArea;
    
    // Zoom Values
    
    linkedView.zoomX = [[OCConstantsLib sharedLib] getZoomFactorAtIndex:self.zoomXIndex];
    linkedView.zoomY = [[OCConstantsLib sharedLib] getZoomFactorAtIndex:self.zoomYIndex];
    rulerView.zoomX = [[OCConstantsLib sharedLib] getZoomFactorAtIndex:self.zoomXIndex];
    keyRollView.zoomY = [[OCConstantsLib sharedLib] getZoomFactorAtIndex:self.zoomYIndex];
	keyRollView.keyObj = [self key];
    
    // Core Units of Measure for calculating drawing units
    
    NSNumber *timeSigBasicBeatMIDILength = [[OCConstantsLib sharedLib].kOCData_TimeSignatureBeatMIDILengths objectAtIndex:myDocument.timeSignatureBasicBeatIndex];
    
    linkedView.timeSignatureBasicBeat = [timeSigBasicBeatMIDILength intValue];
    linkedView.timeSignatureBeatsPerMeasure = myDocument.timeSignatureBeatsPerMeasure;
    linkedView.snapToValue = snapToValue;
    
    rulerView.timeSignatureBasicBeat = [timeSigBasicBeatMIDILength intValue];
    rulerView.timeSignatureBeatsPerMeasure = myDocument.timeSignatureBeatsPerMeasure;
    rulerView.snapToValue = snapToValue;
	    
    // for now we set the frame in only the editor because we want to scrollbars to update.
    [linkedView setFrame:zoomedMasterEditorArea];
    
    // calculate the values needed for drawing ONCE and not every time we draw
    [linkedView calculateValuesForDrawing];
    [rulerView calculateValuesForDrawing];
    [keyRollView calculateValuesForDrawing];

    // update the interface. (a.k.a. give it the goose)
    
    [linkedView setNeedsDisplay:YES];
    [rulerView setNeedsDisplay:	YES];
    [keyRollView setNeedsDisplay:YES];
}
		
- (void) notifyKeyRollOfInterfaceUpdate {	
	lastScrollViewHeight = currentScrollViewHeight;
	currentScrollViewHeight = [scrollView frame].size.height;
}

- (int) timeSignatureBeatsPerMeasure {
	return myDocument.timeSignatureBeatsPerMeasure;
}

#pragma mark -
#pragma mark Object Management
#pragma mark -

/*
 * Simple property accessors to the model
 */

- (NSMutableArray *) notes {
    return myDocument.notes;
}

- (NSMutableArray *) groups {
	return myDocument.groups;
}

- (NSMutableArray *) chords {
	return myDocument.chords;
}

- (NSMutableArray *) sequences {
    return myDocument.sequences;
}

- (NSMutableArray *) resizeTabs {
    return myDocument.resizeTabs;
}

- (OCMusicPieceObj *) musicPiece {
    return myDocument.musicPiece;
}

- (OCKeyObj *)key {
	return myDocument.musicPiece.key;
}



#pragma mark Object Creation

- (void) createNoteAtBeat:(float)beat pitch:(float)pitch {
	float snapBeat = floor( beat / snapToValue ) * snapToValue;
	OCNoteObj *note = [myDocument createNoteAtStartBeat:snapBeat pitch:pitch length:defaultLength];
    
	if ( !note ) {
		// TODO: Handle the error
	}
	
}

- (IBAction)createChordsWithSelection:(id)sender {
    NSMutableArray *chords = [[NSMutableArray array] retain];
	
	// for each note in key in selection; 
	// these are the core functionality for making a chord
	// no group drill-down at this point
	// no updating selected chords to new specs
	// no warning on notes that aren't in key
	
	for ( OCMusicObj *musicObj in selection ) {
		// we use inKindOfClass because we do not need to make a distinction between
		// note classes but we want to keep this open to updates where there might be
		// subclasses of OCNoteObj.
		if ( [musicObj isKindOfClass:[OCNoteObj class]] ) {
			OCNoteObj *note = (OCNoteObj *)musicObj;
			if ( [[self key] isPitchInKey:note.pitch] ) {
				
				// create a chord obj
				OCChordObj *chord = [myDocument createChord];
				[chords addObject:chord];
				
				// pass it the current object in the selection
				[chord addObject:note];
				
				// set the user selections in the chord object
				chord.chordTypeSelection = selectedChordType;
				chord.chordModifierSelection = selectedChordModifer;
				chord.chordExtensionSeventhSelection = selectedSeventhExtension;
				chord.chordExtensionSeventhModifierSelection = selectedSeventhExtensionModifier;
				
				// set the document to the chord object so it can make notes
				chord.myDocument = myDocument;
				
				// calculate pitchs
				[chord calculatePitches];
			}
		}
	}
	
	// swap the converted notes for the chords
	[self selectNone:nil];
	for ( OCMusicObj *musicObj in chords ) {
		[self addMusicObjToSelection:musicObj];
	}
	// clean up
	[chords release];

}

#pragma mark Object Movement

/*
 * Moves every object in selectin by a certain distance
 */

- (void) moveSelectionDeltaX:(float)deltaX DeltaY:(float)deltaY {
    
    // we use isMemberOfClass because we need to handle groups and sequences 
    // in particular ways
    
    for ( OCMusicObj *musicObj in selection ) {
        
        if ( [musicObj isMemberOfClass:[OCNoteObj class]] ) {
            OCNoteObj *note = (OCNoteObj *)musicObj;
            [self moveNote:note DeltaX:deltaX DeltaY:deltaY];
        }
        
        if ( [musicObj isMemberOfClass:[OCChordObj class]] ) {
            OCChordObj *chord = (OCChordObj *)musicObj;
            [self moveChord:chord DeltaX:deltaX DeltaY:deltaY];
        }
        
        if ( [musicObj isMemberOfClass:[OCGroupObj class]] ) {
            OCGroupObj *group = (OCGroupObj *)musicObj;
            [self moveGroup:group DeltaX:deltaX DeltaY:deltaY];
        }
        
        if ( [musicObj isMemberOfClass:[OCSequenceObj class]] ) {
            OCSequenceObj *sequence = (OCSequenceObj *)musicObj;
            [self moveGroup:sequence.root DeltaX:deltaX DeltaY:deltaY];
            [self moveGroup:sequence.sequence DeltaX:deltaX DeltaY:deltaY];
        }
    }
}

/*
 * Moves a single object by a certain distance
 */

- (void)moveNote:(OCNoteObj *)note DeltaX:(float)deltaX DeltaY:(float)deltaY {
    
	note.startBeat = note.oldStartBeat + deltaX;
	note.pitch = note.oldPitch+ deltaY;
    
	if (note.startBeat < 0) { note.startBeat = 0; }
	if (note.pitch < 0) { note.pitch = 0; }
	if (note.pitch > 127) { note.pitch = 127; }	
    
}

- (void) moveGroup:(OCGroupObj *)group DeltaX:(float)deltaX DeltaY:(float)deltaY {
    
    for ( OCMusicObj *musicObj in group.objects ) {
        
        // we use isMemberOfClass because we need to handle groups and sequences 
        // in particular ways
        
        if ( [musicObj isMemberOfClass:[OCNoteObj class]] ) {
            OCNoteObj *note = (OCNoteObj *)musicObj;
            [self moveNote:note DeltaX:deltaX DeltaY:deltaY];
        }
        
        if ( [musicObj isKindOfClass:[OCGroupObj class]] ) {
            OCGroupObj *group = (OCGroupObj *)musicObj;
            [self moveGroup:group DeltaX:deltaX DeltaY:deltaY];
        }
        
    }
}

// this method might be unnecessary
- (void) moveChord:(OCChordObj *)chord DeltaX:(float)deltaX DeltaY:(float)deltaY {
    
    for ( OCMusicObj *musicObj in chord.objects ) {
        
        if ( [musicObj isKindOfClass:[OCNoteObj class]] ) {
            OCNoteObj *note = (OCNoteObj *)musicObj;
            [self moveNote:note DeltaX:deltaX DeltaY:deltaY];
        }
    }
}

#pragma mark Object Resizing

- (void) changeLengthOfSelectionByDeltaX:(float)deltaX {
    // we use isMemberOfClass because we each object type requires special processes
    // to safely resize
    
    for ( OCMusicObj *musicObj in selection ) {
        
        if ( [musicObj isMemberOfClass:[OCNoteObj class]] ) {
            OCNoteObj *note = (OCNoteObj *)musicObj;
            [self changeLengthOfNote:note byDeltaX:deltaX];
        }
        /*
        if ( [musicObj isMemberOfClass:[OCGroupObj class]] ) {
            OCGroupObj *group = (OCGroupObj *)musicObj;
            [self moveChord:chord DeltaX:deltaX DeltaY:deltaY];
        }
        
        if ( [musicObj isMemberOfClass:[OCChordObj class]] ) {
            OCChordObj *chord = (OCChordObj *)musicObj;
            [self moveChord:chord DeltaX:deltaX DeltaY:deltaY];
        }
        */
        if ( [musicObj isMemberOfClass:[OCSequenceObj class]] ) {
            OCSequenceObj *sequence = (OCSequenceObj *)musicObj;
            [self changeLengthOfSequence:sequence byDeltaX:deltaX];
        }
    }
}

- (void) changeLengthOfSequence:(OCSequenceObj *)sequence byDeltaX:(float)deltaX {
    [sequence resizeByDeltaX:deltaX snap:snapToValue];
}

- (void) changeLengthOfNote:(OCNoteObj *)note byDeltaX:(float)deltaX {
    [note resizeByDeltaX:deltaX snap:snapToValue];
}

/*
 * Resets "old" position properties for all objects in selection.
 * Required for all objects to maintain position when scrolling.
 * This is only called in mouseDown event
 */

- (void)setOldData {
    if ( [selection count] == 0 ) {
        return;
    }
    
	for (OCMusicObj *musicObj in selection) {
        
        if ( [musicObj isMemberOfClass:[OCNoteObj class]] ) {
            OCNoteObj *note = (OCNoteObj *)musicObj;
            [note setOldData];
        }
        
        if ( [musicObj isMemberOfClass:[OCGroupObj class]] ) {
            OCGroupObj *group = (OCGroupObj *)musicObj;
            [group setOldData];
        }
		
        if ( [musicObj isMemberOfClass:[OCChordObj class]] ) {
            OCChordObj *chord = (OCChordObj *)musicObj;
            [chord setOldData];
        }
		
		if ( [musicObj isMemberOfClass:[OCSequenceObj class]] ) {
            OCSequenceObj *sequence = (OCSequenceObj *)musicObj;
            [sequence setOldData];
        }
    }
}

#pragma mark Object Deletion

- (void) deleteNoteAtBeat:(float)beat pitch:(float)pitch {
    
    OCMusicObj *musicObj = [self getMusicObjAtBeat:beat pitch:pitch];
    
    // we use isMemberOfClass because object removal of any type needs to be 
    // carefully handled.
    
	if ( [musicObj isMemberOfClass:[OCNoteObj class]] ) {
        OCNoteObj *note = (OCNoteObj *)musicObj;
		[selection removeObject:note];
		[self.myDocument deleteFromDocumentNote:note];
	}
    
    if ( [musicObj isMemberOfClass:[OCGroupObj class]] ) {
        OCGroupObj *group = (OCGroupObj *)musicObj;
        [selection removeObject:group];
		[self deleteGroup:group];
    }
    
    if ( [musicObj isMemberOfClass:[OCSequenceObj class]] ) {
        OCSequenceObj *sequence = (OCSequenceObj *)musicObj;
        [selection removeObject:sequence];
		[self deleteSequence:sequence];
    }
    
    if ( [musicObj isMemberOfClass:[OCChordObj class]] ) {
        OCChordObj *chord = (OCChordObj *)musicObj;
        [selection removeObject:chord];
		[self deleteChord:chord];
    }
    
}

// TODO: Crashes because array is being manipulated while iterating. 
// TODO: Need to manually go through array backwards.

- (IBAction) deleteSelection:(id)sender {
    
    if ( [selection count] == 0 ) {
        return;
    }
    
    NSMutableArray *selectionCache = [NSMutableArray arrayWithArray:selection];
    [self selectNone:nil];
    
    int selectionCount = [selectionCache count];

    for ( int i = selectionCount - 1 ; i >= 0 ; i-- ) {
        
        OCMusicObj *musicObj = [selectionCache objectAtIndex:i];
        
        // we use isMemberOfClass because object removal of any type needs to be 
        // carefully handled.
		
		if ( [musicObj isMemberOfClass:[OCSequenceObj class]] ) {
            OCSequenceObj *sequence = (OCSequenceObj *)musicObj;
            [self deleteSequence:sequence];        
        }
        
        if ( [musicObj isMemberOfClass:[OCGroupObj class]] ) {
            OCGroupObj *group = (OCGroupObj *)musicObj;
            [self deleteGroup:group];        
        }
		
		if ( [musicObj isMemberOfClass:[OCChordObj class]] ) {
            OCChordObj *chord = (OCChordObj *)musicObj;
            [self deleteChord:chord];    
        }
        
        if ( [musicObj isMemberOfClass:[OCNoteObj class]] ) {
            OCNoteObj *note = (OCNoteObj *)musicObj;
            [myDocument deleteFromDocumentNote:note];
        }
    }
    [self updateViews];
}

- (void)deleteSequence:(OCSequenceObj *)sequence {
    [myDocument deleteObjectsFromSequence:sequence];
    [myDocument deleteFromDocumentSequence:sequence];
}

- (void)deleteGroup:(OCGroupObj *)group {
    [myDocument deleteObjectsFromGroup:group];
    [myDocument deleteFromDocumentGroup:group];
}

- (void)deleteChord:(OCChordObj *)chord {
    [myDocument deleteObjectsFromChord:chord];
    [myDocument deleteFromDocumentChord:chord];
}


#pragma mark -
#pragma mark Selection Management
#pragma mark -

/*
 * Returns the topmost object of a given object at the passed location
 * In other words, the object could be part of something larger, and this returns
 * that larger thing
 *
 */

- (OCMusicObj *)getMusicObjAtBeat:(float)beat pitch:(float)pitch {
	//NSLog(@"OCWindowController:getMusicObjAtBeat");
    // get the note the user clicked on
    OCMusicObj *musicObj = [myDocument retrieveNoteAtBeat:beat pitch:pitch];
    if ( ![musicObj isMemberOfClass:[OCResizeTabObj class]] ) {
        // see if the note is part of something larger, like a group or Sequence
        if ( musicObj.parent != nil ) {
            OCMusicObj *parent = [musicObj.parent getTopParent];
            if ( parent ) {
                musicObj = parent;
            }
        }
    }
    return musicObj;
}

/* 
 Selection occurs on MouseDown and behavior changes with the Shift key. Behavior
 is based on object selection behaviors typical of other creative applications.
 
 Normal selection is one object at a time. Selecting a first object, then
 selecting a second object results in the first object being deselected and 
 the second object being selected.
 
 Pressing the Shift key allows multiple objects to be selected at once. So,
 select a first object, press the Shift key, then select a second object to
 have them both selected at the same time. 
 
 If the Shift key is pressed and no object is selected, the already-existing
 selection remains untouched. Otherwise if the Shift key is let go and no object
 is selected, then the selection, regardless of size, is cleared.
 
 */

- (OCMouseMode) selectNoteAtBeat:(float)beat pitch:(float)pitch modifier:(int)modifier {
    //NSLog(@"OCWindowController:selectNoteAtBeat");
	// generic music object variable because a note could be part of something
	// larger
    OCMusicObj *musicObj = [self getMusicObjAtBeat:beat pitch:pitch];
	
	// if no note was selected and the shift key isn't pressed, 
	// clear the selection...
	if ( !musicObj && modifier != NSShiftKeyMask ) {
		[self selectNone:nil];
	}
	
	// ...but don't do anything else, either.
	if ( !musicObj ) {
		return kOCDragSelectMode;
	}
	
	// the actual object has been sorted out, so now we actually do something 
	// with it based on what we it and the mode we are in.
    if ( ![musicObj isMemberOfClass:[OCResizeTabObj class]] ) {
        if ( modifier == NSShiftKeyMask ) {
            if ( musicObj.selected ) {
                [self removeMusicObjFromSelection:musicObj];
            } else {
                [self addMusicObjToSelection:musicObj];
            }
        } else {
            [self selectNone:nil];
            [self addMusicObjToSelection:musicObj];
        }
    } else {
        return kOCResizeMode;
    }
        
    [self updateViews];
    
    return kOCNoMode;
}

#pragma mark Object Selection Routing

- (void) addMusicObjToSelection:(OCMusicObj *)musicObj {
    //NSLog(@"OCWindowController:addMusicObjToSelection");
    // we use isMemberOfClass because object addition of any type needs to be 
    // carefully handled.
	
	if ( [musicObj isMemberOfClass:[OCNoteObj class]] ) {
		OCNoteObj *note = (OCNoteObj *)musicObj;
		[self addNoteToSelection:note];
	}
    
    if ( [musicObj isMemberOfClass:[OCChordObj class]] ) {
		OCChordObj *chord = (OCChordObj *)musicObj;
		[self addChordToSelection:chord];
	}
	
	if ( [musicObj isMemberOfClass:[OCGroupObj class]] ) {
		OCGroupObj *group = (OCGroupObj *)musicObj;
		[self addGroupToSelection:group];
	}
    
    if ( [musicObj isMemberOfClass:[OCSequenceObj class]] ) {
		OCSequenceObj *sequence = (OCSequenceObj *)musicObj;
		[self addSequenceToSelection:sequence];
	}
}

- (void) removeMusicObjFromSelection:(OCMusicObj *)musicObj {
    //NSLog(@"OCWindowController:removeMusicObjFromSelection");
    // we use isMemberOfClass because object removal of any type needs to be 
    // carefully handled.
	
	if ( [musicObj isMemberOfClass:[OCNoteObj class]] ) {
		OCNoteObj *note = (OCNoteObj *)musicObj;
		[self removeNoteFromSelection:note];
	}
    
    if ( [musicObj isMemberOfClass:[OCChordObj class]] ) {
		OCChordObj *chord = (OCChordObj *)musicObj;
		[self removeChordFromSelection:chord];
	}
	
	if ( [musicObj isMemberOfClass:[OCGroupObj class]] ) {
		OCGroupObj *group = (OCGroupObj *)musicObj;
		[self removeGroupFromSelection:group];
	}
    
    if ( [musicObj isMemberOfClass:[OCSequenceObj class]] ) {
		OCSequenceObj *sequence = (OCSequenceObj *)musicObj;
		[self removeSequenceFromSelection:sequence];
	}

}

#pragma mark Note Selection Management

- (void) addNoteToSelection:(OCNoteObj *)note {
    note.oldStartBeat = note.startBeat;
    note.oldPitch = note.pitch;
    note.selected = YES;
    [selection addObject:note];
}

- (void) removeNoteFromSelection:(OCNoteObj *)note {
    note.selected = NO;
    [selection removeObject:note];
}

#pragma mark Group Selection Management

- (void) addGroupToSelection:(OCGroupObj *)group {
	[group select:YES];
	[selection addObject:group];
}

- (void) removeGroupFromSelection:(OCGroupObj *)group {
	[group select:NO];
	[selection removeObject:group];
}

#pragma mark Chord Selection Management

- (void) addChordToSelection:(OCChordObj *)chord {
	[chord select:YES];
	[selection addObject:chord];
}

- (void) removeChordFromSelection:(OCChordObj *)chord {
	[chord select:NO];
	[selection removeObject:chord];
}

#pragma mark Sequence Selection Management

- (void) addSequenceToSelection:(OCSequenceObj *)sequence {
	[sequence select:YES];
	[selection addObject:sequence];
}

- (void) removeSequenceFromSelection:(OCSequenceObj *)sequence {
	[sequence select:NO];
	[selection removeObject:sequence];
}

#pragma mark Absolute Selection Management

- (IBAction) selectAll:(id)sender {
    for ( OCSequenceObj *sequence in myDocument.sequences ) {
        [self addSequenceToSelection:sequence];
    }
    for ( OCGroupObj *group in myDocument.groups ) {
        [self addGroupToSelection:group];
    }
    for ( OCChordObj *chord in myDocument.chords ) {
        [self addChordToSelection:chord];
    }
	for ( OCNoteObj *note in myDocument.notes ) {
        [self addNoteToSelection:note];
    }
    
	[self updateViews];
}

- (IBAction) selectNone:(id)sender {
    for ( OCSequenceObj *sequence in myDocument.sequences ) {
        [self removeSequenceFromSelection:sequence];
    }
	for ( OCGroupObj *group in myDocument.groups ) {
        [self removeGroupFromSelection:group];
    }
    for ( OCChordObj *chord in myDocument.chords ) {
        [self removeChordFromSelection:chord];
    }
    for ( OCNoteObj *note in myDocument.notes ) {
        [self removeNoteFromSelection:note];
    }
	[self updateViews];
}

#pragma mark -
#pragma mark Editing Management
#pragma mark -

- (IBAction)setEditMode:(id)sender {
	int selectedSegment = [sender selectedSegment];
	switch (selectedSegment) {
		case 0:
			editorMode = kAddMode;
			break;
		case 1:
			editorMode = kEditMode;
			break;
		case 2:
			editorMode = kDeleteMode;
			break;				
		default:
			editorMode = kEditMode;
			break;
	}
}

#pragma mark -
#pragma mark Play Management
#pragma mark -

- (IBAction)playNotes:(id)sender {
	[playController playNotes];
}

- (IBAction)stopNotes:(id)sender {
	[playController stopNotes];
}

#pragma mark -
#pragma mark Dummy Content Creation
#pragma mark -

- (IBAction) createLinearSample:(id)selector {
	
	int noteCount = [[myDocument notes] count];
	
	int firstNote = 1 + noteCount;
	int thisNote = firstNote;
	int lastNote = 21 + noteCount;
	for (thisNote = firstNote; thisNote <= lastNote; thisNote++) {
		float startBeat = (float)(kOCView_DefaultNoteLength * thisNote);
		float pitch = (float)(50 + thisNote);
		float length = (float)kOCView_DefaultNoteLength;
		
		OCNoteObj *note = [myDocument createNoteAtStartBeat:startBeat pitch:pitch length:length];
		
		if ( !note ) {
			// Fail silently
		}
	}
    
    // mimic some user actions
    // forwards selection
    
    // two groups next to each other grouped together
    
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:0 + noteCount]];
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:1 + noteCount]];
    [self groupSelection:nil];
    [self selectNone:nil];
    
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:2 + noteCount]];
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:3 + noteCount]];
    [self groupSelection:nil];
    [self selectNone:nil];
    
    [self addMusicObjToSelection:[myDocument.groups objectAtIndex:0 + noteCount]];
    [self addMusicObjToSelection:[myDocument.groups objectAtIndex:1 + noteCount]];
    [self groupSelection:nil];
    [self selectNone:nil];
    
    // two groups not next to each other grouped together
    
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:4 + noteCount]];
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:5 + noteCount]];
    [self groupSelection:nil];
    [self selectNone:nil];
    
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:7 + noteCount]];
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:8 + noteCount]];
    [self groupSelection:nil];
    [self selectNone:nil];
    
    [self addMusicObjToSelection:[myDocument.groups objectAtIndex:3 + noteCount]];
    [self addMusicObjToSelection:[myDocument.groups objectAtIndex:4 + noteCount]];
    [self groupSelection:nil];
    [self selectNone:nil];
    
    // group and note grouped together
    
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:6 + noteCount]];
    [self addMusicObjToSelection:[myDocument.groups objectAtIndex:5 + noteCount]];
    [self groupSelection:nil];
	
	[self updateViews];
	
}

- (IBAction) createOdeToJoySample:(id)selector {
	int noteCount = 62;
	int beats[] = {0, 24, 48, 72, 96, 120, 144, 168, 192, 216, 240, 264, 288, 324, 336, 384, 408, 432, 456, 480, 504, 528, 552, 576, 600, 624, 648, 672, 708, 720, 768, 792, 816, 840, 864, 888, 900, 912, 936, 960, 984, 996, 1008, 1032, 1056, 1080, 1104, 1152, 1176, 1200, 1224, 1248, 1272, 1296, 1320, 1344, 1368, 1392, 1416, 1440, 1476, 1488};
	int pitches[] = {64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62, 64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 62, 60, 60, 62, 62, 64, 60, 62, 64, 65, 64, 60, 62, 64, 65, 64, 62, 60, 62, 55, 64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 62, 60, 60};
	int lengths[] = {kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08 + kNoteLength_16, kNoteLength_16, kNoteLength_04, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08 + kNoteLength_16, kNoteLength_16, kNoteLength_04, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_16, kNoteLength_16, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_16, kNoteLength_16, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_04, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08, kNoteLength_08 + kNoteLength_16, kNoteLength_16, kNoteLength_04};
	
	for ( int n = 0 ; n < noteCount; n++) {
		OCNoteObj *note = [myDocument createNoteAtStartBeat:beats[n] * 2 pitch:pitches[n] length:lengths[n]];
		if ( !note ) {
			// fail silently
		}
			
	}
	
	[self updateViews];
}

- (IBAction) createBasicRandomMelody:(id)selector {
	
	// get a starting pitch
	int rootPitchArray[] = {60, 62, 64, 65, 67, 69, 71}; // middle c
	int rootPitchBound = 6;
	int lastPitch = rootPitchArray[[self randomInRangeMin:0 max:rootPitchBound]];
	
	// get a length at random (eventually)
	int lengthArray[] = {kNoteLength_04, kNoteLength_08, kNoteLength_16, kNoteLength_32};
	int lengthBound = 3;

	int currentBeat = 0;
	
	int minOffset = 1;
	int maxOffset = 3; // typical chord interval
	int upKey = 2;
	
	int noteCount = 24; // 18 minimum because other methods use this for creating test content
	
	// creates notes by figuring out the interval and direction from the previous 
	// note. This keeps everything sounding at least melodic if a bit haphazard
	
	for ( int n = 0 ; n < noteCount ; n++ ) {	
		int offset = [self randomInRangeMin:minOffset max:maxOffset];
		int dirKey = [self randomInRangeMin:1 max:10]; // MAGIC NUMBERS, but that's okay here
		int hitCount = 0;
		do {
			if ( dirKey % upKey == 0 ) {
				lastPitch++;
			} else {
				lastPitch--;
			}
			if ( [[self key] isPitchInKey:lastPitch] ) {
				hitCount++;
			}
		} while ( hitCount < offset );
		
		int length = lengthArray[[self randomInRangeMin:0 max:lengthBound]];
		
		OCNoteObj *note = [myDocument createNoteAtStartBeat:currentBeat pitch:lastPitch length:length];
		if ( !note ) {
			// fail silently
		}
		currentBeat += length;
	}
	
	[self updateViews];
	
}

/*
 * Generates a random melody of notes, then creates a set variety objects with that
 * melody.
 */

- (IBAction) createObjectBuffet:(id)selector {
	
	[self createBasicRandomMelody:nil];
	
	// set some default chord settings just to get stuff made
	selectedChordType = 0; // major
	selectedSeventhExtension = 0; // no selection
	selectedSeventhExtensionModifier = 0; // major
	selectedChordModifer = 0; // none
	
	// GROUP COMBOS
	// simple group
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:1]];
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:2]];
    [self groupSelection:nil]; // group 0
    [self selectNone:nil];

	// simple group with note
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:3]];
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:4]];
    [self groupSelection:nil]; // group 1
    [self selectNone:nil];
	[self addMusicObjToSelection:[myDocument.groups objectAtIndex:1]];
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:5]];
	[self groupSelection:nil]; // group 2
	[self selectNone:nil];
	
	// group with chord
	// make the group
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:6]];
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:7]];
    [self groupSelection:nil]; // group 3
    [self selectNone:nil];
	// make the chord
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:8]];
	[self createChordsWithSelection:nil]; // chord 0
	[self selectNone:nil];
	// select the group and the chord and group them
	[self addMusicObjToSelection:[myDocument.groups objectAtIndex:3]];
	[self addMusicObjToSelection:[myDocument.chords objectAtIndex:0]];
	[self groupSelection:nil]; // group 4
    [self selectNone:nil];
	
	// group with chord and note
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:9]];
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:10]];
    [self groupSelection:nil]; // group 5
    [self selectNone:nil];
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:11]];
	[self createChordsWithSelection:nil]; // chord 1
	[self selectNone:nil];
	[self addMusicObjToSelection:[myDocument.groups objectAtIndex:5]];
	[self addMusicObjToSelection:[myDocument.chords objectAtIndex:1]];
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:12]];
	[self groupSelection:nil]; // group 6
    [self selectNone:nil];
	
	
	// SEQUENCER COMBOS
	// simple notes
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:13]];
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:14]];
    [self  makeSequenceWithSelection:nil]; // sequence 0
    [self selectNone:nil];
	
	// nested groups with chord and note
	// make the group
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:15]];
    [self addMusicObjToSelection:[myDocument.notes objectAtIndex:16]];
    [self groupSelection:nil]; // group 7
    [self selectNone:nil];
	// make the chord
	[self addMusicObjToSelection:[myDocument.notes objectAtIndex:17]];
	[self createChordsWithSelection:nil]; // chord 2
	[self selectNone:nil];
	// select the group and the chord and sequence them
	[self addMusicObjToSelection:[myDocument.groups objectAtIndex:7]];
	[self addMusicObjToSelection:[myDocument.chords objectAtIndex:2]];
	[self makeSequenceWithSelection:nil]; // group 8
    [self selectNone:nil];
	
	[self updateViews];
}

- (int) randomInRangeMin:(int)min max:(int)max {
	return ( arc4random() % abs( max - min ) ) + min;
}

@end
