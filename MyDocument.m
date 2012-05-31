//
//  MyDocument.m
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

#import "MyDocument.h"

#import "OCMusicObj.h"
#import "OCNoteObj.h"
#import "OCGroupObj.h"
#import "OCChordObj.h"
#import "OCSequenceObj.h"
#import "OCResizeTabObj.h"

#import "OCConstantsLib.h"
#import "OCWindowController.h"

#import "OCMusicPieceObj.h"

@implementation MyDocument

#pragma mark -
#pragma mark Properties
#pragma mark -

@synthesize defaultColor;
@synthesize editorArea;

@synthesize zoomXIndex;
@synthesize zoomYIndex;

@synthesize notes;
@synthesize groups;
@synthesize chords;
@synthesize sequences;
@synthesize resizeTabs;
@synthesize musicPiece;

@synthesize snapToIndex;
@synthesize newNoteindex;

#pragma mark -
#pragma mark Class Methods
#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
        
        // set up some basic values to start things off so we dodge any obvious errors
		
		self.defaultColor = [NSColor orangeColor];
		
		zoomXIndex = [OCConstantsLib sharedLib].kOCView_zoomIndex_100;
        zoomYIndex = [OCConstantsLib sharedLib].kOCView_zoomIndex_100;
		
        self.notes = [NSMutableArray array];
		self.groups = [NSMutableArray array];
        self.chords = [NSMutableArray array];
        self.sequences = [NSMutableArray array];
        self.resizeTabs = [NSMutableArray array];
        
        self.musicPiece = [[OCMusicPieceObj alloc] init];
		[self.musicPiece.key calculatePitches];
		
		// this sets up 4/4 time to start with
		timeSignatureBeatsPerMeasure = 4;
		timeSignatureBasicBeatIndex = 2; // [0]:1, [1]:2, [2]:4, [3]:8, [4]:16, [5]:32, [6]:64
		
		snapToIndex = 2;
		newNoteindex = 2;
				
		float editorX = 0.0f;
		float editorY = 0.0f;
		
		// set the default size of the editor area
		NSNumber *timeSigBasicBeatMIDILength = [[OCConstantsLib sharedLib].kOCData_TimeSignatureBeatMIDILengths objectAtIndex:timeSignatureBasicBeatIndex];
		int timeSigBasicBeatMIDILengthValue = [timeSigBasicBeatMIDILength intValue];
		float editorWidth = timeSigBasicBeatMIDILengthValue * timeSignatureBeatsPerMeasure * kOCModel_DefaultNumberOfMeasures;
		
		float editorHeight = (float)kOCMIDI_StandardNoteCount * kOCView_CoreKeyHeight;
		
		defaultEditorArea = NSMakeRect(editorX, editorY, editorWidth, editorHeight);
		self.editorArea = defaultEditorArea;

    }
    return self;
}

- (void) dealloc
{
	[defaultColor release];
	[notes release];
	[groups release];
    [sequences release];
    [resizeTabs release];
	[musicPiece release];
	[super dealloc];
}

