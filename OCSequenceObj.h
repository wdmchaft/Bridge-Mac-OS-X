//
//  OCSequenceObj.h
//  Bridge
//
//  Created by Philip Regan on 2011/12/03.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 The Sequence object is a wrapper for two Group objects. It inherits from OCGroupObj
 to take advantage of some core-editing functions, but it is a class unto itself
 in most respects
 */

#import "OCGroupObj.h"

@class OCNoteObj;
@class MyDocument;
@class OCResizeTabObj;

@interface OCSequenceObj : OCGroupObj {
    
    MyDocument *myDocument;
    // this kind of breaks MVC, but since we want the logic of new note creation 
    // destruction within the Sequence itself, and they are both data classes, it 
    // is easier to make an exception than it is to try and manage crosstalk between the two.
    
    OCResizeTabObj *resizeTab;
        
    /* Root Group Management */
    
    // simple list of notes in parent's objects
    OCGroupObj *root;
    NSMutableArray *rootNotes; 
     
    // full arpg dimensions for the interface are handled in the superclass 
    // properties
    float rootStartBeat;
    float rootWidth;
    
    /* Sequence Management */
    
    // simple list of Sequence notes, linked from the root notes
    OCGroupObj *sequence;
    
    /* Resize Management */
    
    float lastWidth;
    float lastDelta;
    
}

@property (nonatomic, retain) MyDocument *myDocument;
@property (nonatomic, retain) OCResizeTabObj *resizeTab;

@property (nonatomic, retain) OCGroupObj *root;
@property (nonatomic, retain) OCGroupObj *sequence;

#pragma mark -
#pragma mark Content Management
#pragma mark -

/*
 Almost all of the methods below are overridden from OCGroupObj
 */

#pragma mark Root Management

/*
 * Adds a single object to the hierarchy
 */

- (void)addObject:(OCMusicObj *)musicObj;

/*
 * Removes a single object to the hierarchy
 */

- (void)removeObject:(OCMusicObj *)musicObj;

/*
 * Adds an array of objects to the group. Syntactic sugar.
 */

- (void) groupObjects:(NSMutableArray *)newObjects;

/*
 * Private method that should not be called from outside the class.
 *
 * Goes through the objects held in the root group and updates the rootNotes list
 * as needed.
 */

- (void) updateRootNotes:(OCMusicObj *)musicObj;

#pragma mark Sequence Management

/*
 * Adds a single object to the sequence
 */

- (void)addSequenceNote:(OCNoteObj *)seqNote rootNote:(OCNoteObj *)rootNote;

/*
 * Removes a single object to the sequence
 */

- (void)removeSequenceNote:(OCNoteObj *)seqNote;

/*
 *  get the last note in the linked list for a passed root note
 */

- (OCNoteObj *) getLastNoteInSequenceFromNote:(OCNoteObj *)note;

/*
 *  get the root note in the linked list for a passed sequence note
 */

- (OCNoteObj *) getRootNoteInSequenceFromNote:(OCNoteObj *)note;

#pragma mark -
#pragma mark Object Management
#pragma mark -

/* 
 * Overloaded
 *
 * Recursive function that sets selected property to contained objects to the passed 
 * value
 */

- (void)select:(BOOL)newSelected;

/*
 * Overloaded; see OCMusicObj for information
 */

- (void) setOldData;

/*
 * Overloaded; Creates or destroys notes based on a given change in length
 */

- (void) resizeByDeltaX:(float)deltaX snap:(float)snapValue;
- (BOOL)sequenceNoteExistsForRoot:(OCNoteObj *)rootNote forBeat:(float)beat;

#pragma mark -
#pragma mark Dimensions Management
#pragma mark -

/*
 * '- (NSRect)dimensions' is the designated accessor.
 * Returns an NSRect containing the max beat and pitch dimensions (NOT pixel) of 
 * all objects within the hierarchy.
 * The maximum size of objects is maintained via addObject and removeObject
 */

- (NSRect)dimensions;

@end
