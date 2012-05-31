//
//  OCGroupObj.h
//  Bridge
//
//  Created by Philip Regan on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 The group object is a container object for music data objects.
 */

#import "OCMusicObj.h"

@class OCNoteObj;

@interface OCGroupObj : OCMusicObj
{
	// node for hierarchy
	NSMutableArray *objects;
		
}

#pragma mark -
#pragma mark Properties
#pragma mark -


@property (readwrite, retain) NSMutableArray *objects;

#pragma mark -
#pragma mark Content Management
#pragma mark -

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
 * Removes the whole group
 * Returns an array of the children contained by the group for 
 * selection and object management elsewhere.
 * Syntactic sugar
 */

- (NSMutableArray *)ungroupObjects;

#pragma mark -
#pragma mark Object Management
#pragma mark -

/*
 * Recursive function that sets selected property to contained objects to the passed 
 * value
 */

- (void)select:(BOOL)newSelected;

/*
 * Overloaded; see OCMusicObj for information
 */

- (OCMusicObj *)getTopParent;

/*
 * Overloaded; see OCMusicObj for information
 */

- (void) setOldData;

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

/*
 * These are not to be used outside of the class
 */

- (NSRect)updateDimensions:(NSRect)dim musicObj:(OCMusicObj *)musicObj;

- (NSRect)updateDimensions:(NSRect)dim note:(OCNoteObj *)note;

- (NSRect)updateDimensions:(NSRect)dim group:(OCGroupObj *)group;

@end