- (void)makeWindowControllers {
	OCWindowController *windowController = [[OCWindowController alloc] initWithWindowNibName:@"MyDocument"];
	[self addWindowController:windowController];
	windowController.myDocument = self;
	
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

#pragma mark -
#pragma mark Calculated Properties (Property Accessors)
#pragma mark -

/*
 These methods assist drawing the piano roll backgroud. Any change to these causes
 a complete redraw of the interface
 */

- (void) setTimeSignatureBeatsPerMeasure:(int)beatsPerMeasure {
	timeSignatureBeatsPerMeasure = beatsPerMeasure;
	[self calculateEditorArea];
}

- (int) timeSignatureBeatsPerMeasure {
	return timeSignatureBeatsPerMeasure;
}

- (void) setTimeSignatureBasicBeatIndex:(int)basicBeatIndex {
	timeSignatureBasicBeatIndex = basicBeatIndex;
	[self calculateEditorArea];
}

- (int) timeSignatureBasicBeatIndex {
	return timeSignatureBasicBeatIndex;
}

- (void) calculateEditorArea {
	
	float x = 0.0f;
	float y = 0.0f;
	
	float tsBPM = (float)timeSignatureBeatsPerMeasure;
	NSNumber *tsBML = [[OCConstantsLib sharedLib].kOCData_TimeSignatureBeatMIDILengths objectAtIndex:timeSignatureBasicBeatIndex];
	int tsBMLV = [tsBML floatValue];
	float w = tsBPM * tsBMLV * kOCModel_DefaultNumberOfMeasures;
	
	float h = kOCView_CoreKeyHeight * kOCMIDI_StandardNoteCount;
	
	editorArea = NSMakeRect(x, y, w, h);
	
}

#pragma mark -
#pragma mark NoteObj Management
#pragma mark -

/*
 Creates and returns a note object with the passed criteria.
 */

- (OCNoteObj *)createNoteAtStartBeat:(float)theStartBeat pitch:(float)thePitch length:(float)theLength {
	OCNoteObj *newNote = [[OCNoteObj alloc] init];
	[notes addObject:newNote];

	newNote.startBeat = theStartBeat;
	newNote.pitch = thePitch;
	newNote.length = theLength;
    newNote.objectID = [[OCConstantsLib sharedLib] currentID];
    
    newNote.resizeTab = [self createResizeTab];
    newNote.resizeTab.parent = newNote;
    
	return newNote;
}

- (BOOL) resizeTabHitForNote:(OCNoteObj *)note atBeat:(float)beat pitch:(float)pitch {
	//NSLog(@"resizeTabHitForNote:");
    // we are looking to within kNoteLength_16 of the sequence
    // get the dimensions of the sequence first, then check the tab location
    NSRect rect = [note dimensions];
    
    float x = rect.origin.x + rect.size.width;
    float y = rect.origin.y;
    float w = kNoteLength_16;
    float h = rect.origin.y;
    
    NSRect tabRect = NSMakeRect(x, y, w, h);
    NSPoint hitPoint = NSMakePoint(beat, pitch);
        
    // we can't use NSPointInRect(point, rect) because it does not handle heights of 0; we need to explicity
    // check for the pitch itself
    
    if (( hitPoint.x >= tabRect.origin.x ) && 
        ( hitPoint.x <= tabRect.origin.x + tabRect.size.width ) && 
        ( hitPoint.y >= tabRect.origin.y ) &&
        ( hitPoint.y <= tabRect.origin.y ) ) {
        return YES;
    }
    
    return NO;
    
}


/*
 * Returns the first note that meets the given criteria
 *
 * Resizing is a special case since we don't want to change the selection. We just
 * want to allow the user to take the given selection and be able to drag so that
 * they can resize accordingly. In this case, the resizeTab is used as a flag of 
 * sorts that is passed through the system to tell it we are in resize mode.
 */

- (OCMusicObj *) retrieveNoteAtBeat:(float)beat pitch:(float)pitch {
    //NSLog(@"MyDocument:retrieveNoteAtBeat:");
    // check for resize tabs first on all grouping objects that have them.
    
    for ( OCSequenceObj *sequence in sequences ) {
        if ( [self resizeTabHitForSequence:sequence atBeat:beat pitch:pitch] ) {
            return sequence.resizeTab;
        }
    }
    
    // if no group obj resize tabs, then go on to notes
    
	for (OCNoteObj *note in notes) {
		
		// check for resize tabs first since there may already be a selection we
		// don't want to muck with
		
		if ( [self resizeTabHitForNote:note atBeat:beat pitch:pitch] ) {
            return note.resizeTab;
        }
        		
		// this calculation parallels what is in resizeTabHitForSequence
		
		NSRect dim = [note dimensions];
		NSPoint hit = NSMakePoint(beat, pitch);
		
		if ( [self isPoint:hit inRect:dim] ) {
			return note;
		}
	}
	return nil;
}

- (void) deleteFromDocumentNote:(OCNoteObj *)note {
	
	[notes removeObject:note];
	//[note release];
		
}

#pragma mark -
#pragma mark GroupObj Management
#pragma mark -

/*
 Creates and returns an empty group object. Any intended child objects are managed
 in the window controller
 */

- (OCGroupObj *)createGroup {
	OCGroupObj *group = [[OCGroupObj alloc] init];
    group.objectID = [[OCConstantsLib sharedLib] currentID];
	[groups addObject:group];
	return group;
}

/*
 * Shallow deletion of a group from the document
 * used primarily with ungrouping
 */

- (void) deleteFromDocumentGroup:(OCGroupObj *)group {
	
    [groups removeObject:group];
	//[group release];

}

/*
 * Deep deletion of a group from the document
 * used primarily with deleting
 */

- (void) deleteObjectsFromGroup:(OCGroupObj *)group {
    
    int objectsCount = [group.objects count];
    for ( int i = objectsCount - 1 ; i >= 0 ; i-- ) {
        OCMusicObj *musicObj = [group.objects objectAtIndex:i];
        
        // we use isMemberOfClass because we need to be very specific about how
		// we handle deletions
        
        if ( [musicObj isMemberOfClass:[OCGroupObj class]] ) {
            OCGroupObj *childGroup = (OCGroupObj *)musicObj;
            [group removeObject:childGroup];
            [self deleteObjectsFromGroup:childGroup];
            [self deleteFromDocumentGroup:childGroup];
        }
		
		if ( [musicObj isMemberOfClass:[OCChordObj class]] ) {
            OCChordObj *childChord = (OCChordObj *)musicObj;
            [group removeObject:childChord];
            [self deleteObjectsFromChord:childChord];
            [self deleteFromDocumentChord:childChord];
        }
		
		if ( [musicObj isMemberOfClass:[OCNoteObj class]] ) {
            OCNoteObj *note = (OCNoteObj *)musicObj;
            [group removeObject:note];
            [self deleteFromDocumentNote:note];
        }
    }
}

#pragma mark -
#pragma mark ChordObj Management
#pragma mark -

/*
 Creates and returns an empty chord object. Any intended child objects are managed
 in the window controller
 */

- (OCChordObj *)createChord {
    OCChordObj *chord = [[OCChordObj alloc] init];
    chord.objectID = [[OCConstantsLib sharedLib] currentID];
    [chords addObject:chord];
    return chord;
}

/*
 Shallow deletion of a chord object
 */

- (void) deleteFromDocumentChord:(OCChordObj *)chord {
    [chords removeObject:chord];
	//[chord release];

}

/*
 Deep deletion of a chord and all of its child objects
 */

- (void) deleteObjectsFromChord:(OCChordObj *)chord {
    
    int objectsCount = [chord.objects count];
    for ( int i = objectsCount - 1 ; i >= 0 ; i-- ) {
        OCMusicObj *musicObj = [chord.objects objectAtIndex:i];
		
        // we use isMemberOfClass because we need to be very specific about how
		// we handle deletions, and we don't know if or when the class will be updated
		// to handle anything other than just notes.
		
        if ( [musicObj isMemberOfClass:[OCNoteObj class]] ) {
            OCNoteObj *note = (OCNoteObj *)musicObj;
            [chord removeObject:note];
            [self deleteFromDocumentNote:note];
        }
    }
}

#pragma mark -
#pragma mark SequenceObj Management
#pragma mark -

/*
 Creates and returns a sequence object. This creates and links the needed objects 
 for its management, but any child, playable objects are managed in WindowController.
 */

- (OCSequenceObj *)createSequence {
    OCSequenceObj *s = [[OCSequenceObj alloc] init];
    s.objectID = [[OCConstantsLib sharedLib] currentID];
    s.resizeTab = [self createResizeTab];
    s.myDocument = self;
    s.root = [self createGroup];
    s.root.parent = s;
    s.sequence = [self createGroup];
    s.sequence.parent = s;
    [sequences addObject:s];
    return s;
}

/*
 Shallow deletion of a sequence object
 */

- (void) deleteFromDocumentSequence:(OCSequenceObj *)sequence {
    [sequences removeObject:sequence];
    [sequence release];
}

/*
 Deep deletion of a sequence object
 */

- (void) deleteObjectsFromSequence:(OCSequenceObj *)sequence {
    [self deleteObjectsFromGroup:sequence.root];
    [self deleteObjectsFromGroup:sequence.sequence];
}

#pragma mark -
#pragma mark ResizeTabObj Management
#pragma mark -

/*
 Creates and returns a resize tab
 */

- (OCResizeTabObj *) createResizeTab {
    OCResizeTabObj *resizeTab = [[OCResizeTabObj alloc] init];
    resizeTab.objectID = [[OCConstantsLib sharedLib] currentID];
    [resizeTabs addObject:resizeTab];
    return resizeTab;
}

/*
 Deletes a resize tab from the document.
 */

- (void) deleteFromDocumentResizeTabObj:(OCResizeTabObj *)resizeTab {
    [resizeTabs removeObject:resizeTab];
    [resizeTab release];
}

/*
 * calculate if the passed beat/pitch are within the resize tab for a sequence
 */

- (BOOL) resizeTabHitForSequence:(OCSequenceObj *)sequence atBeat:(float)beat pitch:(float)pitch {
    // we are looking to within kNoteLength_16 of the sequence
    // get the dimensions of the sequence first, then check the tab location
    NSRect rect = [sequence dimensions];
    
    float x = rect.origin.x + rect.size.width;
    float y = rect.origin.y;
    float w = kNoteLength_16;
    float h = rect.size.height;
    
    NSRect tabRect = NSMakeRect(x, y, w, h);
    NSPoint hitPoint = NSMakePoint(beat, pitch);

    return [self isPoint:hitPoint inRect:tabRect];    
}

/*
 * Calculates if a given point is within a given rect. We do not use NSPointInRect
 * because we are working in beats and pitches, and not standard coordinates.
 */

- (BOOL) isPoint:(NSPoint)point inRect:(NSRect)rect {
	//[self logPoint:point andRect:rect];
	if ( rect.size.height > 1.0 ) {
		if (( point.x >= rect.origin.x ) && 
			( point.x <= rect.origin.x + rect.size.width ) && 
			( point.y >= rect.origin.y ) &&
			( point.y <= rect.origin.y + rect.size.height ) ) {
			return YES;
		}
	} else {
		if (( point.x >= rect.origin.x ) && 
			( point.x <= rect.origin.x + rect.size.width ) && 
			( point.y >= rect.origin.y ) &&
			( point.y <= rect.origin.y ) ) {
			return YES;
		}
	}
	return NO;
}

/*
 * Prints out the math for a point within a rect. For troubleshooting purposes only
 */

- (void) logPoint:(NSPoint)point andRect:(NSRect)rect {
	//NSLog(@"{x:%.0f, y:%.0f}, {x:%.0f, y:%.0f, w:%.0f, h:%.0f}", point.x, point.y, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	if ( rect.size.height > 1.0 ) {
		NSLog(@"%.0f >= %.0f && %.0f <= %.0f && %.0f >= %.0f && %.0f <= %.0f", point.x, rect.origin.x, point.x, rect.origin.x + rect.size.width, point.y, rect.origin.y, point.y, rect.origin.y + rect.size.height);
	} else {
		NSLog(@"%.0f >= %.0f && %.0f <= %.0f && %.0f >= %.0f && %.0f <= %.0f", point.x, rect.origin.x, point.x, rect.origin.x + rect.size.width, point.y, rect.origin.y, point.y, rect.origin.y);
	}
}

@end
