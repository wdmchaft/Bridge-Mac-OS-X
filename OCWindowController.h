//
//  OCWindowController.h
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

#import <Cocoa/Cocoa.h>
#import "OCConstants.h"

@class OCView;
@class OCScrollView;

@class OCRulerView;
@class OCKeyRollView;

@class MyDocument;

@class OCConstantsLib;

@class OCMusicObj;
@class OCNoteObj;
@class OCGroupObj;
@class OCChordObj;
@class OCSequenceObj;
@class OCResizeTabObj;
@class OCMusicPieceObj;

@class OCSelectKeyWindowController;
@class OCKeyObj;

@class OCSelectChordWindowController;

@class OCPlayController;

@interface OCWindowController : NSWindowController {

    /* Interface Management */
    
	IBOutlet OCView *linkedView;
	NSSegmentedControl *EditModeSelector;
	NSSegmentedControl *defaultLengthSelector;
	OCScrollView *scrollView;
	
	IBOutlet OCRulerView *rulerView;
	IBOutlet OCKeyRollView *keyRollView;
	
	IBOutlet NSButton *increaseZoomXButton;
	IBOutlet NSButton *decreaseZoomXButton;
	IBOutlet NSButton *increaseZoomYButton;
	IBOutlet NSButton *decreaseZoomYButton;
	
	IBOutlet NSStepper *timeSignatureBeatsPerMeasureStepper;
	IBOutlet NSTextField *timeSignatureBeatsPerMeasureField;
	IBOutlet NSStepper *timeSignatureBasicBeatStepper;
	IBOutlet NSTextField *timeSignatureBasicBeatField;
	
	/* Music Playing Management */
	OCPlayController *playController;
    
    /* Window Management */
    
    /* The main window MyDocument is already set to the 'window' property */
    
    IBOutlet NSWindow *selectKeySheet;
    IBOutlet OCSelectKeyWindowController *selectKeyWindowController;
	
	IBOutlet NSWindow *selectChordSheet;
	IBOutlet OCSelectChordWindowController *selectChordWindowController;

	MyDocument *myDocument;
	
	NSRect masterEditorArea;
	NSRect zoomedMasterEditorArea;
	
	float originalScrollViewHeight;
	float lastScrollViewHeight;
	float currentScrollViewHeight;
    
	/* Zoom Management */
    
	int zoomXIndex;
	int zoomYIndex;
	
    /* Control Management */
    
	int timeSignatureBeatsPerMeasure;
	int timeSignatureBasicBeatIndex;
	
	float defaultLength;
	float snapToValue;
    
    /* Select Key Management */
    
    int selectedKeyType;
    int selectedKeyTonic;
	
	/* Select Chord Management */
	
	int selectedChordType;
	int selectedSeventhExtension;
	int selectedSeventhExtensionModifier;
	int selectedChordModifer;
    
    enum EditorMode editorMode;
    
    /* Selection Management */
	
	NSMutableArray *selection;
    
    
	NSButton *stopNotes;
}

@property (nonatomic, retain) IBOutlet OCView *linkedView;
@property (assign) IBOutlet NSSegmentedControl *EditModeSelector;
@property (assign) IBOutlet NSSegmentedControl *defaultLengthSelector;

@property (assign) IBOutlet NSWindow *selectKeySheet;
@property (assign) IBOutlet NSWindow *selectChordSheet;

@property (nonatomic, retain) MyDocument *myDocument;

@property (nonatomic) int zoomXIndex;
@property (nonatomic) int zoomYIndex;

@property (readwrite) enum EditorMode editorMode;

@property (readwrite) int timeSignatureBasicBeatIndex;

#pragma mark -
#pragma mark Zoom Management
#pragma mark -

- (NSRect) refactorRectToCurrentZoom:(NSRect)aRect;
- (NSRect) defactorRectAtCurrentZoom:(NSRect)aRect;

- (IBAction) increaseZoomX:(id)sender;
- (IBAction) decreaseZoomX:(id)sender;
- (IBAction) increaseZoomY:(id)sender;
- (IBAction) decreaseZoomY:(id)sender;

#pragma mark -
#pragma mark Control Management
#pragma mark -

- (IBAction) updateNewNoteValue:(id)sender;
- (IBAction) updateSnapToValue:(id)sender;

- (IBAction) updateTimeSignatureBeatsPerMeasure:(id)sender;
- (IBAction) updateTimeSignatureBasicBeat:(id)sender;

#pragma mark -
#pragma mark Menu Management
#pragma mark -

- (IBAction) groupSelection:(id)sender;
- (IBAction) ungroupSelection:(id)sender;
- (IBAction)changeKey:(id)sender;
- (IBAction)makeChordsWithSelection:(id)sender;
- (IBAction)makeSequenceWithSelection:(id)sender;

#pragma mark -
#pragma mark Window Management
#pragma mark -

