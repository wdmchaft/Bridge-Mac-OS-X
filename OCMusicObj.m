//
//  OCMusicObj.m
//  Bridge
//
//  Created by Philip Regan on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 * Abstract music data object
 * Adds hooks for grouping and identifying objects
 */

#import "OCMusicObj.h"

@implementation OCMusicObj

#pragma mark -
#pragma mark Properties
#pragma mark -

@synthesize objectID;

@synthesize parent;

@synthesize next;
@synthesize previous;

@synthesize locked;
@synthesize selected;

#pragma mark -
#pragma mark Init
#pragma mark -

//---------------------------------------------------------- 
// - (id) init
// there is no dealloc since this class does not get instantiated directly
//---------------------------------------------------------- 
- (id) init
{
    self = [super init];
    if (self) {
        objectID = 0.0f;
		locked = NO;
        selected = NO;

    }
    return self;
}

#pragma mark -
#pragma mark Object Management
#pragma mark -

/*
 overload as required
 */

- (OCMusicObj *)getTopParent {
	return nil;
}

/*
 overload as required
 */

- (void)setOldData {
    return;
}

/*
 overload as required
 */

- (void) changeLengthByDeltaX:(float)deltaX {
	return;
}


@end
