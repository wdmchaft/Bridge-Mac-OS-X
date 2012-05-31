//
//  OCMusicObj.h
//  Bridge
//
//  Created by Philip Regan on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * Abstract music data object
 * Adds hooks for grouping and identifying objects
 */

#import <Cocoa/Cocoa.h>

@interface OCMusicObj : NSObject {
	
	float objectID;
	
	OCMusicObj *parent;
    
    // used in helping to manage Sequence editing
    OCMusicObj *next;
    OCMusicObj *previous;
	
	// behavorial modifiers
	BOOL locked;
	BOOL selected;

	
}

#pragma mark -
#pragma mark Properties
#pragma mark -

@property (nonatomic) float objectID;

@property (nonatomic, retain) OCMusicObj *parent; 

@property (nonatomic, retain) OCMusicObj *next;
@property (nonatomic, retain) OCMusicObj *previous;

@property (nonatomic) BOOL locked;
@property (nonatomic) BOOL selected;

#pragma mark -
#pragma mark Object Management
#pragma mark -

/* 
 These methods are used to help manage other tasks as required by
 other classes. These are to be overloaded as required by each material class.
 */

// Gets the root of the group hierarchy to which a particular
// object belongs
- (OCMusicObj *)getTopParent;

// Recalibrates the "old" data with the current data, which is
// used to help manage object movement in the interface.
- (void)setOldData;

// change the length of a given object by passed length in startbeats
// overloaded by subclasses to handle their particular cases
- (void) changeLengthByDeltaX:(float)deltaX;

@end