#pragma mark Select Key Window

- (IBAction)setKeyTonic:(id)sender;
- (IBAction)setKeyType:(id)sender;
- (IBAction)keyOkButton:(id)sender;
- (IBAction)keyCancelButton:(id)sender;
- (void)selectKeySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;

#pragma mark Select Chord Window

- (IBAction)setChordType:(id)sender;
- (IBAction)selectExtensionSeventh:(id)sender;
- (IBAction)selectExtensionSeventhModifier:(id)sender;
- (IBAction)selectChordModifier:(id)sender;
- (IBAction)chordOkButton:(id)sender;
- (IBAction)chordCancelButton:(id)sender;
- (void)selectChordSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;

#pragma mark -
#pragma mark Color Management
#pragma mark -

- (NSColor *)defaultColor;

#pragma mark -
#pragma mark State Management
#pragma mark -

- (void) updateViews;
- (void) notifyKeyRollOfInterfaceUpdate;
- (int) timeSignatureBeatsPerMeasure;

#pragma mark -
#pragma mark Object Management (accessors to document)
#pragma mark -

- (NSMutableArray *) notes;
- (NSMutableArray *) groups;
- (NSMutableArray *) chords;
- (NSMutableArray *) sequences;
- (NSMutableArray *) resizeTabs;
- (OCMusicPieceObj *) musicPiece;
- (OCKeyObj *)key;

#pragma mark Object Creation

- (void) createNoteAtBeat:(float)beat pitch:(float)pitch;

- (IBAction)createChordsWithSelection:(id)sender;

#pragma mark Object Movement

- (void) moveSelectionDeltaX:(float)deltaX DeltaY:(float)deltaY;
- (void)moveNote:(OCNoteObj *)note DeltaX:(float)deltaX DeltaY:(float)deltaY;
- (void) moveGroup:(OCGroupObj *)group DeltaX:(float)deltaX DeltaY:(float)deltaY;
- (void) moveChord:(OCChordObj *)chord DeltaX:(float)deltaX DeltaY:(float)deltaY;
- (void)setOldData;

#pragma mark Object Resizing

- (void) changeLengthOfSelectionByDeltaX:(float)deltaX;
- (void) changeLengthOfSequence:(OCSequenceObj *)sequence byDeltaX:(float)deltaX;
- (void) changeLengthOfNote:(OCNoteObj *)note byDeltaX:(float)deltaX;

#pragma mark Object Deletion

- (void) deleteNoteAtBeat:(float)beat pitch:(float)pitch;
- (IBAction) deleteSelection:(id)sender;
- (void)deleteSequence:(OCSequenceObj *)sequence;
- (void)deleteGroup:(OCGroupObj *)group;
- (void)deleteChord:(OCChordObj *)chord;

#pragma mark -
#pragma mark Selection Management
#pragma mark -

/*
 * retrieves the topmost selected object if a note has a parent object
 * can return nil
 */

- (OCMusicObj *)getMusicObjAtBeat:(float)beat pitch:(float)pitch;

/*
 * Core object selection algorithm.
 */

- (OCMouseMode) selectNoteAtBeat:(float)beat pitch:(float)pitch modifier:(int)modifier;

#pragma mark Object Selection Routing

- (void) addMusicObjToSelection:(OCMusicObj *)musicObj;
- (void) removeMusicObjFromSelection:(OCMusicObj *)musicObj;

#pragma mark Note Selection Management

- (void) addNoteToSelection:(OCNoteObj *)note;
- (void) removeNoteFromSelection:(OCNoteObj *)note;

#pragma mark Group Selection Management

- (void) addGroupToSelection:(OCGroupObj *)group;
- (void) removeGroupFromSelection:(OCGroupObj *)group;

#pragma mark Chord Selection Management

- (void) addChordToSelection:(OCChordObj *)chord;
- (void) removeChordFromSelection:(OCChordObj *)chord;

#pragma mark Absolute Selection Management

- (IBAction) selectAll:(id)sender;
- (IBAction) selectNone:(id)sender;

#pragma mark Sequence Selection Management

- (void) addSequenceToSelection:(OCSequenceObj *)sequence;
- (void) removeSequenceFromSelection:(OCSequenceObj *)sequence;

#pragma mark -
#pragma mark Editing Management
#pragma mark -

- (IBAction) setEditMode:(id)sender;

#pragma mark -
#pragma mark Play Management
#pragma mark -

- (IBAction)playNotes:(id)sender;
- (IBAction)stopNotes:(id)sender;

#pragma mark -
#pragma mark Dummy Content Creation
#pragma mark -

- (IBAction) createLinearSample:(id)selector;
- (IBAction) createOdeToJoySample:(id)selector;
- (IBAction) createBasicRandomMelody:(id)selector;
- (IBAction) createObjectBuffet:(id)selector;

- (int) randomInRangeMin:(int)min max:(int)max;

@end
