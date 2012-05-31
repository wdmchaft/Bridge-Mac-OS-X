//
//  OCSequenceObj.m
//  Bridge
//
//  Created by Philip Regan on 2011/12/03.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OCSequenceObj.h"

#import "OCNoteObj.h"
#import "MyDocument.h"
#import "OCResizeTabObj.h"

#define DEFAULT_DIM -1

@implementation OCSequenceObj

@synthesize myDocument;
@synthesize resizeTab;

@synthesize root;
@synthesize sequence;

#pragma mark -
#pragma mark Object Lifecycle Management
#pragma mark -

- (id)init {
    self = [super init];
    if (self) {
        rootNotes = [[NSMutableArray array] retain];
    
    }
    return self;
}


- (void)dealloc {
    [myDocument release];
    [rootNotes release];
    //[super dealloc];
}

#pragma mark -
#pragma mark Root Sequence Management
#pragma mark -

/*
 * Adds a single object to the hierarchy
 */

- (void)addObject:(OCMusicObj *)musicObj {
    [root addObject:musicObj];
    [self updateRootNotes:musicObj];
}

/*
 * Removes a single object to the hierarchy
 */

- (void)removeObject:(OCMusicObj *)musicObj {
    [root removeObject:musicObj];
    [self updateRootNotes:musicObj];
}

/*
 * Adds an array of objects to the group. Syntactic sugar.
 */

- (void) groupObjects:(NSMutableArray *)newObjects {
    // we need to keep this operation here in this class so we can't override
    for ( OCMusicObj *musicObj in newObjects ) {
		[self addObject:musicObj];
	}
    NSRect d = [self dimensions];
    lastWidth = d.size.width;
}

#pragma mark Sequence Management

/* typical doubly-linked list stuff */

- (void)addSequenceNote:(OCNoteObj *)seqNote rootNote:(OCNoteObj *)rootNote {
    [seqNote retain];
    OCNoteObj *lastSeqNote = [self getLastNoteInSequenceFromNote:rootNote];
    lastSeqNote.next = seqNote;
    seqNote.previous = lastSeqNote;
    [sequence addObject:seqNote];
}

- (void)removeSequenceNote:(OCNoteObj *)seqNote {
    // get the notes before and after
    OCMusicObj *prv = seqNote.previous;
    OCMusicObj *nxt = seqNote.next;
    
    // tie them together
    prv.next = nxt;
    nxt.previous = prv;
    
    // clear the target note
    seqNote.previous = nil;
    seqNote.next = nil;
    seqNote.parent = nil;
    
    [sequence removeObject:seqNote];
    //[seqNote release];
}

/*
 *  get the last note in the linked list for a passed root note
 */

- (OCNoteObj *) getLastNoteInSequenceFromNote:(OCNoteObj *)note {
    if ( note.next == nil ) {
        return note;
    }
    return [self getLastNoteInSequenceFromNote:(OCNoteObj *)note.next];
}

- (OCNoteObj *) getRootNoteInSequenceFromNote:(OCNoteObj *)note {
    if ( note.previous == nil ) {
        return note;
    }
    return [self getLastNoteInSequenceFromNote:(OCNoteObj *)note.previous];
}

/*
 * Private method that should not be called from outside the class.
 *
 * Goes through the objects held in the root group and updates the rootNotes list
 * as needed.
 */

- (void) updateRootNotes:(OCMusicObj *)musicObj {
    
    // recursion on all kinds of grouping objects, regardlass of class membership
    if ( [musicObj isKindOfClass:[OCGroupObj class]] ) {
        OCGroupObj *group = (OCGroupObj *)musicObj;
        for ( OCMusicObj *mObj in group.objects ) {
            [self updateRootNotes:mObj];
        }
    }
    
    if ( [musicObj isKindOfClass:[OCNoteObj class]] ) {
        OCNoteObj *note = (OCNoteObj *)musicObj;
        // doublecheck to see if this object is already in the list, probably
        // not but we want to be sure we don't get any "false positives" in 
        // other behavior
        BOOL noteLogged = NO;
        for ( OCNoteObj *loggedNote in rootNotes ) {
            if ( note == loggedNote ) {
                noteLogged = YES;
            }
        }
        if ( !noteLogged ) {
            [rootNotes addObject:note];
        }
    }
}

