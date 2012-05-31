//
//  MyDocument.h
//  OCDocumentFramework
//
//  Created by Philip Regan on 2/19/10.
//  Copyright __MyCompanyName__ 2010 . All rights reserved.
//

/*
 * MyDocument is the Model/Controller for the application.
 * All core data objects are held here, and handles interaction between the document
 * and the operating system including the menu system
 */

#import <Cocoa/Cocoa.h>
#import "OCConstants.h"

@class OCConstantsLib;
@class OCWindowController;

@class OCMusicObj;
@class OCNoteObj;
@class OCGroupObj;
@class OCChordObj;
@class OCSequenceObj;
@class OCResizeTabObj;
@class OCMusicPieceObj;

@interface MyDocument : NSDocument
{
	
	NSColor *defaultColor;
	NSRect defaultEditorArea;
	NSRect editorArea;
	
	int zoomXIndex;
	int zoomYIndex;
	
	NSMutableArray *notes;
	NSMutableArray *groups;
    NSMutableArray *chords;
    NSMutableArray *sequences;
    NSMutableArray *resizeTabs;
    
    OCMusicPieceObj *musicPiece;
	
	int timeSignatureBeatsPerMeasure;
	int timeSignatureBasicBeatIndex;
	
    // this is the level of granularity an edit is to fall into
	int snapToIndex;
    // this is the length of any new notes
	int newNoteindex;
			
}

@property (nonatomic, retain) NSColor *defaultColor;
@property (nonatomic) NSRect editorArea;

@property (nonatomic) int zoomXIndex;
@property (nonatomic) int zoomYIndex;

@property (nonatomic, retain) NSMutableArray *notes;
@property (nonatomic, retain) NSMutableArray *groups;
@property (nonatomic, retain) NSMutableArray *chords;
@property (nonatomic, retain) NSMutableArray *sequences;
@property (nonatomic, retain) NSMutableArray *resizeTabs;

@property (nonatomic, retain) OCMusicPieceObj *musicPiece;

@property (nonatomic) int snapToIndex;
@property (nonatomic) int newNoteindex;

#pragma mark -
#pragma mark Calculated Properties (Property Accessors)
#pragma mark -

- (void) setTimeSignatureBeatsPerMeasure:(int)beatsPerMeasure;
- (int) timeSignatureBeatsPerMeasure;

- (void) setTimeSignatureBasicBeatIndex:(int)basicBeatIndex;
- (int) timeSignatureBasicBeatIndex;

- (void) calculateEditorArea;

#pragma mark -
#pragma mark NoteObj Management
#pragma mark -

/*
 * CRUD-like paradigm for managing notes at this level* 
 *
 * Any higher-level interaction and updates happens in the WindowController.
 */

- (OCNoteObj *) createNoteAtStartBeat:(float)theStartBeat pitch:(float)thePitch length:(float)theLength;
- (OCMusicObj *) retrieveNoteAtBeat:(float)beat pitch:(float)pitch;
- (void) deleteFromDocumentNote:(OCNoteObj *)note;
- (BOOL) resizeTabHitForNote:(OCNoteObj *)note atBeat:(float)beat pitch:(float)pitch;

#pragma mark -
#pragma mark GroupObj Management
#pragma mark -

- (OCGroupObj *)createGroup;
- (void) deleteFromDocumentGroup:(OCGroupObj *)group;
- (void) deleteObjectsFromGroup:(OCGroupObj *)group;

#pragma mark -
#pragma mark ChordObj Management
#pragma mark -

- (OCChordObj *)createChord;
- (void) deleteFromDocumentChord:(OCChordObj *)chord;
- (void) deleteObjectsFromChord:(OCChordObj *)chord;

#pragma mark -
#pragma mark SequenceObj Management
#pragma mark -

- (OCSequenceObj *)createSequence;
- (void) deleteFromDocumentSequence:(OCSequenceObj *)sequence;
- (void) deleteObjectsFromSequence:(OCSequenceObj *)sequence;

#pragma mark -
#pragma mark ResizeTabObj Management
#pragma mark -

- (OCResizeTabObj *)createResizeTab;
- (void) deleteFromDocumentResizeTabObj:(OCResizeTabObj *)resizeTab;

- (BOOL) resizeTabHitForSequence:(OCSequenceObj *)sequence atBeat:(float)beat pitch:(float)pitch;

- (BOOL) isPoint:(NSPoint)point inRect:(NSRect)rect;
- (void) logPoint:(NSPoint)point andRect:(NSRect)rect;
@end
