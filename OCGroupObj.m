//
//  OCGroupObj.m
//  Bridge
//
//  Created by Philip Regan on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OCGroupObj.h"

#import "OCNoteObj.h"

@implementation OCGroupObj

#pragma mark -
#pragma mark Properties
#pragma mark -


@synthesize objects;

// All dimensions must be a positive number
#define DEFAULT_DIM -1

#pragma mark -
#pragma mark init
#pragma mark -


- (id)init {
    self = [super init];
    if (self) {
        objects = [[NSMutableArray array] retain];
    }
    return self;
}

#pragma mark -
#pragma mark dealloc
#pragma mark -


- (void)dealloc {
    [objects release];
    [super dealloc];
}

#pragma mark -
#pragma mark Content Management
#pragma mark -

/*
 These methods ensure that child objects are added and removed correctly, particularly
 as it pertains to the parent/child relationship.
 */

- (void)addObject:(OCMusicObj *)musicObj {
    //[musicObj retain];
	[objects addObject:musicObj];
	musicObj.parent = self;
    musicObj.selected = selected;
}

- (void)removeObject:(OCMusicObj *)musicObj {
	musicObj.parent = nil;
	[objects removeObject:musicObj];
    //[musicObj release];
}

- (void) groupObjects:(NSMutableArray *)newObjects {
	for ( OCMusicObj *musicObj in newObjects ) {
		[self addObject:musicObj];
	}
}

- (NSMutableArray *)ungroupObjects {
	for ( OCMusicObj *musicObj in objects ) {
		musicObj.parent = nil;
	}
	return objects;
}

#pragma mark -
#pragma mark Object Management
#pragma mark -

// since the objects array can contain anything, we use type casting to discern
// which object we are working with and act accordingly

- (void)select:(BOOL)newSelected {
    // select self
	self.selected = newSelected;
	// select the objects contained
	for ( OCMusicObj *musicObj in objects ) {
		musicObj.selected = newSelected;
		// recursion on all kinds of grouping objects, regardlass of class membership
		if ( [musicObj isKindOfClass:[OCGroupObj class]] ) {
			OCGroupObj *group = (OCGroupObj *)musicObj;
			[group select:newSelected];
		}
	}
}

// overloaded method

- (OCMusicObj *)getTopParent {
	if ( parent != nil ) {
        return [parent getTopParent];
    }
	return self;
}

/*
 Manages the setting of previous beats and pitches in all child objects
 */

- (void) setOldData {
    
    if ( [objects count] == 0 ) {
        return;
    }
    
    for ( OCMusicObj *musicObj in objects ) {
        if ( [musicObj isKindOfClass:[OCNoteObj class]] ) {
            OCNoteObj *note = (OCNoteObj *)musicObj;
            [note setOldData];
        }
        // we use isKindOfClass since were are generically doing this all grouping
        // classes. Any special cases are handled in the class itself.
        if ( [musicObj isKindOfClass:[OCGroupObj class]] ) {
            OCGroupObj *group = (OCGroupObj *)musicObj;
            [group setOldData];
        }
    }
}

#pragma mark -
#pragma mark Dimensions Management
#pragma mark -

/*
 * Kicks off the process of getting the dimensions
 */

- (NSRect)dimensions {
    
	NSRect dim = NSMakeRect(DEFAULT_DIM, DEFAULT_DIM, DEFAULT_DIM, DEFAULT_DIM);
    
    for ( OCMusicObj *musicObj in objects ) {
        dim = [self updateDimensions:dim musicObj:musicObj];
    }
    
    dim.size.width = dim.size.width - dim.origin.x;
    dim.size.height = dim.size.height - dim.origin.y;
    
	return dim;
}

/*
 *  Routes the process by object
 */

- (NSRect)updateDimensions:(NSRect)dim musicObj:(OCMusicObj *)musicObj {
    // NSZombie
    if ( [musicObj isKindOfClass:[OCGroupObj class]] ) {
        OCGroupObj *group = (OCGroupObj *)musicObj;
        dim = [self updateDimensions:dim group:group];
    }
    // we use isKindOfClass since were are generically doing this all grouping
    // classes. Any special cases are handled in the class itself.
    if ( [musicObj isKindOfClass:[OCNoteObj class]] ) {
        OCNoteObj *note = (OCNoteObj *)musicObj;
        dim = [self updateDimensions:dim note:note];
    }
    
    return dim;
}

/*
 *  Passes each object to the routing method
 */

- (NSRect)updateDimensions:(NSRect)dim group:(OCGroupObj *)group {
    for ( OCMusicObj *musicObj in group.objects ) {
        dim = [self updateDimensions:dim musicObj:musicObj];
    }
	return dim;
}

/*
 * Everything comes down to the area of the note objects.
 * 
 * We calculate the absolute bounds of all the notes first, then trim off the 
 * origin when done. Trying to calculate true width and height proved to be very
 * troublesome.
 */

- (NSRect)updateDimensions:(NSRect)dim note:(OCNoteObj *)note {
    
    if (dim.origin.x == DEFAULT_DIM || 
        dim.origin.y == DEFAULT_DIM ||
        dim.size.width == DEFAULT_DIM ||
        dim.size.height == DEFAULT_DIM ) {
        
        dim.origin.x = note.startBeat;
        dim.origin.y = note.pitch;
        dim.size.width = note.startBeat + note.length;
        dim.size.height = 1.0;
    }
    
    dim.origin.x = MIN( dim.origin.x, note.startBeat );
    dim.origin.y = MIN( dim.origin.y, note.pitch );
    dim.size.width = MAX( dim.size.width, note.startBeat + note.length );
    dim.size.height = MAX( dim.size.height, note.pitch );
        
    return dim;
}

@end