#pragma mark -
#pragma mark Object Management
#pragma mark -

/*
 * Recursive function that sets selected property to contained objects to the passed 
 * value
 */

- (void)select:(BOOL)newSelected {
    selected = newSelected;
    // select the contained objects
    [root select:newSelected];
    [sequence select:newSelected];
}

/*
 * Overloaded; see OCMusicObj for information
 */

- (void) setOldData {
    // set the root objects
    [root setOldData];
    [sequence setOldData];
	lastWidth = 0.0;
	lastDelta = 0.0;
}

/*
 * Creates or destroys notes based on a given change in length
 */

- (void) resizeByDeltaX:(float)deltaX snap:(float)snapValue {
    NSRect seqDim = [self dimensions];
    NSRect rootDim = [root dimensions];
    
    for ( OCNoteObj *note in rootNotes ) {
        
        // get some vital factors for calculations
        float sbOffset = note.startBeat - rootDim.origin.x; // recalibrates the startbeat to a new zero
        float sbFactor = floorf( deltaX / rootDim.size.width ); // the number of widths encompassed by the delta
        
        // project where a new note would go if it were to be sequenced at this point
        float projectedStartBeat = rootDim.origin.x + ( rootDim.size.width * sbFactor ) + sbOffset;

        // if the sequence is being lengthened
        if ( deltaX >= lastDelta ) {
            
            if (    ![self sequenceNoteExistsForRoot:note forBeat:projectedStartBeat] && 
                    projectedStartBeat >= rootDim.origin.x + rootDim.size.width ) {
                OCNoteObj *newSeqNote = [myDocument createNoteAtStartBeat:projectedStartBeat pitch:note.pitch length:note.length];
                [self addSequenceNote:newSeqNote rootNote:note];
            }
            
        } else {            
            // the sequence is being shortened

            OCNoteObj *lastSeqNote = [self getLastNoteInSequenceFromNote:note];
            
            // this needs to be tempered so that it doesn't completely reduce on one mouse drag
            if ( lastSeqNote != note && lastSeqNote.startBeat >= projectedStartBeat ) {
                [self removeSequenceNote:lastSeqNote];
                [myDocument deleteFromDocumentNote:lastSeqNote];
            }
            
        } 
    }
    
    // save the width for next time
    seqDim = [self dimensions];
    lastWidth = seqDim.size.width;
    lastDelta = deltaX;
}

- (BOOL)sequenceNoteExistsForRoot:(OCNoteObj *)rootNote forBeat:(float)beat {
    OCNoteObj *cursor = rootNote;
    do {
        cursor = (OCNoteObj *)cursor.next;
        if (cursor != nil ) {
            if ( cursor.startBeat == beat ) {
                return YES;
            }
        }
    } while ( cursor.next != nil );
    return NO;
}

#pragma mark -
#pragma mark Dimensions Management
#pragma mark -

/*
 * '- (NSRect)dimensions' is the designated accessor.
 * Returns an NSRect containing the max beat and pitch dimensions (NOT pixel) of 
 * all objects within the hierarchy.
 * The maximum size of objects is maintained via addObject and removeObject
 */

- (NSRect)dimensions {
    
    NSRect dim = [root dimensions];
    
    if ( [sequence.objects count] > 0 ) {
        // get the dimensions in the sequence notes
        for ( OCMusicObj *musicObj in sequence.objects ) {
            dim = [self updateDimensions:dim musicObj:musicObj];
        }
        
        dim.size.width = dim.size.width - dim.origin.x;
        dim.size.height = dim.size.height - dim.origin.y;
        
    }
    return dim;
}

@end
